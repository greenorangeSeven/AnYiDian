//
//  VolunteerFaceCell.m
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "VolunteerFaceCell.h"

@implementation VolunteerFaceCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化时加载collectionCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"VolunteerFaceCell" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionViewCell类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib {
    //图片圆形处理
    self.faceBg1View.layer.masksToBounds = YES;
    self.faceBg1View.layer.cornerRadius = self.faceBg1View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceBg2View.layer.masksToBounds = YES;
    self.faceBg2View.layer.cornerRadius = self.faceBg2View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceIv.layer.masksToBounds = YES;
    self.faceIv.layer.cornerRadius = self.faceIv.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
}

@end
