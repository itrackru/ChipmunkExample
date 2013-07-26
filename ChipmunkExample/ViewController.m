//
//  ViewController.m
//  ChipmunkExample
//
//  Created by Игорь Мищенко on 24.07.13.
//  Copyright (c) 2013 Igor Mischenko. All rights reserved.
//

#import "ViewController.h"
#import "ObjectiveChipmunk.h"
#import "ChipmunkObject.h"
#import "ChipmunkHastySpace.h"
#import <QuartzCore/QuartzCore.h>

#define GRABABLE_MASK_BIT (1<<31)
static NSString *borderType = @"borderType";

@interface ViewController ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) ChipmunkHastySpace *space;
@property (nonatomic, strong) ChipmunkMultiGrab *multiGrab;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired = 2;
    tapRecognizer.numberOfTouchesRequired = 1;
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPressRecognizer.minimumPressDuration = 0.5;
    
    [self.view addGestureRecognizer:tapRecognizer];
    [self.view addGestureRecognizer:longPressRecognizer];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    self.space = [[ChipmunkHastySpace alloc] init];
    self.space.damping = 0.6;
    self.space.gravity = cpv(0, 100);
    [self.space addBounds:self.view.bounds
                thickness:100.0f
               elasticity:0.8f friction:1.0f
                   layers:CP_ALL_LAYERS group:CP_NO_GROUP
            collisionType:borderType];
    
    [self addNewObjectAtLocation:CGPointMake(100, 100)];
    
    [self setupMultigrab];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
	self.displayLink.frameInterval = 1;
	[self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}


#pragma mark -
#pragma mark - Instance Methods

- (UIColor *)randomColor {

    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)addNewObjectAtLocation:(CGPoint)location {

    CGRect viewRect = CGRectMake(0, 0, 60, 60);
    UIView *view = [[UIView alloc] initWithFrame:CGRectNull];
    view.center = location;
    view.backgroundColor = [self randomColor];
    [self.view addSubview:view];
    [UIView animateWithDuration:0.3
                     animations:^{
                         view.bounds = viewRect;
                     }
                     completion:^(BOOL finished){
                         [self.space smartAdd:[[ChipmunkObject alloc] initWithView:view]];
                     }];
}


- (void)removeAllObjects {

    for (ChipmunkBody *body in self.space.bodies) {
        ChipmunkObject *object = body.data;
        if ([self.space contains:object]) {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 object.view.bounds = CGRectMake(0, 0, 1, 1);
                             }
                             completion:^(BOOL finished){
                                 [object.view removeFromSuperview];
                                 [self.space smartRemove:object];
                             }];
        }
    }
}


- (void)update {
    
    cpFloat dt = self.displayLink.duration * self.displayLink.frameInterval;
	[self.space step:dt];

    for (ChipmunkBody *body in self.space.bodies) {
        ChipmunkObject *chipObject = body.data;
        [chipObject updatePosition];
    }
}


- (void)setupMultigrab {
    
    if (self.space) {
        cpFloat grabForce = 9999999;
        self.multiGrab = [[ChipmunkMultiGrab alloc] initForSpace:self.space withSmoothing:cpfpow(0.8, 60) withGrabForce:grabForce];
        self.multiGrab.layers = GRABABLE_MASK_BIT;
        self.multiGrab.pushMode = YES;
        self.multiGrab.pushMass = 1000;
        self.multiGrab.grabFriction = grabForce*0.1;
        self.multiGrab.grabRotaryFriction = 1e3 * 8;
        self.multiGrab.grabRadius = 15.0;
    }
}


#pragma mark -
#pragma mark - gesture recognizers


- (void)tap:(UITapGestureRecognizer *)gestureRecognizer {

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self addNewObjectAtLocation:[gestureRecognizer locationInView:self.view]];
    }
}


- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self removeAllObjects];
    }
}


#pragma mark -
#pragma mark Touches


- (cpVect)convertTouch:(UITouch *)touch inView:(UIView *)view {
    
	cpVect point = [touch locationInView:view];
    
    return point;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        [self.multiGrab beginLocation:[self convertTouch:touch inView:self.view]];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches)
        [self.multiGrab updateLocation:[self convertTouch:touch inView:self.view]];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        [self.multiGrab endLocation:[self convertTouch:touch inView:self.view]];
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self touchesEnded:touches withEvent:event];
}

@end
