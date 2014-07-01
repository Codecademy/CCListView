//
//  CCListView.m
//  CodecademyMobile
//
//  Created by Ian Grossberg on 3/31/14.
//  Copyright (c) 2014 Codecademy. All rights reserved.
//

#import "CCListView.h"

#import "UIScrollView+Utility.h"
#import <FLKAutoLayout/UIView+FLKAutoLayout.h>

#ifndef NSLogVerbose
#define NSLogVerbose NSLog
#endif

#ifndef NSLogWarn
#define NSLogWarn NSLog
#endif

#ifndef NSLogError
#define NSLogError NSLog
#endif

const NSString *CodingContentViewPreviousConstraintsKey = @"CodingContentViewPreviousConstraints";
const NSString *CodingContentViewNextConstraintsKey = @"CodingContentViewNextConstraints";

@interface CCListView ()

@property (strong, readwrite) NSMutableArray *contentViews;
@property (strong, readwrite) NSMutableDictionary *contentViewsConstraints;

// the last content view's contraints to the bottom, these are the ones that change the most with each newly added content view
@property (strong, readwrite) NSArray *lastContentViewContraints; // TODO: wrap into contentViewsConstraints dict

@property (readwrite) CGFloat disabledPerpendicularScrollingLastPositionComponent;

@end

@implementation CCListView

@synthesize horizontal = _horizontal;

- (instancetype)initWithFrame:(CGRect)frame horizontal:(BOOL)horizontal scrolling:(BOOL)scrolling
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit:horizontal scrolling:scrolling];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self sharedInit:NO scrolling:YES];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self sharedInit:NO scrolling:YES];
    }
    return self;
}

- (void)sharedInit:(BOOL)horizontal scrolling:(BOOL)scrolling
{
    _horizontal = horizontal;
    
    self.shouldConstrainTrailingEdge = NO;
    
#if DEBUG
    self.debugShowFieldBounds = NO;
#endif
    self.contentViews = [NSMutableArray array];
    self.contentViewsConstraints = [NSMutableDictionary dictionary];

    [self ensureContentView:scrolling];
}

- (void)ensureContentView:(BOOL)scrolling
{
    if (!self.containerView)
    {
        UIView *contentView;
        if (scrolling)
        {
            contentView = [ [UIScrollView alloc] initWithFrame:self.bounds];
        } else
        {
            contentView = [ [UIView alloc] initWithFrame:self.bounds];
        }
        
        [self addSubview:contentView];
        
        self.containerView = contentView;
        
        self.containerView.translatesAutoresizingMaskIntoConstraints = NO;

        self.containerView.backgroundColor = [UIColor clearColor];
        
        [self.containerView alignLeading:@"0" trailing:@"0" toView:self];
        [self.containerView alignTop:@"0" bottom:@"0" toView:self];
        
        if (scrolling && self.scrollContainerView)
        {
            UIScrollView *contentScrollView = self.scrollContainerView;
            contentScrollView.delegate = self;
            
            if (self.horizontal)
            {
                contentScrollView.contentInset = UIEdgeInsetsMake(10.0f, 0, 10.0f, 0);
                
                CGFloat forceHeight = contentScrollView.frame.size.height - contentScrollView.contentInset.top - contentScrollView.contentInset.bottom;
                
                [contentScrollView forceHeight:forceHeight]; // necessary for containing scrolling content that we don't want autosizing up
                
            } else
            {
                contentScrollView.contentInset = UIEdgeInsetsMake(0, 10.0f, 0, 10.0f);
                
                CGFloat forceWidth = contentScrollView.frame.size.width - contentScrollView.contentInset.left - contentScrollView.contentInset.right;
                
                [contentScrollView forceWidth:forceWidth]; // necessary for containing scrolling content that we don't want autosizing up
            }
        }
    }
    
    self.contentViewSpacing = 5.0f;
}

- (UIScrollView *)scrollContainerView
{
    UIScrollView *result;
    
    if ( [self.containerView isKindOfClass:[UIScrollView class] ] )
    {
        result = (UIScrollView *)self.containerView;
    }
    
    return result;
}

- (void)addContentView:(UIView *)newView
{
    if (newView)
    {
        newView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.containerView addSubview:newView];
        
        __block UIView *previousView = [self.contentViews lastObject];
        
        NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(newView);
        
        [self constrainViewToBounds:newView];
        
        if (self.lastContentViewContraints.count > 0)
        {
            [previousView.superview removeConstraints:self.lastContentViewContraints];
            self.lastContentViewContraints = nil;
        }
        
        [self constrainView:newView toPrevious:previousView];
        
        NSArray *bottomConstraints;
        NSString *bottomConstraintString;
        if (self.horizontal)
        {
            bottomConstraintString = [NSString stringWithFormat:@"H:[newView]|"];
        } else
        {
            bottomConstraintString = [NSString stringWithFormat:@"V:[newView]|"];
        }
        bottomConstraints = [NSLayoutConstraint constraintsWithVisualFormat:bottomConstraintString
                                                                    options:0
                                                                    metrics:0
                                                                      views:viewsDictionary];
        [newView.superview addConstraints:bottomConstraints];
        self.lastContentViewContraints = bottomConstraints;
        
#if DEBUG
        [self setDebugShowFieldBoundsOnView:newView];
#endif
        NSUInteger index = (unsigned long)(self.contentViews.count);
        [self.contentViews addObject:newView];
        
        if (self.addedOrInsertedContentViewHandler)
        {
            self.addedOrInsertedContentViewHandler(newView, index);
        }
        
        NSLogVerbose(@"Added view %@ at index %lu", newView, (unsigned long)index);
    } else
    {
        NSLogWarn(@"Attempted to add nil view");
    }
}


- (void)insertContentView:(UIView *)view atIndex:(NSUInteger)index
{
    if (index < self.contentViews.count)
    {
        UIView *previousView;
        if (index != 0)
        {
            previousView = [self contentViewAtIndex:index - 1];
        }
        UIView *nextView = [self contentViewAtIndex:index];
        
        [self removeConstraintsOfType:CodingContentViewPreviousConstraintsKey forView:nextView];
        
        [self.containerView addSubview:view];
        
        [self constrainViewToBounds:view];
        
        [self constrainView:view toPrevious:previousView];
        [self constrainView:nextView toPrevious:view];
        
#if DEBUG
        [self setDebugShowFieldBoundsOnView:view];
#endif
        
        [self.contentViews insertObject:view atIndex:index];
        
        if (self.addedOrInsertedContentViewHandler)
        {
            self.addedOrInsertedContentViewHandler(view, index);
        }

        NSLogVerbose(@"Inserted view %@ at index %lu", view, (unsigned long)index);
    } else
    {
        [self addContentView:view];
    }
}

- (void)constrainViewToBounds:(UIView *)constrainView
{
    if (self.horizontal)
    {
        [constrainView alignTopEdgeWithView:self.containerView predicate:@"0"];
        if (self.shouldConstrainTrailingEdge)
        {
            [constrainView alignBottomEdgeWithView:self.containerView predicate:@"0"];
        } else
        {
            [constrainView alignBottomEdgeWithView:self.containerView predicate:@"<=0"];
        }

    } else
    {
        [constrainView alignLeadingEdgeWithView:self.containerView predicate:@"0"];
        if (self.shouldConstrainTrailingEdge)
        {
            [constrainView alignTrailingEdgeWithView:self.containerView predicate:@"0"];
        } else
        {
            [constrainView alignTrailingEdgeWithView:self.containerView predicate:@"<=0"];
        }
    }
}

- (void)constrainView:(UIView *)constrainView toPrevious:(UIView *)previousView
{
    if (constrainView)
    {
        NSArray *addedConstraints;
        if (!previousView)
        {
            NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(constrainView);
            NSString *topConstraintString;
            if (self.horizontal)
            {
                topConstraintString = [NSString stringWithFormat:@"H:|[constrainView]"];
            } else
            {
                topConstraintString = [NSString stringWithFormat:@"V:|[constrainView]"];
            }
            addedConstraints = [NSLayoutConstraint constraintsWithVisualFormat:topConstraintString
                                                                       options:0
                                                                       metrics:0
                                                                         views:viewsDictionary];
            [constrainView.superview addConstraints:addedConstraints];
        } else
        {
            NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(constrainView, previousView);
            NSString *topConstraintString;
            if (self.horizontal)
            {
                topConstraintString = [NSString stringWithFormat:@"H:[previousView]-%f-[constrainView]", self.contentViewSpacing];
            } else
            {
                topConstraintString = [NSString stringWithFormat:@"V:[previousView]-%f-[constrainView]", self.contentViewSpacing];
            }
            addedConstraints = [NSLayoutConstraint constraintsWithVisualFormat:topConstraintString
                                                                       options:0
                                                                       metrics:0
                                                                         views:viewsDictionary];
            [constrainView.superview addConstraints:addedConstraints];
        }
        
        [self addConstraints:addedConstraints ofType:CodingContentViewPreviousConstraintsKey forView:constrainView];
    } else
    {
        NSLogWarn(@"Attempting to constrain view but it's nil");
    }
}

- (NSString *)constraintsKeyForView:(UIView *)view
{
    return [NSString stringWithFormat:@"%d", (int)view];
}

// TODO: w/ removeConstraintsOfType below: make functionality or naming consistent, add only adds to dict, remove removes from view and dict
- (void)addConstraints:(NSArray *)constraints ofType:(const NSString *)constraintType forView:(UIView *)view
{
    if (constraints)
    {
        NSMutableDictionary *constraintsDict = [self getConstraintsForView:view];
        if (!constraintsDict)
        {
            constraintsDict = [NSMutableDictionary dictionaryWithCapacity:2];
        }
        
        [constraintsDict setObject:constraints forKey:constraintType];
        
        [self.contentViewsConstraints setObject:constraintsDict forKey:[self constraintsKeyForView:view] ];
    } else
    {
        NSLogWarn(@"Attempting to add constraints for %@ but constraints list is nil", view);
    }
}

- (NSMutableDictionary *)getConstraintsForView:(UIView *)view
{
    return [self.contentViewsConstraints objectForKey:[self constraintsKeyForView:view] ];
}

- (void)removeConstraintsOfType:(const NSString *)constraintType forView:(UIView *)view
{
    if (view)
    {
        NSMutableDictionary *constraintsDict = [self getConstraintsForView:view];
        NSArray *constraints = [constraintsDict objectForKey:constraintType];
        if (constraints.count > 0)
        {
            [constraintsDict removeObjectForKey:constraintType];
            [view.superview removeConstraints:constraints];
        } else
        {
            NSLogWarn(@"No constraints of type %@ found for %@", constraintType, view);
        }
    } else
    {
        NSLogWarn(@"Attempting to remove constraints for type %@ but view is nil", constraintType);
    }
}

- (void)enumerateContentViews:(void (^)(UIView *view, NSUInteger index, BOOL *stop) )block
{
    if (block)
    {
        NSUInteger index = 0;
        BOOL stop = NO;
        for (id object in self.contentViews)
        {
            if ( [object isKindOfClass:[UIView class] ] )
            {
                block( (UIView *)object, index, &stop);
                if (stop)
                {
                    break;
                }
                index ++;
            }
        }
    }
}

- (UIView *)firstContentView
{
    return self.contentViews.firstObject;
}

- (UIView *)lastContentView
{
    return self.contentViews.lastObject;
}

- (UIView *)contentViewAtIndex:(NSUInteger)index
{
    UIView *result;
    if (index < self.contentViews.count)
    {
        result = [self.contentViews objectAtIndex:index];
    } else
    {
        NSLogWarn(@"Attempting to retrieve content view at index (%lu) but only have a count of (%lu)", (unsigned long)index, (unsigned long)self.contentViews.count);
    }
    return result;
}

- (UIView *)previousContentViewFromView:(UIView *)view
{
    UIView *result;
    
    if ( ![self contentViewIsFirst:view] )
    {
        NSUInteger index = [self indexOfContentView:view];
        result = [self contentViewAtIndex:index - 1];
    }
    
    return result;
}

- (UIView *)nextContentViewFromView:(UIView *)view
{
    UIView *result;
    
    if ( ![self contentViewIsLast:view] )
    {
        NSUInteger index = [self indexOfContentView:view];
        result = [self contentViewAtIndex:index + 1];
    }
    
    return result;
}

- (NSUInteger)indexOfContentView:(UIView *)contentView
{
    return [self.contentViews indexOfObject:contentView];
}

- (NSUInteger)countofContentViews
{
    return self.contentViews.count;
}

- (CGPoint)originOfContentViewAtIndex:(NSUInteger)index
{
    CGPoint result;
    if (index < [self countofContentViews] )
    {
        UIView *viewAtIndex = [self contentViewAtIndex:index];
        result = viewAtIndex.frame.origin;
    } else
    {
        UIView *lastView = [self lastContentView];
        if (self.horizontal)
        {
            result.x = lastView.frame.origin.x + lastView.frame.size.width + self.contentViewSpacing;
            result.y = lastView.frame.origin.y;
        } else
        {
            result.x = lastView.frame.origin.x;
            result.y = lastView.frame.origin.y + lastView.frame.size.height + self.contentViewSpacing;
        }
    }
    
    return result;
}

- (CGPoint)insertPointOfContentViewAtIndex:(NSUInteger)index
{
    CGPoint result;

    CGPoint viewOrigin = [self originOfContentViewAtIndex:index];
    
    if (self.horizontal)
    {
        result.x = viewOrigin.x - self.contentViewSpacing / 2.0f;
        result.y = viewOrigin.y;
    } else
    {
        result.x = viewOrigin.x;
        result.y = viewOrigin.y - self.contentViewSpacing / 2.0f;
    }
    
    if (self.scrollContainerView)
    {
        CGPoint offset = self.scrollContainerView.contentOffset;
        
        result.x -= offset.x;
        result.y -= offset.y;
    }
    
    return result;
}

- (CGSize)contentSize
{
    CGSize result;
    if (self.scrollContainerView)
    {
        result = self.scrollContainerView.contentSize;
    } else
    {
        result = self.containerView.frame.size;
    }
    
    return result;
}

- (UIView *)contentViewAtLocation:(CGPoint)location inView:(UIView *)relativeView
{
    __block UIView *result;
    
    [self enumerateContentViews:^(UIView *view, NSUInteger index, BOOL *stop)
     {
         CGPoint relativeLocation = [view.superview convertPoint:location fromView:relativeView];
         if (CGRectContainsPoint(view.frame, relativeLocation) )
         {
             result = view;
             *stop = YES;
         } else
         {
             CGPoint nextViewOrigin;
             
             UIView *nextView = [self nextContentViewFromView:view];
             if (nextView)
             {
                 nextViewOrigin = nextView.frame.origin;
             } else
             {
                 nextViewOrigin = [self originOfContentViewAtIndex:[self countofContentViews] ];
             }
             
             if (self.horizontal)
             {
                 if ( abs( (int)view.frame.origin.x - (int)relativeLocation.x) < abs( (int)nextViewOrigin.x - (int)relativeLocation.x) )
                 {
                     result = view;
                     *stop = YES;
                 }
             } else
             {
                 if ( abs( (int)view.frame.origin.y - (int)relativeLocation.y) < abs( (int)nextViewOrigin.y - (int)relativeLocation.y) )
                 {
                     result = view;
                     *stop = YES;
                 }
             }
         }
     } ];
    
    return result;
}

- (BOOL)isContentView:(UIView *)view
{
    return [self.contentViews containsObject:view];
}

- (BOOL)contentViewIsFirst:(UIView *)contentView
{
    return [self.contentViews firstObject] == contentView;
}

- (BOOL)contentViewIsLast:(UIView *)contentView
{
    return [self.contentViews lastObject] == contentView;
}

- (NSUInteger)contentViewIndexForLocation:(CGPoint)location inView:(UIView *)inView
{
    NSUInteger result = NSNotFound;

    UIView *contentViewForLocation = [self contentViewAtLocation:location inView:inView];
    if (contentViewForLocation)
    {
        result = [self indexOfContentView:contentViewForLocation];
    }
    
    return result;
}

- (void)removeContentView:(UIView *)contentView butKeepAsSubview:(BOOL)keepAsSubview
{
    if ( [self.contentViews containsObject:contentView] )
    {
        NSUInteger index = [self indexOfContentView:contentView];
        
        UIView *previousView = [self previousContentViewFromView:contentView];
        UIView *nextView = [self nextContentViewFromView:contentView];
        
        [self.contentViews removeObject:contentView];
        
        [self removeConstraintsOfType:CodingContentViewPreviousConstraintsKey forView:contentView];
        if (nextView)
        {
            [self removeConstraintsOfType:CodingContentViewPreviousConstraintsKey forView:nextView];
            [self constrainView:nextView toPrevious:previousView];
        }
        
        if (!keepAsSubview)
        {
            [contentView removeFromSuperview];
        }
        
        if (self.removedContentViewHandler)
        {
            self.removedContentViewHandler(contentView, index);
        }
        
        NSLogVerbose(@"Removed view %@ from index %lu", contentView, (unsigned long)index);
    } else
    {
        NSLogWarn(@"Attempting to remove a content view (%@) not current in the list", contentView);
    }
}

- (void)removeContentView:(UIView *)contentView
{
    [self removeContentView:contentView butKeepAsSubview:NO];
}

- (void)removeContentViewAtIndex:(NSUInteger)index
{
    if (index < self.contentViews.count)
    {
        UIView *contentView = [self.contentViews objectAtIndex:index];
        [self removeContentView:contentView];
    } else
    {
        NSLogWarn(@"Attempting to remove an index (%lu) past the content views count (%lu)", (unsigned long)index, (unsigned long)self.contentViews.count);
    }
}

- (void)removeAllContentViews
{
    NSArray *contentViews = [self.contentViews copy];
    [contentViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ( [obj isKindOfClass:[UIView class] ] )
         {
             [self removeContentView:obj];
         }
     }];
}

- (BOOL)resignFirstResponder
{
    __block BOOL resigned = NO;
    
    [self enumerateContentViews:^(UIView *view, NSUInteger index, BOOL *stop)
     {
         resigned = *stop = [view resignFirstResponder];
     } ];
    
    if (!resigned)
    {
        resigned = [super resignFirstResponder];
    }
    return resigned;
}

+ (CCListView *)parentListView:(UIView *)forView;
{
    CCListView *result;
    
    UIView *immediateParent = [forView superview];
    if ( [immediateParent isKindOfClass:[UIView class] ] || [immediateParent isKindOfClass:[UIScrollView class] ] )
    {
        UIView *nextParent = [immediateParent superview];
        if ( [nextParent isKindOfClass:[CCListView class] ] )
        {
            result = (CCListView *)nextParent;
        }
    }
    
    return result;
}

@synthesize perpendicularScrollingEnabled = _perpendicularScrollingEnabled;
- (void)setPerpendicularScrollingEnabled:(BOOL)perpendicularScrollingEnabled
{
    _perpendicularScrollingEnabled = perpendicularScrollingEnabled;
    if (!_perpendicularScrollingEnabled && self.scrollContainerView)
    {
        if (self.horizontal)
        {
            self.disabledPerpendicularScrollingLastPositionComponent = self.scrollContainerView.contentOffset.y;
        } else
        {
            self.disabledPerpendicularScrollingLastPositionComponent = self.scrollContainerView.contentOffset.x;
        }
    }
}

- (BOOL)isPerpendicularScrollingEnabled
{
    return _perpendicularScrollingEnabled;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.perpendicularScrollingEnabled)
    {
        if (self.horizontal)
        {
            [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, self.disabledPerpendicularScrollingLastPositionComponent) ];
        } else
        {
            [scrollView setContentOffset:CGPointMake(self.disabledPerpendicularScrollingLastPositionComponent, scrollView.contentOffset.y)];
        }
    }
}

- (void)setScrollingDirectionalLockEnabled:(BOOL)directionalLockEnabled
{
    if (self.scrollContainerView)
    {
        self.scrollContainerView.directionalLockEnabled = directionalLockEnabled;
    }
}

- (BOOL)isScrollingDirectionalLockEnabled
{
    BOOL result = NO;
    if (self.scrollContainerView)
    {
        result = self.scrollContainerView.directionalLockEnabled;
    }
    return result;
}

#pragma mark Debug

#if DEBUG
@synthesize debugShowFieldBounds = _debugShowFieldBounds;
- (void)setDebugShowFieldBounds:(BOOL)debugShowFieldBounds
{
    _debugShowFieldBounds = debugShowFieldBounds;
    for (id object in self.contentViews)
    {
        if ( [object isKindOfClass:[UIView class] ] )
        {
            [self setDebugShowFieldBoundsOnView:object];
        }
    }
}

- (void)setDebugShowFieldBoundsOnView:(UIView *)view
{
    if (self.debugShowFieldBounds)
    {
        [view.layer setBorderColor:[UIColor redColor].CGColor ];
        [view.layer setBorderWidth:1.0f];
    }
}

- (BOOL)debugShowFieldBounds
{
    return _debugShowFieldBounds;
}

#endif

@end
