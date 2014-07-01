//
//  UIScrollView+Utility.m
//  CodecademyMobile
//
//  Created by Ian Grossberg on 2/28/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import "UIScrollView+Utility.h"

@implementation UIScrollView (Utility)

- (void)forceWidth:(CGFloat)width
{
    UIView *forceWidth = [ [UIView alloc] initWithFrame:CGRectMake(0, 0, width, 1.0f) ]; // TODO: test with 0 height
    
    [forceWidth setBackgroundColor:[UIColor clearColor] ];
    [forceWidth setUserInteractionEnabled:NO];
    
    [self addSubview:forceWidth];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(forceWidth);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[forceWidth(%f)]|", width]
                                                                 options:0
                                                                 metrics:0
                                                                   views:viewsDictionary] ];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[forceWidth]"
                                                                 options:0
                                                                 metrics:0
                                                                   views:viewsDictionary] ];
}

- (void)forceHeight:(CGFloat)height
{
    UIView *forceheight = [ [UIView alloc] initWithFrame:CGRectMake(0, 0, 1.0f, height) ]; // TODO: test with 0 width
    
    [forceheight setBackgroundColor:[UIColor clearColor] ];
    [forceheight setUserInteractionEnabled:NO];
    
    [self addSubview:forceheight];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(forceheight);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[forceheight]"
                                                                 options:0
                                                                 metrics:0
                                                                   views:viewsDictionary] ];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[forceheight(%f)]|", height]
                                                                 options:0
                                                                 metrics:0
                                                                   views:viewsDictionary] ];
}

@end
