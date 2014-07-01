//
//  CCListViewController.h
//  CCListViewExample
//
//  Created by Ian Grossberg on 7/1/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CCListView/CCListView.h>

@interface CCListViewController : UIViewController

+ (BOOL)horizontalContent;
- (void)sharedInit;

@property (weak, nonatomic) IBOutlet CCListView *listView;

+ (UILabel *)createJunkLabel;
+ (UITextView *)createJunkTextView;

@end
