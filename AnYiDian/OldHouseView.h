//
//  OldHouseView.h
//  AnYiDian
//
//  Created by Seven on 15/8/4.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdView.h"

@interface OldHouseView : UIViewController<UITableViewDataSource, UITableViewDelegate,EGORefreshTableHeaderDelegate,MBProgressHUDDelegate>
{
    AdView *adView;
    NSMutableArray *houseData;
    NSMutableArray *topHouseData;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    UIWebView *phoneWebView;
}

@property (copy, nonatomic) NSString *typeId;
@property (weak, nonatomic) UIView *frameView;
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
