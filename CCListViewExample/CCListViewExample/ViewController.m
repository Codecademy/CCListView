//
//  ViewController.m
//  CCListViewExample
//
//  Created by Ian Grossberg on 6/27/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import "ViewController.h"

#import <CCListView/CCListView.h>
#import <FLKAutoLayout/UIView+FLKAutoLayout.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.listView addContentView:[ViewController createJunkLabel] ];
    [self.listView addContentView:[ViewController createJunkTextView] ];
    [self.listView addContentView:[ViewController createJunkLabel] ];
    [self.listView addContentView:[ViewController createJunkTextView] ];
    [self.listView addContentView:[ViewController createJunkLabel] ];
    [self.listView addContentView:[ViewController createJunkTextView] ];
    [self.listView addContentView:[ViewController createJunkLabel] ];
    [self.listView addContentView:[ViewController createJunkTextView] ];
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
    [junk setFrame:CGRectMake(0, 0, 100, 100) ];
    [junk constrainWidth:@"200"];
    [junk constrainHeight:@"100"];
    return junk;
}

@end
