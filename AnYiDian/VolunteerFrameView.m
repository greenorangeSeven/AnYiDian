//
//  VolunteerFrameView.m
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "VolunteerFrameView.h"

@interface VolunteerFrameView ()

@end

@implementation VolunteerFrameView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"志愿者";
    
    //下属控件初始化
    self.newsView = [[VolunteerNewsView alloc] init];
    self.newsView.typeId = @"0";
    self.newsView.frameView = self.mainView;
    [self addChildViewController:self.newsView];
    [self.mainView addSubview:self.newsView.view];
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

- (IBAction)item1Action:(id)sender {
    [self.item1Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item3Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    self.newsView.view.hidden = NO;
    self.addVolunteer.view.hidden = YES;
    self.helpView.view.hidden = YES;
}

- (IBAction)item2Action:(id)sender {
    [self.item1Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    [self.item3Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    if (self.addVolunteer == nil) {
        self.addVolunteer = [[AddVolunteerView alloc] init];
        self.addVolunteer.frameView = self.mainView;
        [self addChildViewController:self.addVolunteer];
        [self.mainView addSubview:self.addVolunteer.view];
    }
    self.newsView.view.hidden = YES;
    self.addVolunteer.view.hidden = NO;
    self.helpView.view.hidden = YES;
}

- (IBAction)item3Action:(id)sender {
    [self.item1Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item2Btn setTitleColor:[UIColor colorWithRed:131.0/255 green:132.0/255 blue:133.0/255 alpha:1.0] forState:UIControlStateNormal];
    [self.item3Btn setTitleColor:[Tool getColorForMain] forState:UIControlStateNormal];
    if (self.helpView == nil) {
        self.helpView = [[VolunteerNewsView alloc] init];
        self.helpView.typeId = @"1";
        self.helpView.frameView = self.mainView;
        [self addChildViewController:self.helpView];
        [self.mainView addSubview:self.helpView.view];
    }
    self.newsView.view.hidden = YES;
    self.addVolunteer.view.hidden = YES;
    self.helpView.view.hidden = NO;
}

@end
