//
//  PropertyNewsView.h
//  AnYiDian
//
//  Created by Seven on 15/7/17.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PropertyNewsView : UIViewController<UITableViewDataSource, UITableViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
{
    NSMutableArray *newsData;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
}

@property (copy, nonatomic) NSString *typeId;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void)reload:(BOOL)noRefresh;

//清空
- (void)clear;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
