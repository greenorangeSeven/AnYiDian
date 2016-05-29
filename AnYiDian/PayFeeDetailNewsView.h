//
//  PayFeeDetailNewsView.h
//  AnYiDian
//
//  Created by Seven on 16/4/5.
//  Copyright © 2016年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayFeeDetailNewsView : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (copy, nonatomic) NSArray *bills;
@property double totalFee;
@property (weak, nonatomic) IBOutlet UILabel *totalLb;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
- (IBAction)doPayAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
