//
//  IntegralMarketView.h
//  AnYiDian
//
//  Created by Seven on 15/8/11.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntegralMarketView : UIViewController<EGORefreshTableHeaderDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *commoditys;
    
    //下拉刷新
    BOOL _reloading;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL isLoading;
    BOOL isLoadOver;
    int allCount;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

//下拉刷新
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
