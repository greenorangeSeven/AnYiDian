//
//  ConvenienceTypeView.m
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ConvenienceTypeView.h"
#import "LifeReferCell.h"
#import "ConvenienceTableView.h"
#import "UIImageView+WebCache.h"
#import "HotChooseReusableView.h"
#import "CommDetailView.h"

@interface ConvenienceTypeView ()
{
    NSMutableArray *advDatas;
}

@end

@implementation ConvenienceTypeView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"本地生活圈";
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[LifeReferCell class] forCellWithReuseIdentifier:LifeReferCellIdentifier];
    [self.collectionView registerClass:[HotChooseReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HotChooseFooter"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lifeServicePush:) name:Notification_LifeServicePush object:nil];
    
    [self initFooterHeight];
    
    [self findShopTypeAll];
}

- (void)lifeServicePush:(NSNotification *)notic
{
    NSInteger row = [[notic.userInfo objectForKey:@"row"] integerValue];
    ADInfo *adv = (ADInfo *)[advDatas objectAtIndex:row];
    NSString *adDetailHtm = [NSString stringWithFormat:@"%@%@%@", api_base_url, htm_adDetail ,adv.adId];
    CommDetailView *detailView = [[CommDetailView alloc] init];
    detailView.titleStr = @"详情";
    detailView.urlStr = adDetailHtm;
    detailView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailView animated:YES];
}

- (void)initFooterHeight
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
                                           
                                           //代码控制header和footer的显示
                                           UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
                                           CGFloat width = [UIScreen mainScreen].bounds.size.width;
                                           collectionViewLayout.footerReferenceSize = CGSizeMake(width/2, length * 144 + 37);
                                           
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

//取数方法
- (void)findShopTypeAll
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        //生成获取便民服务类型URL
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:@"1" forKey:@"classType"];
        NSString *findShopTypeAllUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findShopType] params:param];
        
        [[AFOSCClient sharedClient]getPath:findShopTypeAllUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           types = [Tool readJsonStrToShopTypeArray:operation.responseString];
                                           int n = [types count] % 4;
                                           if(n > 0)
                                           {
                                               for (int i = 0; i < 4 - n; i++) {
                                                   ShopType *r = [[ShopType alloc] init];
                                                   r.shopTypeId = @"-1";
                                                   [types addObject:r];
                                               }
                                           }
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
    return [types count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LifeReferCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:LifeReferCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"LifeReferCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[LifeReferCell class]]) {
                cell = (LifeReferCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    ShopType *type = [types objectAtIndex:row];
    if ([type.shopTypeId isEqualToString:@"-1"]) {
        cell.referNameLb.text = nil;
        cell.referIv.image = nil;
        return cell;
    }
    cell.referNameLb.text = type.shopTypeName;
    [cell.referIv sd_setImageWithURL:[NSURL URLWithString:type.imgUrlFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];

    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(IS_IPHONE_6)
    {
        return CGSizeMake(93, 100);
    }
    else
    {
        return CGSizeMake(79, 90);
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
    ShopType *shopType = [types objectAtIndex:[indexPath row]];
    if (shopType != nil) {
        if ([shopType.shopTypeId isEqualToString:@"-1"]) {
            return;
        }
        ConvenienceTableView *shopTableView = [[ConvenienceTableView alloc] init];
        shopTableView.type = shopType;
        [self.navigationController pushViewController:shopTableView animated:YES];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [types removeAllObjects];
    types = nil;
    _iconCache = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
}

// 返回headview或footview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionFooter){
        HotChooseReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HotChooseFooter" forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
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
