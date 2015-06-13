//
//  SWRateControlItemViewController.m
//  SWRateControlDemo
//
//  Created by stone win on 6/13/15.
//  Copyright (c) 2015 stone win. All rights reserved.
//

#import "SWRateControlItemViewController.h"
#import "SWRateControlItemView.h"

@interface SWRateControlItemViewController ()

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation SWRateControlItemViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"SWRateControlItemViewDemo";
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)timerFire:(NSTimer *)timer {
    static CGFloat rating;
    
    SWRateControlItemView *itemView = timer.userInfo[@"itemView"];
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
    
    rating += 1 / 10.f;
    rating = (ceilf(rating) > 1) ? 0 : rating;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    static const CGFloat kDimension = 100;
    SWRateControlItemView *itemView = [[SWRateControlItemView alloc] initWithFrame:CGRectMake(0, 20, kDimension, kDimension)];
    itemView.backgroundColor = [UIColor greenColor];
    itemView.rating = .5f;
    [self.view addSubview:itemView];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1f target:self selector:@selector(timerFire:) userInfo:@{@"itemView": itemView} repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.timer invalidate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
