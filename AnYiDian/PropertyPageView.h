//
//  PropertyPageView.h
//  AnYiDian
//
//  Created by Seven on 15/7/14.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PropertyPageView : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)hydtAction:(id)sender;
- (IBAction)zcfgAction:(id)sender;
- (IBAction)zbxxAction:(id)sender;
- (IBAction)tzggAction:(id)sender;

@end
