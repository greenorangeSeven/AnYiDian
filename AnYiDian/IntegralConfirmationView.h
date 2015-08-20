//
//  IntegralConfirmationView.h
//  AnYiDian
//
//  Created by Seven on 15/8/12.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegralConfirmationView : UIViewController<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (copy, nonatomic) NSString *integral;
@property (copy, nonatomic) NSMutableArray *commodityItems;
@property bool fromShopCar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *totalLb;

@property (weak, nonatomic) IBOutlet UITextField *recipientsTf;
@property (weak, nonatomic) IBOutlet UITextField *telphoneTf;
@property (weak, nonatomic) IBOutlet UITextView *addressTv;
@property (weak, nonatomic) IBOutlet UITextView *remarkTv;
- (IBAction)doOrder:(id)sender;

@end
