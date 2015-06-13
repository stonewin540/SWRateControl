//
//  SWRateControlItem.m
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWRateControlItem.h"

@interface SWRateControlItem ()

@property (nonatomic, strong) UIColor *rateColor, *rateColorHighlighted;
@property (nonatomic, strong) UIImage *rateImage, *rateImageHighlighted;

@end

@implementation SWRateControlItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        [self setRateColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self setRateColor:[UIColor yellowColor] forState:UIControlStateHighlighted];
    }
    return self;
}

#pragma mark - Property

- (void)setRating:(CGFloat)rating {
    CGFloat valid = MIN(rating, 1);
    valid = MAX(valid, 0);
    if (_rating == valid)
    {
        return;
    }
    _rating = valid;
    [self setNeedsDisplay];
}

#pragma mark - Draw

- (UIBezierPath *)ratePathInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    // TODO: JUST A JOKE, REMOVE IT!
    {
        static int seed;
        
        CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
        if (seed) {
            path = [UIBezierPath bezierPathWithArcCenter:center radius:CGRectGetMidX(rect) startAngle:(15 * M_PI / 180) endAngle:(345 * M_PI / 180) clockwise:YES];
        } else {
            path = [UIBezierPath bezierPathWithArcCenter:center radius:CGRectGetMidX(rect) startAngle:(30 * M_PI / 180) endAngle:(330 * M_PI / 180) clockwise:YES];
        }
        [path addLineToPoint:center];
        [path closePath];
        
        seed++;
        seed %= 2;
    }
    
    return path;
}

- (void)getNormalRect:(CGRect *)normalRect highlightedRect:(CGRect *)highlightedRect inRect:(CGRect)rect {
    CGFloat amount = self.rating * CGRectGetWidth(rect);
    CGRect slice, remainder;
    CGRectDivide(rect, &slice, &remainder, amount, CGRectMinXEdge);
    if (normalRect)
    {
        *normalRect = remainder;
    }
    if (highlightedRect)
    {
        *highlightedRect = slice;
    }
}

- (void)drawPathInRect:(CGRect)rect withContext:(CGContextRef)context {
    CGRect normalRect, highlightedRect;
    [self getNormalRect:&normalRect highlightedRect:&highlightedRect inRect:rect];
    
    CGContextSaveGState(context);
    {
        UIBezierPath *path = [self ratePathInRect:rect];
        [path addClip];
        
        [[self rateColorForState:UIControlStateHighlighted] setFill];
        CGContextFillRect(context, highlightedRect);
        [[self rateColorForState:UIControlStateNormal] setFill];
        CGContextFillRect(context, normalRect);
    }
    CGContextRestoreGState(context);
}

- (void)drawImageInRect:(CGRect)rect withContext:(CGContextRef)context {
    CGRect normalRect, highlightedRect;
    [self getNormalRect:&normalRect highlightedRect:&highlightedRect inRect:rect];
    
    CGContextSaveGState(context);
    {
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -CGRectGetHeight(rect));
        
        CGContextDrawImage(context, rect, [self rateImageForState:UIControlStateNormal].CGImage);
        CGContextClipToRect(context, highlightedRect);
        CGContextDrawImage(context, rect, [self rateImageForState:UIControlStateHighlighted].CGImage);
    }
    CGContextRestoreGState(context);
}

- (BOOL)isImageReachable {
    return self.rateImage && self.rateImageHighlighted;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([self isImageReachable])
    {
        [self drawImageInRect:rect withContext:context];
    }
    else
    {
        [self drawPathInRect:rect withContext:context];
    }
}

@end

@implementation SWRateControlItem (Appearance)

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
    
    [self setNeedsDisplay];
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
    
    [self setNeedsDisplay];
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
