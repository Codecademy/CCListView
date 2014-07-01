//
//  CCListViewController.m
//  CCListViewExample
//
//  Created by Ian Grossberg on 7/1/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import "CCListViewController.h"

#import <FLKAutoLayout/UIView+FLKAutoLayout.h>

@interface CCListViewController ()

@end

@implementation CCListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit
{
}

+ (BOOL)horizontalContent
{
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self ensureListView];
}

- (void)ensureListView
{
    if (!self.listView)
    {
        CCListView *listView = [ [CCListView alloc] initWithFrame:self.view.bounds horizontal:[ [self class] horizontalContent] scrolling:YES];
        self.listView = listView;
        
        [self.view addSubview:self.listView];
        self.listView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.listView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.topLayoutGuide
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0] ];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.listView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.bottomLayoutGuide
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0] ];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.listView
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.leftLayoutGuide
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1.0
                                                                   constant:0.0] ];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.listView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.rightLayoutGuide
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:0.0] ];
        
        
        self.listView.backgroundColor = [UIColor grayColor];
    }
    
    self.listView.perpendicularScrollingEnabled = NO;
    self.listView.scrollingDirectionalLockEnabled = YES;
}

+ (UILabel *)createJunkLabel
{
    UILabel *junk = [ [UILabel alloc] init];
    [junk setText:@"JUNK IN THA TRUNK"];
    [junk sizeToFit];
    [junk setBackgroundColor:[UIColor colorWithRed:0.993 green:0.702 blue:1.000 alpha:1.000] ];
    return junk;
}

+ (UITextView *)createJunkTextView
{
    UITextView *junk = [ [UITextView alloc] init];
    [junk setText:@"This is a disertation on junk, junk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junkjunk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junkjunk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junkjunk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junk junk."];
    [junk setBackgroundColor:[UIColor colorWithRed:0.689 green:0.677 blue:0.999 alpha:1.000] ];
    
    [junk setFrame:CGRectMake(0, 0, 100, 200) ];
    [junk constrainWidth:[NSString stringWithFormat:@"%f", junk.frame.size.width] ];
    [junk constrainHeight:[NSString stringWithFormat:@"%f", junk.frame.size.height] ];
    return junk;
}

@end
