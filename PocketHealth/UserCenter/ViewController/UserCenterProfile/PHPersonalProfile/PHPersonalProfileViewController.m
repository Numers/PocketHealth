//
//  PHPersonalProfileViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-12.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPersonalProfileViewController.h"
#import "CalculateViewFrame.h"
#import "Member.h"
#import "PHAppStartManager.h"
#import "PHAccessaryHeadView.h"
#import "PHUpdateRealNameViewController.h"
#import "PHUpdateNickNameViewController.h"
#import "PHHeightViewController.h"
#import "PHWeightViewController.h"
#import "PHSexViewController.h"
#import "PHBindMobileViewController.h"
#import "PHUpdateUserInfoManager.h"
#import "CommonUtil.h"
#import "MBProgressHUD+Add.h"
#import "JSONKit.h"
#import "PHResetPasswordViewController.h"
#import "PHQRCodeViewController.h"
#import "UINavigationController+PHNavigationController.h"

#define TitleLabelFont [UIFont boldSystemFontOfSize:16.f]
#define DetailLabelFont [UIFont systemFontOfSize:15.f]
#define TitleLabelColor [UIColor colorWithRed:26/255.f green:26/255.f blue:26/255.f alpha:1.f]
#define DetailLabelColor [UIColor colorWithRed:148/255.f green:148/255.f blue:148/255.f alpha:1.f]

static NSString *identifyPersonalProfileCell = @"PersonalProfileTableViewCell";
@interface PHPersonalProfileViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHWeightViewDelegate,PHHeightViewDelegate,PHSexViewDelegate>
{
    Member *host;
    PHWeightViewController *phWeightVC;
    PHHeightViewController *phHeightVC;
    PHSexViewController *phSexVC;
}
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation PHPersonalProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [_tableView setBackgroundColor:ViewBackGroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
    host = [[PHAppStartManager defaultManager] userHost];
    [_tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hiddenPickView];
}

-(void)hiddenPickView
{
    if ((phHeightVC != nil) && ([phHeightVC isShow])) {
        [phHeightVC hidden];
    }
    
    if ((phSexVC != nil) && ([phSexVC isShow])) {
        [phSexVC hidden];
    }
    
    if ((phWeightVC != nil) && ([phWeightVC isShow])) {
        [phWeightVC hidden];
    }
}

-(void)navigationControllerSetting
{
    [self.navigationItem setTitle:@"个人资料"];
}

-(void)updateUserSex:(sexCode)sex
{
    [[PHUpdateUserInfoManager defaultManager] updateUserInfoWithParameter:[NSString stringWithFormat:@"%d",sex] WithProperty:@"Usersex" CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            host = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                [[PHAppStartManager defaultManager] setHostMember:host];
                [_tableView reloadData];
            }
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络错误！" InView:self.view];
    }];
}

-(void)updateWeight:(NSInteger)weight
{
    [[PHUpdateUserInfoManager defaultManager] updateUserInfoWithParameter:[NSString stringWithFormat:@"%ld",(long)weight] WithProperty:@"Userweight" CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            host = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                [[PHAppStartManager defaultManager] setHostMember:host];
                [_tableView reloadData];
            }
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络错误！" InView:self.view];
    }];
}

-(void)updateHeight:(NSInteger)height
{
    [[PHUpdateUserInfoManager defaultManager] updateUserInfoWithParameter:[NSString stringWithFormat:@"%ld",(long)height] WithProperty:@"Userheight" CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            host = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                [[PHAppStartManager defaultManager] setHostMember:host];
                [_tableView reloadData];
            }
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络错误！" InView:self.view];
    }];
}

-(void)loginOut
{
    [[PHAppStartManager defaultManager] loginOut];
}

-(void)uploadHeadImage:(UIImage *)image
{
    MBProgressHUD *hud =[MBProgressHUD showMessag:@"" toView:self.view];
    //上传头像
    NSData *imageData = UIImagePNGRepresentation(image);
    [[PHUpdateUserInfoManager defaultManager] updateUserHeadWithImageData:imageData Completion:^(NSURLResponse *response, NSData *responseObject, NSError *error) {
        [hud hide:YES];
        if (!error) {
            NSDictionary *dic = [responseObject objectFromJSONData];
            NSInteger code = [[dic objectForKey:@"Code"] integerValue];
            if (code == 1) {
                NSDictionary *resultDic = [dic objectForKey:@"Result"];
                NSError *error = nil;
                host = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
                if (!error) {
                    [[PHAppStartManager defaultManager] setHostMember:host];
                    [_tableView reloadData];
                }
            }else{
                [CommonUtil HUDShowText:@"上传失败！" InView:self.view];
            }
        }else{
            [CommonUtil HUDShowText:@"网络错误！" InView:self.view];
        }
    }];
}

-(NSMutableAttributedString *)generateAttriuteStringWithStr:(NSString *)str WithColor:(UIColor *)color WithFont:(UIFont *)font
{
    if (str == nil) {
        return nil;
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange range;
    range.location = 0;
    range.length = attrString.length;
    [attrString beginEditing];
    [attrString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:color,NSForegroundColorAttributeName,font,NSFontAttributeName, nil] range:range];
    [attrString endEditing];
    return attrString;
}

#pragma mark - tableview delegate and datasoucre
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger result = 0;
    switch (section) {
        case 0:
            result = 4;
            break;
        case 1:
        {
            if ((host.loginName == nil) || (host.loginName.length == 0)){
                result = 1;
            }else{
                result = 2;
            }
        }
            break;
        case 2:
            result = 3;
            break;
        case 3:
            result = 1;
            break;
        default:
            break;
    }
    return result;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 3) {
        return 20.f;
    }
    return 0.1f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ((host.loginName == nil) || (host.loginName.length == 0)) {
        return 3;
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0) ) {
        return 88.0f;
    }else{
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifyPersonalProfileCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifyPersonalProfileCell];
    }
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"头像" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:nil];
                    PHAccessaryHeadView *headView = [[PHAccessaryHeadView alloc] initWithFrame:CGRectMake(0, 0, 80, 96)];
                    [headView setupWithMember:host];
                    cell.accessoryView = headView;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 1:
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"姓名" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:host.realName WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 2:
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"昵称" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:host.nickName WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 3:
                {
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"二维码名片" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    UIImageView *qrView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"usercenter-QR-code"]];
                    [qrView setFrame:CGRectMake(0, 0, 17.f, 17.f)];
                    cell.accessoryView = qrView;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;

                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    if ((host.loginName == nil) || (host.loginName.length == 0)) {
                        [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"绑定手机号" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                        [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:@"未绑定" WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    }else{
                        [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"修改手机号" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                        cell.detailTextLabel.text = nil;
                    }
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 1:
                    if ((host.loginName == nil) || (host.loginName.length == 0)) {
                        [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"设置密码" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                        cell.detailTextLabel.text = nil;
                    }else{
                        [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"修改密码" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                        cell.detailTextLabel.text = nil;
                    }
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"身高" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:[NSString stringWithFormat:@"%ldcm",(long)host.userHeight] WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    break;
                case 1:
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"体重" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:[NSString stringWithFormat:@"%ldkg",(long)host.userWeight] WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    break;
                case 2:
                {
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"性别" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    NSString *sex = nil;
                    if (host.userSex == sexMan) {
                        sex = @"男";
                    }else if (host.userSex == sexWoman){
                        sex = @"女";
                    }else{
                        sex = @"未设置";
                    }
                    [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:sex WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                }
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                {
                    UITableViewCell *tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    [tableViewCell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"注销" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [tableViewCell.textLabel setTextAlignment:NSTextAlignmentCenter];
                    return tableViewCell;
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return cell;
}
#pragma mark - tableview点击cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:@"上传头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"马上照一张" otherButtonTitles:@"从相册中取一张", nil ];
                    [as setTag:1];
                    [as showInView:self.view];
                }
                    break;
                case 1:
                {
                    PHUpdateRealNameViewController *phUpdateRealNameVC = [[PHUpdateRealNameViewController alloc] init];
                    [self.navigationController pushViewController:phUpdateRealNameVC animated:YES];
                }
                    break;
                case 2:
                {
                    PHUpdateNickNameViewController *phUpdateNickNameVC = [[PHUpdateNickNameViewController alloc] init];
                    [self.navigationController pushViewController:phUpdateNickNameVC animated:YES];
                }
                    break;
                case 3:
                {
                    PHQRCodeViewController *phQRCodeVC = [[PHQRCodeViewController alloc] initWithMember:host WithMemberType:host.userType];
                    [self.navigationController pushViewController:phQRCodeVC animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    PHBindMobileViewController *phBindMobileVC = [[PHBindMobileViewController alloc] init];
                    [self.navigationController pushViewController:phBindMobileVC animated:YES];
                }
                    break;
                case 1:
                {
                    PHResetPasswordViewController *phResetPasswordVC = [[PHResetPasswordViewController alloc] init];
                    [self.navigationController pushViewController:phResetPasswordVC animated:YES];
                }
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                {
                    phHeightVC = [[PHHeightViewController alloc] initWithHeight:host.userHeight];
                    phHeightVC.delegate = self;
                    [phHeightVC showInView:self.view];
                }
                    break;
                case 1:
                {
                    phWeightVC = [[PHWeightViewController alloc] initWithWeight:host.userWeight];
                    phWeightVC.delegate = self;
                    [phWeightVC showInView:self.view];
                }
                    break;
                case 2:
                {
                    phSexVC = [[PHSexViewController alloc] init];
                    phSexVC.delegate = self;
                    [phSexVC showInView:self.view];
                }
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                {
                    UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:@"退出后不会删除任何历史数据,下次登录依然可以使用本账号" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出登录" otherButtonTitles:nil, nil];
                    [as setTag:2];
                    [as showInView:self.view];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark ----------ActionSheet 按钮点击-------------
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"用户点击的是第%ld个按钮",(long)buttonIndex);
    switch (actionSheet.tag) {
        case 1:
        {
            switch (buttonIndex) {
                case 0:
                    //照一张
                {
                    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
                    [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                    [imgPicker setDelegate:self];
                    [imgPicker setAllowsEditing:YES];
                    [self.navigationController presentViewController:imgPicker animated:YES completion:^{
                    }];
                }
                    break;
                case 1:
                    //搞一张
                {
                    UIImagePickerController *imgPicker=[[UIImagePickerController alloc]init];
                    [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                    [imgPicker setDelegate:self];
                    [imgPicker setAllowsEditing:YES];
                    [self presentViewController:imgPicker animated:YES completion:^{
                    }];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (buttonIndex) {
                case 0:
                {
                    [self loginOut];
                }
                    break;
                default:
                    break;
            }

        }
            break;
        default:
            break;
    }
}

#pragma mark ----------图片选择完成-------------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage  * userHeadImage= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        UIImage *viewImage = [CommonUtil croppedImage:userHeadImage];
        [self uploadHeadImage:viewImage];
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma -mark PickViewDelegate
-(void)pickWeight:(NSInteger)weight
{
    [self updateWeight:weight];
}

-(void)pickHeight:(NSInteger)height
{
    [self updateHeight:height];
}

-(void)pickSex:(sexCode)sex
{
    [self updateUserSex:sex];
}
@end