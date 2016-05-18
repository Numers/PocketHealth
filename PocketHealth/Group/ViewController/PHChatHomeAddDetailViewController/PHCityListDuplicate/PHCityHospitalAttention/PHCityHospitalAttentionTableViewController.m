//
//  PHCityHospitalAttentionTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/21.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHCityHospitalAttentionTableViewController.h"
#import "PHCityHospitalAttentionTableViewCell.h"
#import "City.h"
#import "Organization.h"
#import "SFirendDB.h"
#import "Member.h"
#import "PHAppStartManager.h"

#import "UIImageView+WebCache.h"

#import "PHGroupHttpRequest.h"
#import "JSONKit.h"
#import "ClientHelper.h"

//子界面
#import "PHOrganizationDetailsViewController.h"
#import "MBProgressHUD.h"


#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface PHCityHospitalAttentionTableViewController ()<UISearchBarDelegate,UIAlertViewDelegate>
{
    City *selectCity;
    NSMutableArray *filterOrganizationList;
    NSArray * organizationList; //tableview 数据源
    
    createType createtype;
    
    //经纬度获取
    CLLocationDegrees lat; //纬度
    CLLocationDegrees lon; //经度
}
@property(nonatomic, strong) UISearchBar *searchBar;

@end


static NSString * identifierPHCityHospitalAttentionTableViewCell = @"identifierPHCityHospitalAttentionTableViewCell";
@implementation PHCityHospitalAttentionTableViewController

-(id)initWithCity:(City *)city
{
    self = [super init];
    if (self) {
        selectCity = city;
        createtype = createTypeCity;
    }
    return self;
}

-(id)initWithNearLocationWithLatitude:(double)latitude longitude:(double)longitude{
    self = [super init];
    if (self) {
        lat = latitude;
        lon = longitude;
        createtype = createTypeLocation;
    }
    return  self;
}
//-(id)initWithHopsitalArray:(NSArray *)hopsitalArray{
//    self = [super init];
//    if (self) {
//        organizationList = hopsitalArray;
//        createtype  = createTypeHospitalArray;
//    }
//    return  self;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    

    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0f)];
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = _searchBar;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PHCityHospitalAttentionTableViewCell" bundle:nil] forCellReuseIdentifier:identifierPHCityHospitalAttentionTableViewCell];
    
    
//    //根据不同的初始化进行不同的处理
//    switch (createtype) {
//        case createTypeCity:
//        {
//            [self initlizedFilterOrganizations];
//        }
//            break;
//        case createTypeLocation:{
//            //暂时不需要特殊处理
//            [self initlizedHospitalArray];
//            
//        }
//            break;
//        default:
//            break;
//    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"附近医院";
    //根据不同的初始化进行不同的处理
    switch (createtype) {
        case createTypeCity:
        {
            [self initlizedFilterOrganizations];
        }
            break;
        case createTypeLocation:{
            //暂时不需要特殊处理
            [self initlizedHospitalArray];
            
        }
            break;
        default:
            break;
    }
}
#pragma -mark searchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSelector:@selector(filterOrganizaitonWithSearchText:) withObject:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
-(void)filterOrganizaitonWithSearchText:(NSString *)searchText
{
    
    [self clearFilterOrganList];
    if ((searchText == nil) || (searchText.length == 0)) {
        [filterOrganizationList addObjectsFromArray:organizationList];
    }else{
        NSString *likeStr = [NSString stringWithFormat:@"*%@*",searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.organizationName LIKE[cd] %@ OR SELF.organizationLevel LIKE[cd] %@",likeStr,likeStr];
        NSArray *array = [organizationList filteredArrayUsingPredicate:predicate];
        if ((array == nil) || (array.count == 0)) {
            
        }else{
            [filterOrganizationList addObjectsFromArray:array];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
#pragma mark - tablview data soure create
-(void)initlizedFilterOrganizations
{
    [self clearFilterOrganList];
    
//    if (selectCity.organizationList.count > 0) {
//        [filterOrganizationList addObjectsFromArray:selectCity.organizationList];
//    }
    //请求网络 获取我是否关注这个城市中的医院
    [PHGroupHttpRequest requestCityHospitalWithCityId:selectCity.cityId done:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            [filterOrganizationList removeAllObjects];
            NSDictionary * resObject = (NSDictionary *)responseObject;
            NSArray * resultArray = [resObject objectForKey:@"Result"];
            //创建一个局部变量 保存获取的数据
            NSMutableArray * tmpOrgList = [NSMutableArray arrayWithCapacity:resultArray.count];
            
            for (NSDictionary * tmpORg in resultArray) {
//                NSLog(@"%@",tmpORg);
                NSError *error = nil;
                Organization * getOrg = [MTLJSONAdapter modelOfClass:[Organization class] fromJSONDictionary:tmpORg error:&error];
                if (!error) {
                    [tmpOrgList addObject:getOrg];
                }
            }
            //给数据源添加数据
            organizationList = [NSArray arrayWithArray:tmpOrgList];
            //给过滤数据添加数据
            [filterOrganizationList  addObjectsFromArray:organizationList];
            [self.tableView reloadData];
        }
        
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
    
}
//初始化来自array
-(void)initlizedHospitalArray{
    [self clearFilterOrganList];
    [PHGroupHttpRequest requestNearByHospitalWithLat:lat lon:lon done:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            [filterOrganizationList removeAllObjects];
            NSDictionary * resObject = (NSDictionary *)responseObject;
            NSArray * resultArray = [resObject objectForKey:@"Result"];
            //创建一个局部变量 保存获取的数据
            NSMutableArray * tmpOrgList = [[NSMutableArray alloc]init];
            
            for (NSDictionary * tmpORg in resultArray) {
                NSLog(@"%@",tmpORg);
                NSError *error = nil;
                Organization * getOrg = [MTLJSONAdapter modelOfClass:[Organization class] fromJSONDictionary:tmpORg error:&error];
                NSLog(@"%@",getOrg);
                if (!error) {
                    [tmpOrgList addObject:getOrg];
                }
            }
            //给数据源添加数据
            organizationList = [NSArray arrayWithArray:tmpOrgList];
            //给过滤数据添加数据
            [filterOrganizationList  addObjectsFromArray:organizationList];
            [self.tableView reloadData];
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}


-(void)clearFilterOrganList{
    if (filterOrganizationList == nil) {
        filterOrganizationList = [[NSMutableArray alloc] init];
    }else{
        [filterOrganizationList removeAllObjects];
    }
}
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 3;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return filterOrganizationList.count;
}
#pragma -mark TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return 75;
}
#pragma  mark - cell点击
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Organization *org = [filterOrganizationList objectAtIndex:indexPath.row];
    PHOrganizationDetailsViewController * phOraganVC = [[PHOrganizationDetailsViewController alloc]initWithOrganization:org];
    [self.navigationController pushViewController:phOraganVC animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHCityHospitalAttentionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierPHCityHospitalAttentionTableViewCell forIndexPath:indexPath];
    if (!cell) {
        NSLog(@"error");
    }
    Organization *org = [filterOrganizationList objectAtIndex:indexPath.row];
//    if ([org.organizationHeadImage isKindOfClass:[NSNull class]] || org.organizationHeadImage ==nil) {
//        
//    }else{
//        NSURL * orgHeadUrl = [NSURL URLWithString:org.organizationHeadImage];
//        [cell.imageViewHead sd_setImageWithURL:orgHeadUrl placeholderImage:[UIImage imageNamed:@"defult_hospital_icons"]];
//    }
    
    NSURL * orgHeadUrl = [NSURL URLWithString:org.organizationHeadImage];
    [cell.imageViewHead sd_setImageWithURL:orgHeadUrl placeholderImage:[UIImage imageNamed:@"defult_hospital_icons"]];
    
    cell.labelMainName.text = org.organizationName;
    cell.labelSecondLabel.text = org.organizationLevel;
    cell.labelDetailLabel.text = org.organizationAddress;
    
    cell.btnRightBtn.tag = indexPath.row;
    if (org.utuid>0) {
        [cell.btnRightBtn setTitle:@"已关注" forState:UIControlStateDisabled];
        [cell.btnRightBtn setEnabled:NO];

    }else{
        [cell.btnRightBtn setTitle:@"点击关注" forState:UIControlStateNormal];
        [cell.btnRightBtn addTarget:self action:@selector(attentionHospitalBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    // Configure the cell...
    
    return cell;
}

-(void)attentionHospitalBtnClick:(id)sender{
    UIButton *clickBtn = (UIButton *)sender;
    if (IOS_VERSION_8_OR_ABOVE) {
        
        //    NSLog(@"%u",clickBtn.tag);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认添加" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self attentionHospital:clickBtn.tag];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIAlertView * alertViewIOS7 = [[UIAlertView alloc]initWithTitle:@"确认添加" message:nil
                                                               delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertViewIOS7.tag = clickBtn.tag;
        [alertViewIOS7 show];
    }
    
    
}
#pragma mark - alertIOS7 delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self attentionHospital:alertView.tag];
    }
}

-(void)attentionHospital:(NSInteger)tag{
    Member * host = [[PHAppStartManager defaultManager]userHost];
    Organization *org = [filterOrganizationList objectAtIndex:tag];
    Member *member  = [Member initWithOrganization:org];
    //将该用户存入数据库
    SFirendDB * sfriendDB = [[SFirendDB alloc]init];
    if (![sfriendDB isExistMemberWithUid:member.memberId WithBelongUid:host.memberId]) {
        member.userState = userStateNormal;
        [sfriendDB saveUser:member WithBelongUid:host.memberId];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = @"正在添加关注...";
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    
    
    //直接加好友
    [PHGroupHttpRequest requestAddAnFriend:member.memberId WithMemberType:0 done:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSString * message = [dic objectForKey:@"Message"];
        hud.labelText = message;
        [hud hide:YES afterDelay:1];
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            //将该用户设置为自己的好友 加入到好友列表
            if ([sfriendDB isExistMemberWithUid:member.memberId WithBelongUid:host.memberId]) {
                member.userState = userStateDelete;
                [sfriendDB mergeWithUser:member WithBelongUid:host.memberId];
            }
            org.utuid = 1;
            NSIndexPath *path = [NSIndexPath indexPathForRow:tag inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
            //                    NSDictionary *dic = (NSDictionary *)responseObject;
            //                NSString * sendTag = [NSString stringWithFormat:@"%@请求添加%@为好友",host.nickName,member.nickName];
            //                //                    NSLog(@"%@",[dic objectForKey:@"Message"]);
            //                NSDictionary *userInfoData = [NSDictionary dictionaryWithObjectsAndKeys:host.headImage,@"HeadImg",host.loginName,@"LoginName",host.nickName,@"NickName",[NSString stringWithFormat:@"%lld",host.memberId],@"UserId",[NSString stringWithFormat:@"%u",host.userType],@"UserType", nil];
            //                NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:userInfoData,@"Data",@"1",@"Code",sendTag,@"Message", nil];
            //                NSString *userInfoStr = [userInfo JSONString];
            //                NSInteger ret =  [ClientHelper addFriend:host.memberId Token:[CommonUtil MyToken] ToUid:member.memberId UserInfo:userInfoStr Msgsn:99999];
            //                NSLog(@"addFriend %ld",(long)ret);
            
        }else{
            NSLog(@"帐号错误 一般不会打印");
        }
        
        
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        hud.labelText = @"网络错误";
        [hud hide:YES afterDelay:1];
    }];
}

#pragma -mark scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_searchBar.isFirstResponder) {
        [_searchBar resignFirstResponder];
    }
}
@end
