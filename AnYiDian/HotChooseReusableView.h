//
//  HotChooseReusableView.h
//  AnYiDian
//
//  Created by Seven on 15/8/14.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotChooseReusableView : UICollectionReusableView<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *advDatas;
}

@property (copy, nonatomic)  UINavigationController *navigationController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
