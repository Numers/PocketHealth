//
//  PHOrganizationAttantionListViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHOrganizationAttantionListViewController.h"
#import "CalculateViewFrame.h"
#import "PHAttentionOrganizationTableViewCell.h"
#import "PHGetMemberInfoManager.h"
#import "Member.h"
#import "Organization.h"
#import "PHOrganizationDetailsViewController.h"
#import "PHAppStartManager.h"
#import "CommonUtil.h"

static NSString *cellIdentify = @"AttentionOrganizationCell";
@interface PHOrganizationAttantionListViewController ()<UIScrollViewDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
{
    NSMutableArray *organizationList;
    NSMutableArray *filterOrganizationList;
    UIActivityIndicatorView *activityView;
    Organization * alertTmpMember;
    NSIndexPath * alertTmpIndexPath;
}
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UISearchBar *searchBar;
@end

@implementation PHOrganizationAttantionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [_tableView registerNib:[UINib nibWithNibName:@"PHAttentionOrganizationTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentify];
    [self initlizedOrganizationList];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem setTitle:@"医院"];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.tableView setEditing:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initlizedOrganizationList
{
    [activityView setOpaque:YES];
    [activityView startAnimating];
    [[PHGetMemberInfoManager defaultManager] requestFriendListWithMemberType:MemberUserTypeAdmin CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSArray *resultArr = [dic objectForKey:@"Result"];
            organizationList = [[NSMutableArray alloc] init];
            for (NSDictionary *m in resultArr) {
                @try {
                    NSError *error = nil;
                    Organization *organization = [MTLJSONAdapter modelOfClass:[Organization class] fromJSONDictionary:m error:&error];
                    if (!error) {
                        [organizationList addObject:organization];
                    }
                }
                @catch (NSException *exception) {
                    
                }
            }
            if (organizationList.count > 0) {
                filterOrganizationList = [NSMutableArray arrayWithArray:organizationList];
            }else{
                [CommonUtil HUDShowText:@"您还未关注任何医院！" InView:self.view];
                filterOrganizationList = [[NSMutableArray alloc] init];
            }
            [self tableViewReloadData];
        }else{
            [CommonUtil HUDShowText:[dic objectForKey:@"Message"] InView:self.view];
            [self tableViewReloadData];
        }
        [activityView setOpaque:NO];
        [activityView stopAnimating];
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [activityView setOpaque:NO];
        [activityView stopAnimating];
        [CommonUtil HUDShowText:@"网络错误！" InView:self.view];
        [self tableViewReloadData];
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


-(void)filterOrganizationWithSearchText:(NSString *)searchText
{
    if (filterOrganizationList == nil) {
        filterOrganizationList = [[NSMutableArray alloc] init];
    }else{
        [filterOrganizationList removeAllObjects];
    }
    
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
    [self tableViewReloadData];
}

#pragma -mark searchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSelector:@selector(filterOrganizationWithSearchText:) withObject:searchText];
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
    Organization *selectOrg = [filterOrganizationList objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(pushChatViewWithMemberId:WithUserType:)]) {
        [[PHAppStartManager defaultManager] popToTabBarControllerWithIndex:1];
        [self.delegate pushChatViewWithMemberId:selectOrg.userId WithUserType:MemberUserTypeAdmin];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filterOrganizationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHAttentionOrganizationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    
    Organization *selectOrganization = [filterOrganizationList objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //Data processing
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update Interface
                [cell setupWithOrganization:selectOrganization];
            });
        }
    });
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    Organization *selectOrganization = [filterOrganizationList objectAtIndex:indexPath.row];
    
    if (IOS_VERSION_8_OR_ABOVE) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            //提示是否删除
            UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:@"是否删除 " message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self.delegate deleteFriendWithMemberId:selectOrganization.userId result:^(BOOL flag) {
                    //            NSLog(@"%hhd",flag);
                    if (flag) {
                        [filterOrganizationList removeObject:selectOrganization];
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                }];
            }];
            [alertVC addAction:cancelAction];
            [alertVC addAction:okAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }else{
        UIAlertView *alertViewIOS7 = [[UIAlertView alloc]initWithTitle:@"是否删除" message:nil
                                                              delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertTmpMember = selectOrganization;
        alertTmpIndexPath = indexPath;
        [alertViewIOS7 show];
    }
    
}

//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

#pragma -mark scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}
#pragma mark - 给ios8以下使用的alertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.delegate deleteFriendWithMemberId:alertTmpMember.userId result:^(BOOL flag) {
            //
            //            NSLog(@"%hhd",flag);
            if (flag) {
                [filterOrganizationList  removeObject:alertTmpMember];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:alertTmpIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
}
@end
