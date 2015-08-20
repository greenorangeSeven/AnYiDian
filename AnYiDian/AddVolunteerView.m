//
//  AddVolunteerView.m
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "AddVolunteerView.h"
#import "VolunteerFaceCell.h"
#import "RegUserInfo.h"
#import "UIImageView+WebCache.h"
#import "AddVolunteerHeaderView.h"

@interface AddVolunteerView ()

@end

@implementation AddVolunteerView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    
    
    CGRect tableFrame = self.collectionView.frame;
    tableFrame.size.height = self.frameView.frame.size.height;
    tableFrame.size.width = self.frameView.frame.size.width;
    self.collectionView.frame = tableFrame;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[VolunteerFaceCell class] forCellWithReuseIdentifier:VolunteerFaceCellIdentifier];
    [self.collectionView registerClass:[AddVolunteerHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AddVolunteerHeader"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshed:) name:Notification_RefreshAddVolunteerView object:nil];
    
    [self findNewsVolunteer];
}

- (void)refreshed:(NSNotification *)notification
{
    [self findNewsVolunteer];
}

//取数方法
- (void)findNewsVolunteer
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        //生成获取志愿者
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];

        [param setValue:@"1" forKey:@"pageNumbers"];
        [param setValue:@"6" forKey:@"countPerPages"];
        NSString *findLifeTypeAllUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findVolunteerByPage] params:param];
        
        [[AFOSCClient sharedClient]getPath:findLifeTypeAllUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                           NSError *error;
                                           NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                           
                                           NSDictionary *datas = [json objectForKey:@"data"];
                                           NSArray *array = [datas objectForKey:@"resultsList"];
                                           
                                           volunteers = [NSMutableArray arrayWithArray:[Tool readJsonToObjArray:array andObjClass:[RegUserInfo class]]];
                                           [self.collectionView reloadData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           if (hud != nil) {
                                               [hud hide:YES];
                                           }
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool showCustomHUD:@"网络不给力" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
                                       }
                                   }];
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [volunteers count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VolunteerFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VolunteerFaceCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"VolunteerFaceCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[VolunteerFaceCell class]]) {
                cell = (VolunteerFaceCell *)o;
                break;
            }
        }
    }
    NSInteger row = [indexPath row];
    RegUserInfo *user = [volunteers objectAtIndex:row];
    cell.userNameLb.text = user.regUserName;
    [cell.faceIv sd_setImageWithURL:[NSURL URLWithString:user.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ;
    if(IS_IPHONE_6)
    {
        return CGSizeMake(110, 137);
    }
    else
    {
        return CGSizeMake(106, 137);
    }
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
//    LifeRefer *refer = [refers objectAtIndex:[indexPath row]];
//    if (refer != nil) {
//        CommDetailView *detailView = [[CommDetailView alloc] init];
//        detailView.titleStr = refer.lifeTypeName;
//        detailView.urlStr = refer.url;
//        [self.navigationController pushViewController:detailView animated:YES];
//    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 返回headview或footview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionHeader){
        AddVolunteerHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"AddVolunteerHeader" forIndexPath:indexPath];
        reusableview = headerView;
    }
    
    return reusableview;
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

@end
