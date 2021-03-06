//
//  PHGroupInfoEditViewController.m
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHGroupInfoEditViewController.h"
#import "GlobalVar.h"
#import "PHGroupAccessaryHeadView.h"
#import "CalculateViewFrame.h"
#import "PHGroupNameEditViewController.h"
#import "PHTagEditViewController.h"
#import "PHGroupIntroductionEditViewController.h"
#import "Group.h"
#import "SGroupDB.h"
#import "PHGroupHttpRequest.h"
#import "PHUpdateGroupInfoAPI.h"
#import "JSONKit.h"
#import "MBProgressHUD+Add.h"

#import "PHJoinStrategyViewController.h"

#define TitleLabelFont [UIFont boldSystemFontOfSize:16.f]
#define DetailLabelFont [UIFont systemFontOfSize:15.f]
#define TitleLabelColor [UIColor colorWithRed:26/255.f green:26/255.f blue:26/255.f alpha:1.f]
#define DetailLabelColor [UIColor colorWithRed:148/255.f green:148/255.f blue:148/255.f alpha:1.f]

static NSString *identifyGroupInfoEditTableViewCell = @"identifyGroupInfoEditTableViewCell";
@interface PHGroupInfoEditViewController ()<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PHJoinStrategyViewDelegate>
{
    PHJoinStrategyViewController *phJoinStrategyVC;
}
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation PHGroupInfoEditViewController
-(id)initWithGroup:(Group *)editGroup
{
    self = [super init];
    if (self) {
        group = editGroup;
    }
    return self;
}

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
    [_tableView reloadData];
}

-(void)navigationControllerSetting
{
    [self.navigationItem setTitle:@"编辑群资料"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hiddenPickView];
}

-(void)hiddenPickView
{
    if ((phJoinStrategyVC != nil) && ([phJoinStrategyVC isShow])) {
        [phJoinStrategyVC hidden];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableAttributedString *)generateGroupBriefIntroductionAttributeString
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"群简介\n"];
    NSRange range;
    range.location = 0;
    range.length = attrStr.length;
    [attrStr addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TitleLabelColor,NSForegroundColorAttributeName,TitleLabelFont,NSFontAttributeName, nil] range:range];
    
    NSMutableAttributedString *addStr = [[NSMutableAttributedString alloc] initWithString:group.groupBriefIntroduction];
    NSRange range1;
    range1.location = 0;
    range1.length = addStr.length;
    [addStr addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:DetailLabelColor,NSForegroundColorAttributeName,DetailLabelFont,NSFontAttributeName, nil] range:range1];
    [attrStr appendAttributedString:addStr];
    return attrStr;
}

-(NSMutableAttributedString *)generateAttriuteStringWithStr:(NSString *)str WithColor:(UIColor *)color WithFont:(UIFont *)font
{
    if(str == nil)
    {
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

-(void)uploadHeadImage:(UIImage *)image
{
    //上传头像
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *groupImageName = [NSString stringWithFormat:@"%u_%lf_image.png",group.groupId,time];
    [PHGroupHttpRequest uploadMessageFileWithFileName:groupImageName WithUIImage:image WithSendMessage:nil completeHandle:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (!error) {
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSInteger code = [[dic objectForKey:@"Code"] integerValue];
            if (code == 1) {
                 NSString *path = [[dic objectForKey:@"Result"]objectForKey:@"FileName"];
                if (path != nil) {
                    [self updateGroupHeadImageWithPath:path];
                }
            }else{
                [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.navigationController.view];
            }
        }else{
            [CommonUtil HUDShowText:@"网络连接失败!" InView:self.navigationController.view];
        }

    }];
}

-(void)updateGroupHeadImageWithPath:(NSString *)path
{
    MBProgressHUD *hud =[MBProgressHUD showMessag:@"" toView:self.view];
    [[PHUpdateGroupInfoAPI defaultManager] updateGroupInfoWithParameter:path WithProperty:@"Hblogourl" WithGroupId:[NSString stringWithFormat:@"%u",group.groupId] CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            group.groupHeadImage = [NSString stringWithFormat:@"%@%@",ServerBaseURL,path];
            SGroupDB *groupdb = [[SGroupDB alloc] init];
            [groupdb mergeGroup:group];
            [_tableView reloadData];
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.navigationController.view];
        }
        
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [CommonUtil HUDShowText:@"网络连接失败!" InView:self.navigationController.view];
    }];
}

-(void)updateGroupJoinStrategy:(JoinStrategy)strategy
{
    [[PHUpdateGroupInfoAPI defaultManager] updateGroupInfoWithParameter:[NSString stringWithFormat:@"%d",strategy] WithProperty:@"Hbjoingroup" WithGroupId:[NSString stringWithFormat:@"%u",group.groupId] CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            group.joinStrategy = strategy;
            SGroupDB *groupdb = [[SGroupDB alloc] init];
            [groupdb mergeGroup:group];
            [_tableView reloadData];
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.navigationController.view];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络连接失败!" InView:self.navigationController.view];
    }];
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
            return 1;
        }
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
    return 0.1f;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == 0) && (indexPath.row == 0) ) {
        return 88.0f;
    }else if((indexPath.section == 1) && (indexPath.row == 0)){
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }else{
        return 44.f;
    }
    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifyGroupInfoEditTableViewCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifyGroupInfoEditTableViewCell];
    }
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"头像" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:nil];
                    PHGroupAccessaryHeadView *headView = [[PHGroupAccessaryHeadView alloc] initWithFrame:CGRectMake(0, 0, 80, 96)];
                    [headView setupWithGroup:group];
                    cell.accessoryView = headView;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 1:
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"群名称" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:group.groupName WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 2:
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"群标签" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:group.groupTag WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                case 3:
                {
                    [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"加群机制" WithColor:TitleLabelColor WithFont:TitleLabelFont]];
                    if (group.joinStrategy == unNeedValidate) {
                        [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:@"允许任何人关注" WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    }
                    
                    if (group.joinStrategy == needValidate) {
                        [cell.detailTextLabel setAttributedText:[self generateAttriuteStringWithStr:@"需要管理员验证" WithColor:DetailLabelColor WithFont:DetailLabelFont]];
                    }
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
                {
                    NSMutableAttributedString *attStr = [self generateGroupBriefIntroductionAttributeString];
                    CGRect frame = [attStr boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
                    [cell setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, frame.size.height + 20.f)];
                    [cell.textLabel setAttributedText:attStr];
                    cell.textLabel.numberOfLines = 0;
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
                    [as showInView:self.view];
                }
                    break;
                case 1:
                {
                    PHGroupNameEditViewController *phGroupNameEditVC = [[PHGroupNameEditViewController alloc] initWithGroup:group];
                    [self.navigationController pushViewController:phGroupNameEditVC animated:YES];
                }
                    break;
                case 2:
                {
                    PHTagEditViewController *phTagEditVC = [[PHTagEditViewController alloc] initWithGroup:group];
                    [self.navigationController pushViewController:phTagEditVC animated:YES];
                }
                    break;
                case 3:
                {
                    phJoinStrategyVC = [[PHJoinStrategyViewController alloc] initWithJoinStrategy:group.joinStrategy];
                    phJoinStrategyVC.delegate = self;
                    [phJoinStrategyVC showInView:self.view];
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
                    PHGroupIntroductionEditViewController *phGroupIntroductionEditVC = [[PHGroupIntroductionEditViewController alloc] initWithGroup:group];
                    [self.navigationController pushViewController:phGroupIntroductionEditVC animated:YES];
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
    NSLog(@"用户点击的是第%ld个按钮",buttonIndex);
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

#pragma -mark PHJoinStrategyViewDelegate
-(void)selectStrategy:(JoinStrategy)strategy
{
    [self updateGroupJoinStrategy:strategy];
}
@end
