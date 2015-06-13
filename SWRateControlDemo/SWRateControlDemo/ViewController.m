//
//  ViewController.m
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "ViewController.h"
#import "SWRateControlItemView.h"
#import "SWRateControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    static const CGFloat kDimension = 100;
    SWRateControlItemView *itemView = [[SWRateControlItemView alloc] initWithFrame:CGRectMake(0, 20, kDimension, kDimension)];
    itemView.backgroundColor = [UIColor greenColor];
    itemView.rating = .5f;
    [self.view addSubview:itemView];
    
    SWRateControl *control = [[SWRateControl alloc] init];
    control.backgroundColor = [UIColor blueColor];
    control.rating = 1;
    control.enabled = NO;
    [self.view addSubview:control];
    
    SWRateControl *control2 = [[SWRateControl alloc] init];
    control2.backgroundColor = [UIColor lightGrayColor];
    [control2 setRateImage:[UIImage imageNamed:@"star"] forState:UIControlStateNormal];
    [control2 setRateImage:[UIImage imageNamed:@"star_highlighted"] forState:UIControlStateHighlighted];
    [control2 addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    {
        CGRect frame = CGRectZero;
        frame.size = [control2 sizeThatFits:CGSizeMake(0, 70)];
        frame.origin.x = roundf((CGRectGetWidth(self.view.bounds) - frame.size.width) / 2);
        frame.origin.y = 200;
        control2.frame = frame;
    }
    [self.view addSubview:control2];
    
    __weak __typeof (self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:.1f target:wself selector:@selector(timerFire:) userInfo:@{@"item": itemView, @"control": control} repeats:YES];
    });
}

- (void)timerFire:(NSTimer *)timer {
    static CGFloat rating;
    
    SWRateControlItemView *itemView = timer.userInfo[@"item"];
    itemView.rating = rating;
    if (0 == rating) {
        UIImage *rateImage, *rateImageHighlighted;
        
        if (arc4random() % 2) {
            rateImage = nil;
            rateImageHighlighted = nil;
        } else {
            rateImage = [UIImage imageNamed:@"star"];
            rateImageHighlighted = [UIImage imageNamed:@"star_highlighted"];
        }
        
        itemView.rateImage = rateImage;
        itemView.rateImageHighlighted = rateImageHighlighted;
    }
    
    int slowdown = (int)(rating * 10) % 4;
    if (0 == slowdown)
    {
        CGFloat rt = (arc4random() % 51) / 10.f;
        SWRateControl *control = timer.userInfo[@"control"];
        control.rating = rt;
        {
            CGRect frame = CGRectZero;
            frame.size = [control sizeThatFits:CGSizeZero];
            frame.origin.y = CGRectGetMaxY(itemView.frame);
            control.frame = frame;
            
            if (0 == rating) {
                UIImage *rateImage, *rateImageHighlighted;
                
                if (arc4random() % 2) {
                    rateImage = nil;
                    rateImageHighlighted = nil;
                } else {
                    rateImage = [UIImage imageNamed:@"star"];
                    rateImageHighlighted = [UIImage imageNamed:@"star_highlighted"];
                }
                
                [control setRateImage:rateImage forState:UIControlStateNormal];
                [control setRateImage:rateImageHighlighted forState:UIControlStateHighlighted];
            }
        }
    }
    
    rating += 1 / 10.f;
    rating = (ceilf(rating) > 1) ? 0 : rating;
}

- (void)valueChanged:(SWRateControl *)sender {
    NSLog(@"current rating: %.1f", sender.rating);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
