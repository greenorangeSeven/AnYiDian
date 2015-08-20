//
//  ErShouFangFrameView.m
//  AnYiDian
//
//  Created by Seven on 15/8/4.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "ErShouFangFrameView.h"
#import "PublishTradeView.h"

@interface ErShouFangFrameView ()
{
    NSString *typeId;
}

@end

@implementation ErShouFangFrameView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"二手房";
    
    typeId = @"1";
    
    UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 21, 22)];
    [rBtn addTarget:self action:@selector(addESFAction:) forControlEvents:UIControlEventTouchUpInside];
    [rBtn setImage:[UIImage imageNamed:@"addESF"] forState:UIControlStateNormal];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
    self.navigationItem.rightBarButtonItem = rightBtn;
    
    //下属控件初始化
    self.chushouView = [[OldHouseView alloc] init];
    self.chushouView.typeId = @"1";
    self.chushouView.frameView = self.mainView;
    [self addChildViewController:self.chushouView];
    [self.mainView addSubview:self.chushouView.view];
}

- (void)addESFAction:(id)sender
{
    PublishTradeView *publishView = [[PublishTradeView alloc] init];
    if ([typeId isEqualToString:@"1"]) {
        publishView.title = @"二手房出售发布";
    }
    else if ([typeId isEqualToString:@"2"])
    {
        publishView.title = @"房屋租赁发布";
    }
    publishView.typeId = typeId;
    publishView.parentView = self.view;
    [self.navigationController pushViewController:publishView animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

- (IBAction)item1Action:(id)sender {
    typeId = @"1";
    [self.item1Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    self.chushouView.view.hidden = NO;
    self.chuzuView.view.hidden = YES;
}

- (IBAction)item2Action:(id)sender {
    typeId = @"2";
    [self.item1Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    if (self.chuzuView == nil) {
        self.chuzuView = [[OldHouseView alloc] init];
        self.chuzuView.typeId = @"2";
        self.chuzuView.frameView = self.mainView;
        [self addChildViewController:self.chuzuView];
        [self.mainView addSubview:self.chuzuView.view];
    }
    self.chushouView.view.hidden = YES;
    self.chuzuView.view.hidden = NO;
}

@end
