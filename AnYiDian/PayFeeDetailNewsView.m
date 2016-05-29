//
//  PayFeeDetailNewsView.m
//  AnYiDian
//
//  Created by Seven on 16/4/5.
//  Copyright © 2016年 Seven. All rights reserved.
//

#import "PayFeeDetailNewsView.h"
#import "PayFeeDetailCell.h"
#import <AlipaySDK/AlipaySDK.h>

@interface PayFeeDetailNewsView ()
{
    NSString *billIdsStr;
}

@end

@implementation PayFeeDetailNewsView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"缴费清单";
    
    self.totalLb.text = [NSString stringWithFormat:@"%0.2f元", self.totalFee];
    
    [self.payBtn.layer setCornerRadius:5.0f];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [[UIView alloc] init];
    NSMutableArray *billIds = [[NSMutableArray alloc] init];
    for (Bill *b in self.bills) {
        [billIds addObject:b.detailsId];
    }
    billIdsStr = [billIds componentsJoinedByString:@"-"];
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bills.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    
    PayFeeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:PayFeeDetailCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"PayFeeDetailCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[PayFeeDetailCell class]]) {
                cell = (PayFeeDetailCell *)o;
                break;
            }
        }
    }
    Bill *bill = [self.bills objectAtIndex:row];
    NSString *moneyStr = @"";
    if (bill.typeId == 0) {
        moneyStr = [NSString stringWithFormat:@"%@物业费", bill.monthStr];
    }
    else if (bill.typeId == 1)
    {
        moneyStr = [NSString stringWithFormat:@"%@车辆秩序维护费", bill.monthStr];
    }
    
    cell.titleLb.text = moneyStr;
    cell.feeLb.text = [NSString stringWithFormat:@"￥%0.2f元", bill.totalMoney];
    
    return cell;
    
    
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

- (IBAction)doPayAction:(id)sender {
    //生成支付宝订单URL
    NSString *createOrderUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_createAlipayParams];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:createOrderUrl]];
    [request setUseCookiePersistence:NO];
    [request setTimeOutSeconds:30];
    [request setPostValue:billIdsStr forKey:@"billDetailsId"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestCreate:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在支付..." andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud)
    {
        [request.hud hide:NO];
    }
    [Tool showCustomHUD:@"网络连接超时" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
}

- (void)requestCreate:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSString *state = [json objectForKey:@"state"];
    if ([state isEqualToString:@"0000"] == NO) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:[[json objectForKey:@"header"] objectForKey:@"msg"]
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        NSString *orderStr = [json objectForKey:@"msg"];
        [[AlipaySDK defaultService] payOrder:orderStr fromScheme:@"AnYiDianAlipay" callback:^(NSDictionary *resultDic)
         {
             NSString *resultState = resultDic[@"resultStatus"];
             if([resultState isEqualToString:ORDER_PAY_OK])
             {
                 [self updatePayedTable];
             }
         }];
    }
}

#pragma mark 刷新列表(当程序支付时在后台被kill掉时供appdelegate调用)
- (void)updatePayedTable
{
    [Tool showCustomHUD:@"支付成功" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:2];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_RefreshPayFeeTableView object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
