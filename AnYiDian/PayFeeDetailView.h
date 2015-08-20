//
//  PayFeeDetailView.h
//  AnYiDian
//
//  Created by Seven on 15/8/13.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bill.h"

@interface PayFeeDetailView : UIViewController

@property (weak, nonatomic) Bill *bill;
@property (weak, nonatomic) IBOutlet UILabel *monthLb;
@property (weak, nonatomic) IBOutlet UILabel *moneyLb;
@property (weak, nonatomic) IBOutlet UILabel *totalLb;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
- (IBAction)doPayAction:(id)sender;

@end
