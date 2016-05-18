//
//  PHOneKeyFindDocListViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/3/9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHOneKeyFindDocListViewController.h"
#import "PHVideoChatManager.h"
#import "PHFindDoctorsManager.h"
#import "PHAppStartManager.h"
#import "XGPSocketAVideoHelper.h"

#import "PHFindDoctorListTableViewCell.h"

#import "Room.h"
#import "Doctor.h"
#import "CommonUtil.h"
#import "CalculateViewFrame.h"
#import "UINavigationController+PHNavigationController.h"
#import "ClientHelper.h"

#import "PHAddDetailMemberFkViewController.h"

//#import "PHBackViewTopToolBar.h"

static NSString *cellIdentify = @"FindDoctorListTableViewCell";
@interface PHOneKeyFindDocListViewController ()<UITableViewDelegate,UITableViewDataSource,PHFindDoctorTableViewCellDelegate>
{
    NSMutableArray *doctorList;
    UIActivityIndicatorView *activityView;
}
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation PHOneKeyFindDocListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:ViewBackGroundColor];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setOpaque:NO];
    [activityView setCenter:CGPointMake(_tableView.frame.size.width / 2, _tableView.frame.size.height / 2)];
    [_tableView addSubview:activityView];

    
    [_tableView registerNib:[UINib nibWithNibName:@"PHFindDoctorListTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentify];
    doctorList = [[NSMutableArray alloc] init];
    [self requestDoctorList];
    

//    PHBackViewTopToolBar *bottomToolBar = [[PHBackViewTopToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 80.0f)];
//    [[[UIApplication sharedApplication] keyWindow] addSubview:bottomToolBar];
//    [bottomToolBar show];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerAVRoomSucceedNotify:) name:@"sendToVCSuccueedRegister" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerAVRoomFailedNotify:) name:@"sendToVCFailedRegister" object:nil];
    [self.navigationItem setTitle:@"一键寻医"];
    [self.navigationController setOtherViewNavigation];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestDoctorList
{
    [activityView setOpaque:YES];
    [activityView startAnimating];
    [[PHFindDoctorsManager defaultManager] requestDoctorListCallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            if (resultDic != nil) {
                NSDictionary *roomDic = [resultDic objectForKey:@"Room"];
                NSError *error = nil;
                Room *room = [MTLJSONAdapter modelOfClass:[Room class] fromJSONDictionary:roomDic error:&error];
                if (error) {
                    [CommonUtil HUDShowText:@"房间信息转化失败!" InView:self.view];
                    return ;
                }
                NSArray *resultDoctorList = [resultDic objectForKey:@"Doctor"];
                if (resultDoctorList != nil) {
                    for (NSDictionary *docInfo in resultDoctorList) {
                        Doctor *doctor = [MTLJSONAdapter modelOfClass:[Doctor class] fromJSONDictionary:docInfo error:&error];
                        if (!error) {
                            NSDictionary *doctorDic = [NSDictionary dictionaryWithObjectsAndKeys:room,@"Room",doctor,@"Doctor", nil];
                            [doctorList addObject:doctorDic];
                        }
                    }
                    [_tableView reloadData];
                }
            }
            if (doctorList.count == 0) {
                [CommonUtil HUDShowText:[dic objectForKey:@"现在无医生在线，请稍后再试。"] InView:self.view];
            }
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
        [activityView setOpaque:NO];
        [activityView stopAnimating];
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [activityView setOpaque:NO];
        [activityView stopAnimating];
        [CommonUtil HUDShowText:@"网络错误!" InView:self.view];
    }];
}

-(void)startVideoChatWithDic:(NSDictionary *)dic{
    
    [[XGPSocketAVideoHelper defaultManager] registerRoomWithDic:dic];
}

-(void)registerAVRoomSucceedNotify:(NSNotification *)notify
{
    NSDictionary *dic = notify.object;
    [self performSelectorOnMainThread:@selector(createVideoChatWithDic:) withObject:dic waitUntilDone:NO];
}

-(void)registerAVRoomFailedNotify:(NSNotification *)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CommonUtil HUDShowText:@"视频创建失败，请稍后重试!" InView:self.view];
    });
}

-(void)createVideoChatWithDic:(NSDictionary *)dic
{
    [[PHVideoChatManager defaultManager] createVideoChatWithDicInfo:dic WithCallState:NO];
}

#pragma mark - tableview delegate and datasoucre
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return doctorList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 98.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (doctorList.count == 0) {
        return nil;
    }
    switch (section) {
        case 0:
        {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 42)];
            [view setBackgroundColor:[UIColor whiteColor]];
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(14, 13, [UIScreen mainScreen].bounds.size.width - 28, 42)];
            [title setText:@"Tips:本次通话前5分钟免费，之后开始计价收费，每次10分钟30元人民币"];
            [title setTextColor:[UIColor colorWithRed:148.0f/255 green:148.0f/255 blue:148.0f/255 alpha:1.0f]];
            [title setFont:[UIFont systemFontOfSize:12.f]];
            [title setNumberOfLines:0];
            [view addSubview:title];
            return view;
        }
            break;
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (doctorList.count == 0) {
        return 0.f;
    }

    switch (section) {
        case 0:
            return 60.0f;
            break;
        default:
            break;
    }
    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PHFindDoctorListTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellIdentify];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //Data processing
            NSDictionary *dic = [doctorList objectAtIndex:indexPath.row];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update Interface
                cell.indexTag = indexPath.row;
                cell.delegate = self;
                [cell setUpCellWithDictionary:dic];
            });
        }
    });
    return cell;
}
#pragma mark - tableview点击cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [doctorList objectAtIndex:indexPath.row];
    Doctor *doctor = [dic objectForKey:@"Doctor"];
    if (doctor != nil) {
        Member *member = [[Member alloc] init];
        member.memberId = doctor.memberId;
        PHAddDetailMemberFkViewController *phAddDetailMemberVC = [[PHAddDetailMemberFkViewController alloc] initWithMember:member];
        [self.navigationController pushViewController:phAddDetailMemberVC animated:YES];
    }
}

#pragma -mark phFindDoctorListTableViewCellDelegate
-(void)pushToVideoChatWithTag:(NSInteger)tag
{
    NSDictionary *dic = [doctorList objectAtIndex:tag];
    Doctor *doctor = [dic objectForKey:@"Doctor"];
    Room *room = [dic objectForKey:@"Room"];
    if (doctor.diCancall) {
        if (doctor.diCalling) {
            [CommonUtil HUDShowText:@"该医生正在通话中!" InView:self.view];
        }else{
            if(![ClientHelper isConnect])
            {
                [CommonUtil HUDShowText:@"网络连接异常，请稍后再试!" InView:self.view];
                [ClientHelper connect];
                return;
            }
            Member *host = [[PHAppStartManager defaultManager] userHost];
            NSDictionary *mutableDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:host.memberId],@"fromId",[NSNumber numberWithLongLong:doctor.memberId],@"touid",host.nickName,@"NickName",host.headImage,@"HeadImg",doctor.nickName,@"ToUserNickName",doctor.headImage,@"ToUserHeadImage",room.tmtVideoIp,@"roomip",[NSNumber numberWithInteger:room.roomId],@"roomid",[NSNumber numberWithInteger:room.videoPort],@"port",[NSNumber numberWithInteger:room.iid],@"iid", nil];
            [self startVideoChatWithDic:mutableDic];
        }
    }else{
        [CommonUtil HUDShowText:@"暂时不能发送视频请求给该医生!" InView:self.view];
    }
}
@end