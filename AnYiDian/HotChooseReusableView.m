//
//  HotChooseReusableView.m
//  AnYiDian
//
//  Created by Seven on 15/8/14.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "HotChooseReusableView.h"
#import "HotChooseCell.h"
#import "UIImageView+WebCache.h"
#import "CommDetailView.h"

@implementation HotChooseReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化时加载collectionCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"HotChooseReusableView" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionReusableView类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionReusableView class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self initTableData];
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)initTableData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取广告URL
        UserInfo *userInfo = [[UserModel Instance] getUserInfo];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1143917095261700" forKey:@"typeId"];
        [param setValue:userInfo.defaultUserHouse.cellId forKey:@"cellId"];
        [param setValue:@"1" forKey:@"timeCon"];
        NSString *getADDataUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findAdInfoList] params:param];
        
        [[AFOSCClient sharedClient]getPath:getADDataUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           advDatas = [Tool readJsonStrToAdinfoArray:operation.responseString];
                                           NSInteger length = [advDatas count];
                                           
                                           if (length > 0)
                                           {
                                               [self.tableView reloadData];
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           
                                       }
                                   }];
    }
}

#pragma TableView的处理

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 144;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return advDatas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HotChooseCell *cell = [tableView dequeueReusableCellWithIdentifier:HotChooseCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HotChooseCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[HotChooseCell class]]) {
                cell = (HotChooseCell *)o;
                break;
            }
        }
    }
    
    NSUInteger row = [indexPath row];
    ADInfo *ad = [advDatas objectAtIndex:row];
    
    [Tool roundTextView:cell.bgView andBorderWidth:1.0 andCornerRadius:0.0];
    cell.titleLb.text = ad.adName;
    [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:ad.imgUrlFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
//    ADInfo *adv = (ADInfo *)[advDatas objectAtIndex:row];
//    NSString *adDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_adDetail ,adv.adId];
//    CommDetailView *detailView = [[CommDetailView alloc] init];
//    detailView.titleStr = @"详情";
//    detailView.urlStr = adDetailHtm;
//    detailView.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:detailView animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_LifeServicePush object:nil userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"@d", row]  forKey:@"row"]];
}

@end
