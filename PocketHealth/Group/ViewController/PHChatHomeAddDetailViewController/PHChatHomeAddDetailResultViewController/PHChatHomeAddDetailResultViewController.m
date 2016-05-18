//
//  PHChatHomeAddDetailResultViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHChatHomeAddDetailResultViewController.h"

//界面
#import "CalculateViewFrame.h"
#import "CustomSubtitleHasRightBtnTableViewCell.h"
#import "MBProgressHUd.h"


//
//#import "Member.h"
#import "Group.h"

#import "ClientHelper.h"
#import "PHAppStartManager.h"
#import "CommonUtil.h"
#import "PHGroupHttpRequest.h"
#import "JSONKit.h"

#import "SFirendDB.h"
#import "UIImageView+WebCache.h"

static NSString *identifierAddDetailResultVieCell = @"PHAddDetailResultVieTableViewCell";

@interface PHChatHomeAddDetailResultViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    Member *host;
}
@property (strong, nonatomic) UITableView *tableViewMain;

@end

@implementation PHChatHomeAddDetailResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor lightGrayColor];

    self.title = @"查询结果";
    self.resultArray = [[NSMutableArray alloc]init];
    //0.初始化tableview
    self.tableViewMain = [[UITableView alloc]init];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    //特殊的位置
    if (IOS_VERSION_8_OR_ABOVE) {
       
    }else{
        
    }
    frame.size.height -= 64;
    frame.origin.y = self.tableViewY;
    
    
    self.tableViewMain.frame = frame;
    self.tableViewMain.delegate = self;
    self.tableViewMain.dataSource = self;
    [self.view addSubview:self.tableViewMain];
    
    host = [[PHAppStartManager defaultManager] userHost];
    [self.tableViewMain registerNib:[UINib nibWithNibName:@"CustomSubtitleHasRightBtnTableViewCell" bundle:nil] forCellReuseIdentifier:identifierAddDetailResultVieCell];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //顶部条显示

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self removeAllUserInResultArray];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 从上方页面刷新本页面tableview
-(void)reloadResultTableViewWithArray:(NSArray *)sendResultArray WithMemberType:(MemberUserType)memberUserType{
    
    if (memberUserType == MemberUserTypeDoctor) {
        //如果是医院
        for (NSDictionary * memberDic in sendResultArray) {
            NSError *error ;
            Group * group = [MTLJSONAdapter modelOfClass:[Group class] fromJSONDictionary:memberDic error:&error];
            [self.resultArray addObject:group];
        }
    }else if (memberUserType == MemberUserTypeUser){
        //用户
        for (NSDictionary * memberDic in sendResultArray) {
            NSError *error ;
            Member * member = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:memberDic error:&error];
            [self.resultArray addObject:member];
        }
    }
//    [self.resultArray removeAllObjects];
//
//    for (NSDictionary * memberDic in sendResultArray) {
//        NSError *error ;
//        Member * member = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:memberDic error:&error];
//        [self.resultArray addObject:member];
//    }
    //处理member 将member添加到数组
    NSLog(@"%@",sendResultArray);
    [self.tableViewMain reloadData];
}
#pragma mark - tableview delegate and datasoucre
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resultArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}
// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomSubtitleHasRightBtnTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierAddDetailResultVieCell];
    if (cell == nil) {
        cell = [[CustomSubtitleHasRightBtnTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierAddDetailResultVieCell];
    }
    NSString *showLableStr;
    NSString * showDetailStr;
    NSURL * headImgUrl;
    id inCellMember = self.resultArray[indexPath.row];
    if ([inCellMember isKindOfClass:[Group class]]) {
        Group *group = (Group *)inCellMember;
        showLableStr = group.groupName;
        showDetailStr = group.groupBriefIntroduction;
        headImgUrl = [NSURL URLWithString:group.groupHeadImage];
    }else if ([inCellMember isKindOfClass:[Member class]]){
        Member *member  = (Member *)inCellMember;
        showLableStr = member.nickName;
        showDetailStr = member.location;
        headImgUrl = [NSURL URLWithString:member.headImage];
    }

    [cell.customRightBtn setTitle:@"关注" forState:UIControlStateNormal];
    [cell.customRightBtn addTarget:self action:@selector(attentionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"%ld %ld",(long)indexPath.section ,(long) indexPath.row);
    cell.customRightBtn.tag = indexPath.row;
    
    [cell.customImageView sd_setImageWithURL:headImgUrl placeholderImage:[UIImage imageNamed:@"defult_hospital_icons"]];
    cell.customLabel.text = showLableStr;
    cell.customDetailLabel.text = showDetailStr;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id inCellMember = self.resultArray[indexPath.row];
    if (inCellMember!=nil) {
        if ([inCellMember isKindOfClass:[Group class]]) {
            Group *group = (Group *)inCellMember;
            [self.delegate pushSearchResultGroupViewController:group];
//            [PHGroupHttpRequest requestAddGroup:group.groupId WithMemberId:host.memberId WithTag:@"" done:^(AFHTTPRequestOperation *operation, id responseObject) {
//                //
//                if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
//                    NSDictionary *dic = (NSDictionary *)responseObject;
//                    NSLog(@"%@",[dic objectForKey:@"Message"]);
//                }else{
//                    NSLog(@"群错误 一般 是已进群");
//                }
//            } error:^(AFHTTPRequestOperation *operation, NSError *error) {
//                //
//            }];
            
            //做直接加群
        }else if ([inCellMember isKindOfClass:[Member class]]){
            Member *member  = (Member *)inCellMember;
            [self.delegate pushSearchResultMemberViewController:member];
//            //将该用户存入数据库
//            SFirendDB * sfriendDB = [[SFirendDB alloc]init];
//            if (![sfriendDB isExistMemberWithUid:member.memberId WithBelongUid:host.memberId]) {
//                [sfriendDB saveUser:member WithBelongUid:host.memberId];
//            }
//            
//            
//            //直接加好友
//            //推入用户详情界面。
////            Member *host = [[PHAppStartManager defaultManager] userHost];
//            //+(void)requestAddAnFriend:(long long)toid WithFriendType:(MemberFriendType)friendType done:(ApiDoneCallback)doneCallback error:(ApiErrorCallback)errorCallback{
//            [PHGroupHttpRequest requestAddAnFriend:member.memberId WithMemberType:0 done:^(AFHTTPRequestOperation *operation, id responseObject) {
//                //
//                if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
////                    NSDictionary *dic = (NSDictionary *)responseObject;
//                    NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友",host.nickName,member.nickName];
////                    NSLog(@"%@",[dic objectForKey:@"Message"]);
//                    NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:host.headImage,@"HeadImg",host.loginName,@"LoginName",host.nickName,@"NickName",[NSString stringWithFormat:@"%lld",host.memberId],@"UserId",[NSString stringWithFormat:@"%u",host.userType],@"UserType", nil];
//                    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
//                    NSString *userInfoStr = [userInfo JSONString];
//                    NSInteger ret =  [ClientHelper addFriend:host.memberId Token:[CommonUtil MyToken] ToUid:member.memberId UserInfo:userInfoStr Msgsn:99999];
//            
//            
//
//                    NSLog(@"addFriend %ld",(long)ret);
//                    
//                }else{
//                    NSLog(@"帐号错误 一般不会打印");
//                }
//
//                
//            } error:^(AFHTTPRequestOperation *operation, NSError *error) {
//                //
//            }];
        }
    }
    
    
    
    
}
-(void)attentionBtnClick:(id)sender{
    UIButton *clickBtn = (UIButton *)sender;
    NSLog(@"%u",clickBtn.tag);
    
    id inCellMember = self.resultArray[clickBtn.tag];
    if (IOS_VERSION_8_OR_ABOVE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认添加" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self attentionSomeOneOrGroup:inCellMember];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIAlertView *alertViewIOS7 = [[UIAlertView alloc]initWithTitle:@"确认添加" message:nil
    delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertViewIOS7.tag = clickBtn.tag;
        [alertViewIOS7 show];
    }
    
   
    


}
#pragma mark - 给ios8以下使用的alertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        id inCellMember = self.resultArray[alertView.tag];
        [self attentionSomeOneOrGroup:inCellMember];
    }
}
#pragma mark - 点击关注之后的处理方法函数
-(void)attentionSomeOneOrGroup:(id)inCellMember{
    if ([inCellMember isKindOfClass:[Group class]]) {
        
//        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hub.mode                      = MBProgressHUDModeText;
//        hub.labelText                 = @"正在关注...";
//        hub.margin                    = 10.0f;
//        hub.removeFromSuperViewOnHide = YES;
        
        Group *group = (Group *)inCellMember;
        [PHGroupHttpRequest requestAddGroup:group.groupId WithMemberId:host.memberId WithTag:@"" done:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            NSDictionary *dic = (NSDictionary *)responseObject;
            NSString * message = [dic objectForKey:@"Message"];
            [CommonUtil HUDShowText:message InView:[UIApplication sharedApplication].keyWindow];
//            hub.labelText = message;
//            [hub hide:YES afterDelay:1];
            if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
                
                
                //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
            }else{
                
            }
        } error:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            [CommonUtil HUDShowText: @"网络错误" InView:[UIApplication sharedApplication].keyWindow];
//            hub.labelText = @"网络错误";
//            [hub hide:YES afterDelay:1];
        }];
        //做直接加群
    }else if ([inCellMember isKindOfClass:[Member class]]){
        Member *member  = (Member *)inCellMember;
        //将该用户存入数据库
        SFirendDB * sfriendDB = [[SFirendDB alloc]init];
//        MBProgressHUD *hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hub.mode                      = MBProgressHUDModeText;
//        hub.labelText                 = @"正在关注...";
//        hub.margin                    = 10.0f;
//        hub.removeFromSuperViewOnHide = YES;
        
        if (![sfriendDB isExistMemberWithUid:member.memberId WithBelongUid:host.memberId]) {
            member.userState = userStateDelete;
            [sfriendDB saveUser:member WithBelongUid:host.memberId];
        }
        //直接加好友
        if (member.userType == MemberUserTypeAdmin) {
            [PHGroupHttpRequest requestAddAnFriend:member.memberId WithMemberType:0 done:^(AFHTTPRequestOperation *operation, id responseObject) {
                //
                NSDictionary *dic = (NSDictionary *)responseObject;
                NSString * message = [dic objectForKey:@"Message"];
                  [CommonUtil HUDShowText:message InView:[UIApplication sharedApplication].keyWindow];
//                hub.labelText = message;
//                [hub hide:YES afterDelay:1];
                if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
                    //                    NSDictionary *dic = (NSDictionary *)responseObject;
                    
                    if (member.userType == MemberUserTypeAdmin) {
                        //
                        if ([sfriendDB isExistMemberWithUid:member.memberId WithBelongUid:host.memberId]) {
                            member.userState = userStateNormal;
                            [sfriendDB mergeWithUser:member WithBelongUid:host.memberId];
                        }
                    }else{
                        //                            NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友",host.nickName,member.nickName];
                        //                            //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
                        //                            NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:host.headImage,@"HeadImg",host.loginName,@"LoginName",host.nickName,@"NickName",[NSString stringWithFormat:@"%lld",host.memberId],@"UserId",[NSString stringWithFormat:@"%u",host.userType],@"UserType", nil];
                        //                            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
                        //                            NSString *userInfoStr = [userInfo JSONString];
                        //                            NSInteger ret =  [ClientHelper addFriend:host.memberId Token:[CommonUtil MyToken] ToUid:member.memberId UserInfo:userInfoStr Msgsn:99999];
                        //                            NSLog(@"addFriend %ld",(long)ret);
                    }
                    
                    
                }else{
                    NSLog(@"帐号错误 一般不会打印");
                }
                
                
            } error:^(AFHTTPRequestOperation *operation, NSError *error) {
                //
                 [CommonUtil HUDShowText:@"网络错误" InView:[UIApplication sharedApplication].keyWindow];
//                hub.labelText = @"网络错误";
//                [hub hide:YES afterDelay:1];
            }];
            
        }else{
            NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友",host.nickName,member.nickName];
            //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
            NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:host.headImage,@"HeadImg",host.loginName,@"LoginName",host.nickName,@"NickName",[NSString stringWithFormat:@"%lld",host.memberId],@"UserId",[NSString stringWithFormat:@"%u",host.userType],@"UserType", nil];
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
            NSString *userInfoStr = [userInfo JSONString];
            NSInteger ret =  [ClientHelper addFriend:host.memberId Token:[CommonUtil MyToken] ToUid:member.memberId UserInfo:userInfoStr Msgsn:99999];
            NSLog(@"addFriend %ld",(long)ret);
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            
//            // Configure for text only and offset down
//            hud.mode = MBProgressHUDModeText;
//            hud.margin = 10.f;hud.yOffset = 150.f;
//            hud.removeFromSuperViewOnHide = YES;
            
            if (ret>0) {
                //请求成功
                 [CommonUtil HUDShowText:@"已提交你的加好友申请" InView:[UIApplication sharedApplication].keyWindow];
//                hub.labelText = @"已提交你的加好友申请";
//                [hub hide:YES afterDelay:1];
            }else{
                 [CommonUtil HUDShowText:@"网络错误 请重试" InView:[UIApplication sharedApplication].keyWindow];
//                hub.labelText = @"网络错误 请重试";
//                [hub hide:YES afterDelay:1];
            }
            
        }
    }

}


#pragma mark -  清空搜索结果列表
-(void)removeAllUserInResultArray{
    [self.resultArray removeAllObjects];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"Entering:%@",searchController.searchBar.text);
}
@end
