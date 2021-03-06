//
//  CircleOfFriendsFullCell.m
//  BBK
//
//  Created by Seven on 14-12-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "CircleOfFriendsFullCell.h"
#import "CircleOfFriendsImgCell.h"
#import "CircleOfFriendsReplyCell.h"
#import "Topic.h"
#import "UIImageView+WebCache.h"

@implementation CircleOfFriendsFullCell

- (void)awakeFromNib
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[CircleOfFriendsImgCell class] forCellWithReuseIdentifier:CircleOfFriendsImgCellIdentifier];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    //    设置无分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadCircleOfFriendsImage:(TopicFull *)topic
{
    imageList = topic.imgUrlList;
    [self.collectionView reloadData];
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [imageList count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CircleOfFriendsImgCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CircleOfFriendsImgCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CircleOfFriendsImgCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[CircleOfFriendsImgCell class]]) {
                cell = (CircleOfFriendsImgCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    
    NSString *imageUrl = [imageList objectAtIndex:row];
    [cell.imageIv setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loadpic.png"]];
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 60);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 0, 0, 5);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.photos count] == 0) {
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        for (NSString *d in imageList) {
            MWPhoto * photo = [MWPhoto photoWithURL:[NSURL URLWithString:d]];
            [photos addObject:photo];
        }
        self.photos = photos;
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = NO;//左右分页切换,默认否
    browser.displaySelectionButtons = NO;//是否显示选择按钮在图片上,默认否
    browser.alwaysShowControls = YES;//控制条件控件 是否显示,默认否
    browser.zoomPhotosToFill = NO;//是否全屏,默认是
    //    browser.wantsFullScreenLayout = YES;//是否全屏
    [browser setCurrentPhotoIndex:[indexPath row]];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController pushViewController:browser animated:YES];
}

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)loadCircleOfFriendsReply:(TopicFull *)topic
{
    replyList = topic.replyList;
    [self.tableView reloadData];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return replyList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicReply *record = [replyList objectAtIndex:[indexPath row]];
    return record.contentHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CircleOfFriendsReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:CircleOfFriendsReplyCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"CircleOfFriendsReplyCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[CircleOfFriendsReplyCell class]]) {
                cell = (CircleOfFriendsReplyCell *)o;
                break;
            }
        }
    }
    int row = [indexPath row];
    TopicReply *record = [replyList objectAtIndex:row];
    cell.replyContentLb.attributedText = record.replyContentAttr;
    
    CGRect replyFrame = cell.replyContentLb.frame;
    replyFrame.size.height = record.contentHeight;
    cell.replyContentLb.frame = replyFrame;

    return cell;
}

- (IBAction)deteleAction:(id)sender {
}

- (IBAction)heartAction:(id)sender {
}

- (IBAction)replyAction:(id)sender {
}
@end