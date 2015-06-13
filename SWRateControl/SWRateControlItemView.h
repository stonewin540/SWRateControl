//
//  SWRateControlItemView.h
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWRateControlItemView : UIView

@property (nonatomic, assign) CGFloat rating;
@property (nonatomic, strong) UIColor *rateColor, *rateColorHighlighted;
@property (nonatomic, strong) UIImage *rateImage, *rateImageHighlighted;
@property (nonatomic, getter=isUserInteractionEnabled, setter=setUserInteractionEnabled:) BOOL enabled;

@end
