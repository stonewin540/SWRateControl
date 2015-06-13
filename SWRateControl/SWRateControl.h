//
//  SWRateControl.h
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWRateControl : UIControl

@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, assign) CGFloat medialGap;
@property (nonatomic, assign) int fragment;

@end

@interface SWRateControl (Appearance)

- (void)setRateColor:(UIColor *)rateColor forState:(UIControlState)state;
- (UIColor *)rateColorForState:(UIControlState)state;
- (void)setRateImage:(UIImage *)rateImage forState:(UIControlState)state;
- (UIImage *)rateImageForState:(UIControlState)state;

@end
