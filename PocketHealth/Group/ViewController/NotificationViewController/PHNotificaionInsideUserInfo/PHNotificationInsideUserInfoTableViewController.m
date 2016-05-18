//
//  PHNotificationInsideUserInfoTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/20.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHNotificationInsideUserInfoTableViewController.h"

#import "PHGroupPersonalInfoCellHeaderViewController.h"

#import "UINavigationController+PHNavigationController.h"
//自定义按钮
#import "PHBlueButton.h"
#import "MBProgressHUD.h"

static NSString * identifierNotificaionDetailUserCell = @"identifierNotificaionDetailUserCell";
@interface PHNotificationInsideUserInfoTableViewController ()
{
    PHGroupPersonalInfoCellHeaderViewController * phGPHeadViewVC;
}
@end

@implementation PHNotificationInsideUserInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBar.hidden = YES;
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController setTranslucentView];
    
    phGPHeadViewVC =[[PHGroupPersonalInfoCellHeaderViewController alloc]initWithMemberId:_notifiMessage.memberId];
    self.tableView.tableHeaderView = phGPHeadViewVC.view;
    
    [self createTwoBtnAddTableViewFootView];
    //下方添加2个按钮
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setOtherViewNavigation];
    //    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    self.navigationController.navigationBar.hidden = NO;
//    [self.navigationController.navigationBar setTranslucent:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - createTwoBtnAddTableViewFootView
-(void)createTwoBtnAddTableViewFootView{
    UIView * bottomBtnView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 65)];
    PHBlueButton * blueBtnLeft = [[PHBlueButton alloc]initWithFrame:CGRectMake(kBtnLeftMargin, 0, kBottomBtnWidthWithTWO, 44)];
    blueBtnLeft.backgroundColor = [UIColor paperColorBlueA400];
    [blueBtnLeft addTarget:self action:@selector(agreeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [blueBtnLeft setTitle:@"同意申请" forState:UIControlStateNormal];
    
    PHBlueButton * blueBtnRight = [[PHBlueButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2+kBtnLeftMargin, 0, kBottomBtnWidthWithTWO, 44)];
    blueBtnRight.backgroundColor = [UIColor paperColorBlueA400];
    [blueBtnRight addTarget:self action:@selector(cancalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [blueBtnRight setTitle:@"取   消" forState:UIControlStateNormal];
    
    [bottomBtnView addSubview:blueBtnLeft];
    [bottomBtnView addSubview:blueBtnRight];
    
    self.tableView.tableFooterView = bottomBtnView;
}
#pragma mark -  按钮委托
-(void)agreeBtnClick:(id)sender{
    if (self.notifiMessage.state == NotificationMessageStateAgree) {
        //如果已经同意过了 那么就弹出提示表示已同意
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"你已同意过了";
        hud.margin = 10.f;hud.yOffset = 150.f;
        hud.removeFromSuperViewOnHide = YES;
        
        [hud hide:YES afterDelay:2];
        
    }else{
        //否则，加好友
        if ([self.delegate respondsToSelector:@selector(agreeBtnClickReback:)]) {
            [self.delegate agreeBtnClickReback:self.notifiMessage];
        }
    }
    
}
-(void)cancalBtnClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierNotificaionDetailUserCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierNotificaionDetailUserCell];
    }
    

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end