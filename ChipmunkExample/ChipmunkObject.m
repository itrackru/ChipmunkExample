//
//  ChipmunkObject.m
//  ChipmunkExample
//
//  Created by Игорь Мищенко on 24.07.13.
//  Copyright (c) 2013 Igor Mischenko. All rights reserved.
//

#import "ChipmunkObject.h"

@implementation ChipmunkObject

- (id)initWithView:(UIView *)view {
    
    if (self = [self init]) {
        
        _view = view;
        
        CGFloat width   = _view.frame.size.width;
        CGFloat height  = _view.frame.size.height;
        CGPoint position = _view.center;
        
        _view.center = CGPointZero;
        
        cpFloat mass = 1;
        ChipmunkBody *body = [[ChipmunkBody alloc] initWithMass:mass
                                                      andMoment:cpMomentForBox(mass, width, height)];
        body.pos = position;
        body.data = self;
        
        ChipmunkPolyShape *shape = [[ChipmunkPolyShape alloc] initBoxWithBody:body width:width height:height];
        shape.elasticity = 1.0;
        shape.collisionType = [ChipmunkObject class];
        shape.data = self;
        
        _body = body;
        _shape = shape;
        
        _chipmunkObjects = [NSArray arrayWithObjects:_body, _shape, nil];
        
        [self updatePosition];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {

    UIView *view = [[UIView alloc] initWithFrame:frame];
    return [self initWithView:view];
}


- (void)updatePosition {
    
    self.view.transform = self.body.affineTransform;
    //    NSLog(@"body position %@", NSStringFromCGPoint(self.body.pos));
}

@end
