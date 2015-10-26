//
//  MainPageView.h
//  AnYiDian
//
//  Created by Seven on 15/7/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPageView : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *adIv;

@property (weak, nonatomic) IBOutlet UIView *newsHouseView;
@property (weak, nonatomic) IBOutlet UIImageView *newsHouseImg;
@property (weak, nonatomic) IBOutlet UILabel *newsHouseNameLb;
@property (weak, nonatomic) IBOutlet UILabel *newsHouseContentLb;

@property (weak, nonatomic) IBOutlet UIView *ershouHouseView;
@property (weak, nonatomic) IBOutlet UIImageView *oldHouseImg;
@property (weak, nonatomic) IBOutlet UILabel *oldHouseNameLb;
@property (weak, nonatomic) IBOutlet UILabel *oldHouseContentLb;

@property (weak, nonatomic) IBOutlet UIView *lifeQueryView;
@property (weak, nonatomic) IBOutlet UIView *lifeServiceView;
@property (weak, nonatomic) IBOutlet UIView *supermarketView;

- (IBAction)repairAction:(id)sender;
- (IBAction)suitAction:(id)sender;
- (IBAction)committeeNoticeAction:(id)sender;
- (IBAction)payfeeAction:(id)sender;

@end
