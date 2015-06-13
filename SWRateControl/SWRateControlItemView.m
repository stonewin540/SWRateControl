//
//  SWRateControlItemView.m
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWRateControlItemView.h"

@interface SWRateControlItemView ()
@end

@implementation SWRateControlItemView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
        self.enabled = NO;
        
        _rateColor = [UIColor grayColor];
        _rateColorHighlighted = [UIColor yellowColor];
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

- (void)setRateColor:(UIColor *)ratingColor {
    if ([_rateColor isEqual:ratingColor]) {
        return;
    }
    _rateColor = ratingColor;
    [self setNeedsDisplay];
}

- (void)setRateColorHighlighted:(UIColor *)ratingColorHighlighted {
    if ([_rateColorHighlighted isEqual:ratingColorHighlighted]) {
        return;
    }
    _rateColorHighlighted = ratingColorHighlighted;
    [self setNeedsDisplay];
}

- (void)setRateImage:(UIImage *)ratingImage {
    if ([_rateImage isEqual:ratingImage]) {
        return;
    }
    _rateImage = ratingImage;
    [self setNeedsDisplay];
}

- (void)setRateImageHighlighted:(UIImage *)ratingImageHighlighted {
    if ([_rateImageHighlighted isEqual:ratingImageHighlighted]) {
        return;
    }
    _rateImageHighlighted = ratingImageHighlighted;
    [self setNeedsDisplay];
}

#pragma mark - Draw

- (UIBezierPath *)ratingPathInRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    // TODO: JUST A JOKE, PLEASE REMOVE IT!
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
        UIBezierPath *path = [self ratingPathInRect:rect];
        [path addClip];
        
        [self.rateColorHighlighted setFill];
        CGContextFillRect(context, highlightedRect);
        [self.rateColor setFill];
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
        
        CGContextDrawImage(context, rect, self.rateImage.CGImage);
        CGContextClipToRect(context, highlightedRect);
        CGContextDrawImage(context, rect, self.rateImageHighlighted.CGImage);
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
