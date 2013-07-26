//
//  ChipmunkObject.h
//  ChipmunkExample
//
//  Created by Игорь Мищенко on 24.07.13.
//  Copyright (c) 2013 Igor Mischenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveChipmunk.h"

@interface ChipmunkObject : NSObject <ChipmunkObject>

@property (readonly) NSArray *chipmunkObjects;
@property (readonly) ChipmunkBody *body;
@property (readonly) ChipmunkPolyShape *shape;
@property (readonly) UIView *view;

- (id)initWithView:(UIView *)view;
- (id)initWithFrame:(CGRect)frame;
- (void)updatePosition;

@end
