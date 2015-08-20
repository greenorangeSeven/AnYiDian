//
//  BuildingPageView.h
//  AnYiDian
//
//  Created by Seven on 15/7/14.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuildingPageView : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *marketingView;
@property (weak, nonatomic) IBOutlet UIView *preferentialView;

@end
