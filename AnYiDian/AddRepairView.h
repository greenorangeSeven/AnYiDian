//
//  AddRepairView.h
//  BBK
//
//  Created by Seven on 14-12-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddRepairView : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *faceBg1View;
@property (weak, nonatomic) IBOutlet UILabel *faceBg2View;
@property (weak, nonatomic) IBOutlet UIImageView *faceIv;

@property (weak, nonatomic) IBOutlet UILabel *userInfoLb;
@property (weak, nonatomic) IBOutlet UILabel *mobileNoLb;

@property (weak, nonatomic) IBOutlet UILabel *repairContentPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *repairContentTv;
@property (weak, nonatomic) IBOutlet UILabel *repairTypeNameLb;
@property (weak, nonatomic) IBOutlet UIButton *submitRepairBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *repairCostBtn;

- (IBAction)selectRepairTypeAction:(id)sender;
- (IBAction)telServiceAction:(id)sender;
- (IBAction)submitRepairAction:(id)sender;
- (IBAction)pushRepairCostView:(id)sender;

@end
