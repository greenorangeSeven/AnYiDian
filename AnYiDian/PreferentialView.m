//
//  PreferentialView.m
//  AnYiDian
//
//  Created by Seven on 15/8/5.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "PreferentialView.h"
#import "Activity.h"
#import "PreferentialCell.h"
#import "UIImageView+WebCache.h"
#import "PreferentialDetailView.h"

@interface PreferentialView ()
{
    UserInfo *userInfo;
    NSMutableArray *activities;
}

@end

@implementation PreferentialView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"优惠政策";
    
    userInfo = [[UserModel Instance] getUserInfo];
    
    self.preferentialCollection.delegate = self;
    self.preferentialCollection.dataSource = self;
    
    self.preferentialCollection.backgroundColor = [Tool getBackgroundColor];
    
    [self.preferentialCollection registerClass:[PreferentialCell class] forCellWithReuseIdentifier:PreferentialCellIdentifier];
    
    [self getActivityList];
}

//取数方法
- (void)getActivityList
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        //生成获取列表URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:userInfo.regUserId forKey:@"userId"];
        NSString *getActivityListUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findPreferentialPolicyOnTime] params:param];
        [[AFOSCClient sharedClient]getPath:getActivityListUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           activities = [Tool readJsonStrToActivityArray:operation.responseString];
                                           self.pageControl.numberOfPages = [activities count];
                                           [self.preferentialCollection reloadData];
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
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [activities count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int indexRow = [indexPath row];
    Activity *activity = [activities objectAtIndex:indexRow];
    self.pageControl.currentPage = indexRow;
    
    PreferentialCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PreferentialCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PreferentialCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[PreferentialCell class]]) {
                cell = (PreferentialCell *)o;
                break;
            }
        }
    }
    
    [Tool roundView:cell.bg andCornerRadius:5.0f];
    
    [cell.praiseBtn setTitle:[NSString stringWithFormat:@"  赞(%d)", activity.heartCountNew] forState:UIControlStateNormal];
    [cell.praiseBtn addTarget:self action:@selector(praiseAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.praiseBtn.tag = indexRow;
    
    if ([activity.isJoin isEqualToString:@"1"]) {
        [cell.attendBtn setTitle:@"  已参与" forState:UIControlStateNormal];
    }
    else
    {
        [cell.attendBtn setTitle:@"  我要参与" forState:UIControlStateNormal];
    }
    [cell.attendBtn addTarget:self action:@selector(attendAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.attendBtn.tag = indexRow;
    
    [cell.checkDetailBtn addTarget:self action:@selector(checkDetailAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.checkDetailBtn.tag = indexRow;
    
    cell.titleLb.text = activity.activityName;
    cell.dateLb.text = [NSString stringWithFormat:@"活动时间：%@-%@", activity.starttime, activity.endtime];
    cell.contentLb.text = [Tool flattenHTML:activity.content];
    cell.telephoneLb.text = [NSString stringWithFormat:@"咨询电话：%@", activity.phone];
    cell.qqLb.text = [NSString stringWithFormat:@"咨询QQ：%@", activity.qq];
    [cell.imageIv sd_setImageWithURL:[NSURL URLWithString:activity.imgUrlFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    return cell;
    
}

- (void)praiseAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;

    if (tap) {
        Activity *activity = [activities objectAtIndex:tap.tag];
        if (activity)
        {
            tap.enabled = NO;
            //如果有网络连接
            if ([UserModel Instance].isNetworkRunning) {
                //查询当前有效的活动列表
                UserInfo *userInfo = [[UserModel Instance] getUserInfo];
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setValue:activity.activityId forKey:@"activityId"];
                [param setValue:userInfo.regUserId forKey:@"regUserId"];
                NSString *praiseActivityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCancelInYhEstateHeart] params:param];
                [[AFOSCClient sharedClient]getPath:praiseActivityUrl parameters:Nil
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               @try {
                                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                                   NSError *error;
                                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

                                                   NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                                   NSString *msg = [[json objectForKey:@"header"] objectForKey:@"msg"];
                                                   if ([state isEqualToString:@"0000"] == YES) {
                                                       if([activity.isHeart isEqualToString:@"0"])
                                                       {
                                                           activity.isHeart = @"1";
                                                           [Tool showCustomHUD:@"点赞成功" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                                           activity.heartCountNew += 1;
                                                       }
                                                       else if ([activity.isHeart isEqualToString:@"1"])
                                                       {
                                                           activity.isHeart = @"0";
                                                           [Tool showCustomHUD:@"已取消点赞" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                                           activity.heartCountNew -= 1;
                                                       }
                                                       
                                                       [self.preferentialCollection reloadData];
                                                   }
                                                   tap.enabled = YES;
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
                                                   [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                               }
                                           }];
            }
        }
    }
}

- (void)attendAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        Activity *activity = [activities objectAtIndex:tap.tag];
        if (activity)
        {
            tap.enabled = NO;
            //如果有网络连接
            if ([UserModel Instance].isNetworkRunning) {
                //查询当前有效的活动列表
                UserInfo *userInfo = [[UserModel Instance] getUserInfo];

                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setValue:activity.activityId forKey:@"activityId"];
                [param setValue:userInfo.regUserId forKey:@"regUserId"];
                NSString *addCancelInActivityUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_addCancelInPreferentialPolicy] params:param];
                [[AFOSCClient sharedClient]getPath:addCancelInActivityUrl parameters:Nil
                                           success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                               @try {
                                                   NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                                   NSError *error;
                                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

                                                   NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                                   if ([state isEqualToString:@"0000"] == NO) {
                                                       UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                                                                    message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                                                                   delegate:nil
                                                                                          cancelButtonTitle:@"确定"
                                                                                          otherButtonTitles:nil];
                                                       [av show];
                                                       //                                                       return;
                                                   }
                                                   else
                                                   {
                                                       NSString *hudStr = @"";
                                                       if([activity.isJoin isEqualToString:@"1"] == YES)
                                                       {
                                                           activity.isJoin = @"0";
                                                           hudStr = @"取消参与";
                                                       }
                                                       else
                                                       {
                                                           activity.isJoin = @"1";
                                                           hudStr = @"已参与";
                                                       }
                                                       [Tool showCustomHUD:hudStr andView:self.view andImage:@"37x-Failure.png" andAfterDelay:2];
                                                       [self.preferentialCollection reloadData];
                                                   }
                                                   tap.enabled = YES;
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
                                                   [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                               }
                                           }];
            }
        }
    }
}

- (void)checkDetailAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        Activity *activity = [activities objectAtIndex:tap.tag];
        if (activity)
        {
            PreferentialDetailView *detailView = [[PreferentialDetailView alloc] init];
            detailView.activity = activity;
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Activity *activity = [activities objectAtIndex:[indexPath row]];
    if (activity)
    {
        
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

@end
