//
//  LifeReferView.m
//  BBK
//
//  Created by Seven on 14-12-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "LifeReferView.h"
#import "LifeRefer.h"
#import "LifeReferCell.h"
#import "LifeReferFooterReusableView.h"
#import "CommDetailView.h"
#import "UIImageView+WebCache.h"

@interface LifeReferView ()

@end

@implementation LifeReferView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"生活助手";

    hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[LifeReferCell class] forCellWithReuseIdentifier:LifeReferCellIdentifier];
    [self.collectionView registerClass:[LifeReferFooterReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LifeReferFooter"];
    
    [self findLifeTypeAll];
}

//取数方法
- (void)findLifeTypeAll
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"加载中..." andView:self.view andHUD:hud];
        //生成获取生活查询URL
        NSString *findLifeTypeAllUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findLifeTypeAll] params:nil];
        
        [[AFOSCClient sharedClient]getPath:findLifeTypeAllUrl parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           refers = [Tool readJsonStrToLifeReferArray:operation.responseString];
                                           int n = [refers count] % 4;
                                           if(n > 0)
                                           {
                                               for (int i = 0; i < 4 - n; i++) {
                                                   LifeRefer *r = [[LifeRefer alloc] init];
                                                   r.lifeTypeId = @"-1";
                                                   [refers addObject:r];
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
    return [refers count];
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
    NSInteger row = [indexPath row];
    LifeRefer *refer = [refers objectAtIndex:row];
    if ([refer.lifeTypeId isEqualToString:@"-1"]) {
        cell.referNameLb.text = nil;
        cell.referIv.image = nil;
        return cell;
    }
    cell.referNameLb.text = refer.lifeTypeName;
    
    [cell.referIv sd_setImageWithURL:[NSURL URLWithString:refer.imgUrlFull] placeholderImage:[UIImage imageNamed:@"placeHoder"]];
    
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
    LifeRefer *refer = [refers objectAtIndex:[indexPath row]];
    if (refer != nil) {
        CommDetailView *detailView = [[CommDetailView alloc] init];
        detailView.titleStr = refer.lifeTypeName;
        detailView.urlStr = refer.url;
        [self.navigationController pushViewController:detailView animated:YES];
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
    //清空
    for (LifeRefer *refer in refers) {
        refer.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [refers removeAllObjects];
    refers = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{

}

// 返回headview或footview
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (kind == UICollectionElementKindSectionFooter){
        LifeReferFooterReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"LifeReferFooter" forIndexPath:indexPath];
        reusableview = footerView;
    }
    return reusableview;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
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
