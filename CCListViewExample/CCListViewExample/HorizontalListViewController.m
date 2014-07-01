//
//  HorizontalListViewController.m
//  CCListViewExample
//
//  Created by Ian Grossberg on 7/1/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import "HorizontalListViewController.h"

@implementation HorizontalListViewController

+ (BOOL)verticalContent
{
    return NO;
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
