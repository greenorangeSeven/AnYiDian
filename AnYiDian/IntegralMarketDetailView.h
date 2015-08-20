//
//  IntegralMarketDetailView.h
//  AnYiDian
//
//  Created by Seven on 15/8/11.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegralMarketDetailView : UIViewController

@property (copy, nonatomic) NSString *commodityId;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageIv;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;
@property (weak, nonatomic) IBOutlet UILabel *integralLb;
//@property (weak, nonatomic) IBOutlet UILabel *marketPriceLb;
//@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
//@property (weak, nonatomic) IBOutlet UILabel *collectionLb;
@property (weak, nonatomic) IBOutlet UIView *properyView;
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLb;

@property (weak, nonatomic) IBOutlet UIButton *buyNowBtn;
- (IBAction)buyNowAction:(id)sender;

@end
