//
//  PayFeeFrameView.h
//  AnYiDian
//
//  Created by Seven on 15/8/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayFeeTableView.h"

@interface PayFeeFrameView : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *item1Btn;
@property (weak, nonatomic) IBOutlet UIButton *item2Btn;
@property (weak, nonatomic) IBOutlet UIButton *item3Btn;
@property (weak, nonatomic) IBOutlet UIView *mainView;

- (IBAction)item1Action:(id)sender;
- (IBAction)item2Action:(id)sender;
- (IBAction)item3Action:(id)sender;

@property (strong, nonatomic) PayFeeTableView *wuyeFeeView;
@property (strong, nonatomic) PayFeeTableView *dianFeeView;
@property (strong, nonatomic) PayFeeTableView *tingcheFeeView;

@end
