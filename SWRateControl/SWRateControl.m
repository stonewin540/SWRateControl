//
//  SWRateControl.m
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWRateControl.h"
#import "SWRateControlItem.h"

@interface SWRateControlItemWrapperView : UIView
@end
@implementation SWRateControlItemWrapperView
@end

static const CGFloat kDefaultHeight = 50;

@interface SWRateControl ()



@property (nonatomic, assign) int numberOfItems;
@property (nonatomic, strong) NSMutableArray *rateItems;

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
        _rateItems = [[NSMutableArray alloc] init];
        
        [self reloadData];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect itemFrame = CGRectZero;
    itemFrame.size = CGSizeMake(CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
    NSUInteger count = self.rateItems.count;
    for (int i = 0; i < count; i++) {
        SWRateControlItem *item = self.rateItems[i];
        item.frame = itemFrame;
        
        itemFrame.origin.x += CGRectGetWidth(itemFrame) + self.medialGap;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = size.height;
    if (0 == height) {
        height = kDefaultHeight;
    }
    
    CGFloat itemDimension = height;
    int numberOfGaps = MAX(0, self.numberOfItems - 1);
    CGFloat itemsWidth = self.numberOfItems * itemDimension;
    CGFloat gapsWidth = numberOfGaps * self.medialGap;
    CGFloat width = itemsWidth + gapsWidth;
    
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
    
    SWRateControlItem *item;
    NSUInteger count = self.rateItems.count;
    for (int i = 0; i < count; i++) {
        item = self.rateItems[i];
        CGRect frame = item.frame;
        frame.size.width += self.medialGap;
        if (CGRectContainsPoint(frame, point)) {
            break;
        }
        
        rating++;
    }
    
    CGFloat fragmentRating = 1.f / self.fragment;
    CGFloat fragmentWidth = CGRectGetWidth(item.frame) / self.fragment;
    for (int i = 0; i < self.fragment; i++) {
        rating += fragmentRating;
        
        CGFloat amount = fragmentWidth + (fragmentWidth * i);
        CGRect slice, remainder;
        CGRectDivide(item.frame, &slice, &remainder, amount, CGRectMinXEdge);
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

- (void)addItem:(SWRateControlItem *)item {
    [self addSubview:item];
    [self.rateItems addObject:item];
}

- (void)removeAllItems {
    [self.rateItems makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.rateItems removeAllObjects];
}

- (void)reloadData {
    [self removeAllItems];
    
    for (int i = 0; i < self.numberOfItems; i++) {
        SWRateControlItem *item = [[SWRateControlItem alloc] init];
        item.rating = [self ratingForItemAtIndex:i];
        [self addItem:item];
    }
}

- (CGFloat)ratingForItemAtIndex:(int)index {
    return self.rating - index;
}

- (void)updateItemsWithBlock:(void(^)(int idx, SWRateControlItem *item))block {
    if (!block) {
        return;
    }
    
    NSUInteger count = self.rateItems.count;
    for (int i = 0; i < count; i++) {
        SWRateControlItem *item = self.rateItems[i];
        block(i, item);
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
    [self updateItemsWithBlock:^(int idx, SWRateControlItem *item) {
        item.rating = [wself ratingForItemAtIndex:idx];
    }];
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
    [self updateItemsWithBlock:^(int idx, SWRateControlItem *item) {
        [item setRateColor:wself.rateColor forState:UIControlStateNormal];
    }];
}

- (void)setRateColorHighlighted:(UIColor *)rateColorHighlighted {
    if ([_rateColorHighlighted isEqual:rateColorHighlighted]) {
        return;
    }
    _rateColorHighlighted = rateColorHighlighted;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItem *item) {
        [item setRateColor:wself.rateColorHighlighted forState:UIControlStateHighlighted];
    }];
}

- (void)setRateImage:(UIImage *)rateImage {
    if ([_rateImage isEqual:rateImage]) {
        return;
    }
    _rateImage = rateImage;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItem *item) {
        [item setRateImage:wself.rateImage forState:UIControlStateNormal];
    }];
}

- (void)setRateImageHighlighted:(UIImage *)rateImageHighlighted {
    if ([_rateImageHighlighted isEqual:rateImageHighlighted]) {
        return;
    }
    _rateImageHighlighted = rateImageHighlighted;
    
    __weak __typeof (self) wself = self;
    [self updateItemsWithBlock:^(int idx, SWRateControlItem *item) {
        [item setRateImage:wself.rateImageHighlighted forState:UIControlStateHighlighted];
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
