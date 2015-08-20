//
//  PreferentialView.h
//  AnYiDian
//
//  Created by Seven on 15/8/5.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferentialView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) IBOutlet UICollectionView *preferentialCollection;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
