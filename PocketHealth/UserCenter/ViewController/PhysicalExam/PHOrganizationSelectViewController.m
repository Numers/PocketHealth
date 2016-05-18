//
//  PHOrganizationSelectViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHOrganizationSelectViewController.h"
#import "CalculateViewFrame.h"
#import "Organization.h"
#import "City.h"
#import "PHOrganizationTableViewCell.h"
#import "GlobalVar.h"
#import "PHOrganizationManager.h"
#import "MBProgressHUD+Add.h"
#import "CommonUtil.h"
static NSString *cellIdentify = @"OrganizaitonCell";
@interface PHOrganizationSelectViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UISearchBarDelegate,UIAlertViewDelegate>
{
    City *selectCity;
    NSMutableArray *filterOrganizationList;
    UIActivityIndicatorView *activityView;
}
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UISearchBar *searchBar;
@end

@implementation PHOrganizationSelectViewController

-(id)initWithCity:(City *)city
{
    self = [super init];
    if (self) {
        selectCity = city;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0f)];
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + _searchBar.frame.size.height, frame.size.width, frame.size.height - _searchBar.frame.size.height)];
    [_tableView setBackgroundColor:ViewBackGroundColor];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
        
    }

    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityView setOpaque:NO];
    [activityView setCenter:CGPointMake(_tableView.frame.size.width / 2, _tableView.frame.size.height / 2)];
    [_tableView addSubview:activityView];

    [_tableView registerNib:[UINib nibWithNibName:@"PHOrganizationTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentify];
    [self requestOrganizationList];
}

-(void)initlizedFilterOrganizations
{
    if (filterOrganizationList == nil) {
        filterOrganizationList = [[NSMutableArray alloc] init];
    }else{
        [filterOrganizationList removeAllObjects];
    }
    if (selectCity.organizationList.count > 0) {
        [filterOrganizationList addObjectsFromArray:selectCity.organizationList];
    }
    [self tableViewReloadData];
    if(selectCity.organizationList.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您所在的城市，暂时没有医院，未来我们将更多的医院纳入进来" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)navigationControllerSetting
{
    [self.navigationItem setTitle:@"医院列表"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestOrganizationList
{
    [selectCity.organizationList removeAllObjects];
    [activityView setOpaque:YES];
    [activityView startAnimating];
    [[PHOrganizationManager defaultManager] requestOrganizationListByCityId:selectCity.cityId CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSArray *organizationList = [dic objectForKey:@"Result"];
            if ((organizationList != nil) && (organizationList.count > 0)) {
                for (NSDictionary *organizationDic in organizationList) {
                    NSError *error = nil;
                    Organization *organization = [MTLJSONAdapter modelOfClass:[Organization class] fromJSONDictionary:organizationDic error:&error];
                    if (!error) {
                        [selectCity.organizationList addObject:organization];
                    }
                }
            }
            [self initlizedFilterOrganizations];
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
        }
        [activityView setOpaque:NO];
        [activityView stopAnimating];

    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [activityView setOpaque:NO];
        [activityView stopAnimating];
        [CommonUtil HUDShowText:@"网络错误" InView:self.view];
    }];
}

-(void)tableViewReloadData
{
    if ((filterOrganizationList != nil) && (filterOrganizationList.count > 0)) {
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 0.5)];
        [headView setBackgroundColor:[UIColor colorWithRed:199/255.f green:200/255.f blue:204/255.f alpha:1.f]];
        _tableView.tableHeaderView = headView;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }else{
        _tableView.tableHeaderView = nil;
        _tableView.tableFooterView = nil;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    [_tableView reloadData];
}


-(void)filterOrganizaitonWithSearchText:(NSString *)searchText
{
    if (filterOrganizationList == nil) {
        filterOrganizationList = [[NSMutableArray alloc] init];
    }else{
        [filterOrganizationList removeAllObjects];
    }
    
    if ((searchText == nil) || (searchText.length == 0)) {
        [filterOrganizationList addObjectsFromArray:selectCity.organizationList];
    }else{
        NSString *likeStr = [NSString stringWithFormat:@"*%@*",searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.organizationName LIKE[cd] %@ OR SELF.organizationLevel LIKE[cd] %@",likeStr,likeStr];
        NSArray *array = [selectCity.organizationList filteredArrayUsingPredicate:predicate];
        if ((array == nil) || (array.count == 0)) {
            
        }else{
            [filterOrganizationList addObjectsFromArray:array];
        }
    }
    [self tableViewReloadData];
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

#pragma -mark TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
{
    return 75.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.row == filterOrganizationList.count - 1) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            
            [cell setSeparatorInset:UIEdgeInsetsZero];
            
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            
            [cell setLayoutMargins:UIEdgeInsetsZero];
            
        }
    }else{
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
            
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            
            [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 0)];
            
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Organization *org = [filterOrganizationList objectAtIndex:indexPath.row];
    UIAlertView *alert = nil;
    if (org != nil) {
        NSString *msg = [NSString stringWithFormat:@"您确定选择%@吗?",org.organizationName];
        alert = [[UIAlertView alloc] initWithTitle:@"选择机构" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setTag:indexPath.row];
    }else{
        alert = [[UIAlertView alloc] initWithTitle:@"选择机构" message:@"该机构不存在" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    }
    [alert show];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filterOrganizationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHOrganizationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    
    Organization *organization = [filterOrganizationList objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //Data processing
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update Interface
                [cell setupWithOrganization:organization];
            });
        }
    });
    return cell;
}

#pragma -mark scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}

#pragma -mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }else{
        Organization *org = [filterOrganizationList objectAtIndex:alertView.tag];
        if (org != nil) {
            if ([_delegate respondsToSelector:@selector(popViewWithOrganization:)]) {
                [self.navigationController popViewControllerAnimated:NO];
                [_delegate popViewWithOrganization:org];
            }
        }
    }
}
@end