//
//  AddVolunteerHeaderView.m
//  AnYiDian
//
//  Created by Seven on 15/7/23.
//  Copyright (c) 2015年 Seven. All rights reserved.
//

#import "AddVolunteerHeaderView.h"
#import "UIImageView+WebCache.h"

@implementation AddVolunteerHeaderView
{
    int isVolunteer;
    UserInfo *userInfo;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 初始化时加载collectionCell.xib文件
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"AddVolunteerHeaderView" owner:self options:nil];
        
        // 如果路径不存在，return nil
        if (arrayOfViews.count < 1)
        {
            return nil;
        }
        // 如果xib中view不属于UICollectionReusableView类，return nil
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionReusableView class]])
        {
            return nil;
        }
        // 加载nib
        self = [arrayOfViews objectAtIndex:0];
    }
    [self initView];
    return self;
}

- (void)awakeFromNib {
    
}

- (void)initView
{
    userInfo = [[UserModel Instance] getUserInfo];
    
    [self.faceIv sd_setImageWithURL:[NSURL URLWithString:userInfo.photoFull] placeholderImage:[UIImage imageNamed:@"default_head.png"]];
    
    self.mobileNoLb.text = [NSString stringWithFormat:@"手机号码：%@", userInfo.mobileNo];
    self.userInfoLb.text = [NSString stringWithFormat:@"%@%@%@    %@", userInfo.defaultUserHouse.cellName, userInfo.defaultUserHouse.buildingName, userInfo.defaultUserHouse.numberName, userInfo.regUserName];
    //图片圆形处理
    self.faceBg1View.layer.masksToBounds = YES;
    self.faceBg1View.layer.cornerRadius = self.faceBg1View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceBg2View.layer.masksToBounds = YES;
    self.faceBg2View.layer.cornerRadius = self.faceBg2View.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    self.faceIv.layer.masksToBounds = YES;
    self.faceIv.layer.cornerRadius = self.faceIv.frame.size.height / 2;    //最重要的是这个地方要设成imgview高的一半
    
    [self.addVolunteerBtn.layer setCornerRadius:5.0f];
    [self findRegUserInfoByUserId];
}

- (void)findRegUserInfoByUserId
{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"userId"];
    
    NSString *findRegUserInfoUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_findRegUserInfoByUserId] params:param];
    [[AFOSCClient sharedClient] getPath:findRegUserInfoUrl parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                                        
                                    }
                                    else
                                    {
                                        isVolunteer = [[[json objectForKey:@"data"] objectForKey:@"isVolunteer"] intValue];
                                        if (isVolunteer == 1) {
                                            [self.addVolunteerBtn setTitle:@"退出志愿者" forState:UIControlStateNormal];
                                        }
                                        else
                                        {
                                            [self.addVolunteerBtn setTitle:@"参加志愿者" forState:UIControlStateNormal];
                                        }
                                    }
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"列表获取出错");
                                    if ([UserModel Instance].isNetworkRunning == NO) {
                                        return;
                                    }
                                }];
}

- (IBAction)addVolunteerAction:(id)sender {
    self.addVolunteerBtn.enabled = NO;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:userInfo.regUserId forKey:@"userId"];
    NSString *changeVolunteerStateUrl = [Tool serializeURL:[NSString stringWithFormat:@"%@%@", api_base_url, api_changeVolunteerState] params:param];
    [[AFOSCClient sharedClient]getPath:changeVolunteerStateUrl parameters:Nil
                               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                   @try {
                                       NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
                                       NSError *error;
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                       
                                       NSString *state = [[json objectForKey:@"header"] objectForKey:@"state"];
                                       
                                       if ([state isEqualToString:@"0000"] == YES)
                                       {
                                           if (isVolunteer == 1) {
                                               isVolunteer = 0;
                                           }
                                           else
                                           {
                                               isVolunteer = 1;
                                           }
                                           if (isVolunteer == 1) {
                                               [self.addVolunteerBtn setTitle:@"退出志愿者" forState:UIControlStateNormal];
                                           }
                                           else
                                           {
                                               [self.addVolunteerBtn setTitle:@"参加志愿者" forState:UIControlStateNormal];
                                           }
                                           
                                       }
                                       self.addVolunteerBtn.enabled = YES;
                                       [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshAddVolunteerView object:nil];
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
                                   
                               }];
}
@end
