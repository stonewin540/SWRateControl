//
//  SWRateControl.m
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWRateControl.h"
#import "SWRateControlItemView.h"

@interface SWRateControlItemViewWrapperView : UIView
@end
@implementation SWRateControlItemViewWrapperView
@end

static const CGFloat kDefaultHeight = 50;

@interface SWRateControl ()



@property (nonatomic, assign) int numberOfItems;
@property (nonatomic, strong) NSMutableArray *rateItemViews;

@property (nonatomic, strong) UIColor *rateColor, *rateColorHighlighted;
@property (nonatomic, strong) UIImage *rateImage, *rateImageHighlighted;

@end

@implementation SWRateControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        _numberOfItems = 5;
        _medialGap = 5;
        _fragment = 2;
        _rateItemViews = [[NSMutableArray alloc] init];
        
        [self reloadData];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect itemViewFrame = CGRectZero;
    itemViewFrame.size = CGSizeMake(CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    NSUInteger count = self.rateItemViews.count;
    for (int i = 0; i < count; i++) {
        SWRateControlItemView *itemView = self.rateItemViews[i];
        itemView.frame = itemViewFrame;
        
        itemViewFrame.origin.x += CGRectGetWidth(itemViewFrame) + self.medialGap;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = size.height;
    if (0 == height) {
        height = kDefaultHeight;
    }
    
    CGFloat itemViewDimension = height;
    int numberOfGaps = MAX(0, self.numberOfItems - 1);
    CGFloat itemViewsWidth = self.numberOfItems * itemViewDimension;
    CGFloat gapsWidth = numberOfGaps * self.medialGap;
    CGFloat width = itemViewsWidth + gapsWidth;
    
    return CGSizeMake(width, height);
}

#pragma mark - Interactive

- (CGFloat)ratingOfPoint:(CGPoint)point {
    CGFloat rating = 0;
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        if (point.x <= CGRectGetMinX(self.bounds)) {
            rating = 0;
        } else if (CGRectGetMaxX(self.bounds) <= point.x) {
            rating = self.numberOfItems;
        }
        return rating;
    }
    
    SWRateControlItemView *itemView;
    NSUInteger count = self.rateItemViews.count;
    for (int i = 0; i < count; i++) {
        itemView = self.rateItemViews[i];
        CGRect frame = itemView.frame;
        frame.size.width += self.medialGap;
        if (CGRectContainsPoint(frame, point)) {
            break;
        }
        
        rating++;
    }
    
    CGFloat fragmentRating = 1.f / self.fragment;
    CGFloat fragmentWidth = CGRectGetWidth(itemView.frame) / self.fragment;
    for (int i = 0; i < self.fragment; i++) {
        rating += fragmentRating;
        
        CGFloat amount = fragmentWidth + (fragmentWidth * i);
        CGRect slice, remainder;
        CGRectDivide(itemView.frame, &slice, &remainder, amount, CGRectMinXEdge);
        if (CGRectContainsPoint(slice, point))
        {
            break;
        }
    }
    
    return rating;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    CGFloat rating = [self ratingOfPoint:point];
    self.rating = rating;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint point = [touch locationInView:self];
    CGFloat rating = [self ratingOfPoint:point];
    self.rating = rating;
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)addItemView:(SWRateControlItemView *)itemView {
    [self addSubview:itemView];
    [self.rateItemViews addObject:itemView];
}

- (void)removeAllItemViews {
    [self.rateItemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.rateItemViews removeAllObjects];
}

- (void)reloadData {
    [self removeAllItemViews];
    
    for (int i = 0; i < self.numberOfItems; i++) {
        SWRateControlItemView *itemView = [[SWRateControlItemView alloc] init];
        itemView.rating = [self ratingForItemAtIndex:i];
        [self addItemView:itemView];
    }
}

- (CGFloat)ratingForItemAtIndex:(int)index {
    return self.rating - index;
}

- (void)updateItemsWithBlock:(void(^)(int idx, SWRateControlItemView *itemView))block {
    if (!block) {
        return;
    }
    
    NSUInteger count = self.rateItemViews.count;
    for (int i = 0; i < count; i++) {
        SWRateControlItemView *itemView = self.rateItemViews[i];
        block(i, itemView);
    }
}

#pragma mark - Property

- (void)setRating:(CGFloat)rating {
    CGFloat valid = MIN(rating, self.numberOfItems);
    valid = MAX(valid, 0);
    if (_rating == valid) {
        return;
    }
    _rating = valid;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItemView *itemView) {
        itemView.rating = [wself ratingForItemAtIndex:idx];
    }];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setNumberOfItems:(int)numberOfItems {
    int valid = MAX(0, numberOfItems);
    if (_numberOfItems == valid) {
        return;
    }
    _numberOfItems = valid;
}

- (void)setMedialGap:(CGFloat)medialGap {
    CGFloat valid = MAX(0, medialGap);
    if (_medialGap == valid) {
        return;
    }
    _medialGap = valid;
}

- (void)setRateColor:(UIColor *)rateColor {
    if ([_rateColor isEqual:rateColor]) {
        return;
    }
    _rateColor = rateColor;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItemView *itemView) {
        itemView.rateColor = wself.rateColor;
    }];
}

- (void)setRateColorHighlighted:(UIColor *)rateColorHighlighted {
    if ([_rateColorHighlighted isEqual:rateColorHighlighted]) {
        return;
    }
    _rateColorHighlighted = rateColorHighlighted;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItemView *itemView) {
        itemView.rateColorHighlighted = wself.rateColorHighlighted;
    }];
}

- (void)setRateImage:(UIImage *)rateImage {
    if ([_rateImage isEqual:rateImage]) {
        return;
    }
    _rateImage = rateImage;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItemView *itemView) {
        itemView.rateImage = wself.rateImage;
    }];
}

- (void)setRateImageHighlighted:(UIImage *)rateImageHighlighted {
    if ([_rateImageHighlighted isEqual:rateImageHighlighted]) {
        return;
    }
    _rateImageHighlighted = rateImageHighlighted;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItemView *itemView) {
        itemView.rateImageHighlighted = wself.rateImageHighlighted;
    }];
}

@end

@implementation SWRateControl (Appearance)

- (void)setRateColor:(UIColor *)rateColor forState:(UIControlState)state {
    switch (state) {
        case UIControlStateHighlighted:
            self.rateColorHighlighted = rateColor;
            break;
        case UIControlStateNormal:
            self.rateColor = rateColor;
            break;
        default:
            break;
    }
}

- (UIColor *)rateColorForState:(UIControlState)state {
    UIColor *color = nil;
    
    switch (state) {
        case UIControlStateHighlighted:
            color = self.rateColorHighlighted;
            break;
        case UIControlStateNormal:
            color = self.rateColor;
            break;
        default:
            break;
    }
    
    return color;
}

- (void)setRateImage:(UIImage *)rateImage forState:(UIControlState)state {
    switch (state) {
        case UIControlStateHighlighted:
            self.rateImageHighlighted = rateImage;
            break;
        case UIControlStateNormal:
            self.rateImage = rateImage;
            break;
        default:
            break;
    }
}

- (UIImage *)rateImageForState:(UIControlState)state {
    UIImage *image = nil;
    
    switch (state) {
        case UIControlStateHighlighted:
            image = self.rateImageHighlighted;
            break;
        case UIControlStateNormal:
            image = self.rateImage;
            break;
        default:
            break;
    }
    
    return image;
}

@end
