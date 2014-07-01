//
//  ViewController.m
//  CCListViewExample
//
//  Created by Ian Grossberg on 6/27/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import "VerticalListViewController.h"

@implementation VerticalListViewController

+ (BOOL)verticalContent
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.listView addContentView:[CCListViewController createJunkLabel] ];
    [self.listView addContentView:[CCListViewController createJunkTextView] ];
    [self.listView addContentView:[CCListViewController createJunkLabel] ];
    [self.listView addContentView:[CCListViewController createJunkTextView] ];
    [self.listView addContentView:[CCListViewController createJunkLabel] ];
    [self.listView addContentView:[CCListViewController createJunkTextView] ];
    [self.listView addContentView:[CCListViewController createJunkLabel] ];
    [self.listView addContentView:[CCListViewController createJunkTextView] ];
}

@end
