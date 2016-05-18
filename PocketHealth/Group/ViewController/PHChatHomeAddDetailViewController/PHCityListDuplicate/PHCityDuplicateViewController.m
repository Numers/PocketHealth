//
//  PHCityDuplicateViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/21.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHCityDuplicateViewController.h"
#import "CalculateViewFrame.h"
#import "ChineseInclude.h"
#import "PinYinForObjc.h"
//#import "PHOrganizationManager.h"
#import "City.h"
#import "Organization.h"
#import "BATableView.h"
#import "PHOrganizationSelectViewController.h"
#import "MBProgressHUD+Add.h"
#import "PHGroupHttpRequest.h"

//子界面
#import "PHCityHospitalAttentionTableViewController.h"

#define TitleLabelFont [UIFont boldSystemFontOfSize:16.f]
#define TitleLabelColor [UIColor colorWithRed:26/255.f green:26/255.f blue:26/255.f alpha:1.f]

static NSString *cellIdentify = @"CityCell";
static NSString *gpsCityHeader = @"#";
static NSString *hotHeader = @"热门城市";
@interface PHCityDuplicateViewController ()<BATableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate,CityDelegate,MBProgressHUDDelegate>
{
    NSMutableArray *sectionRows;//全部数据
    NSMutableArray *filterSectionRows;//过滤后数据
    NSMutableArray *sections;//全部section
    NSMutableArray *filterSections;//过滤后分类
    NSMutableArray *cityList;
    Organization *gpsOrganization;
    
    NSString * myCityName;
}
@property(nonatomic, strong) BATableView *tableView;
@property(nonatomic, strong) UISearchBar *searchBar;
@end

@implementation PHCityDuplicateViewController
-(id)initWithCityName:(NSString *)cityLocation
{
    self = [super init];
    if (self) {
        myCityName = cityLocation;
//        filterSectionRows = [[NSMutableArray alloc] init];
//        filterSections = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44.0f)];
    [_searchBar setPlaceholder:@"输入城市名或首字母查询"];
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:self.tabBarController];
    _tableView = [[BATableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + _searchBar.frame.size.height, frame.size.width, frame.size.height - _searchBar.frame.size.height)];
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [self requestCityList];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

//    [self showHUD];
}

//-(void)showHUD
//{
//    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
//    [self.view.window addSubview:HUD];
//    
//    HUD.labelText = @"Loading";
//    HUD.delegate = self;
////    [HUD showWhileExecuting:@selector(requestCityList) onTarget:self withObject:nil animated:YES];
//}

-(void)initlizedSectionsAndSectionRows
{
    if (filterSectionRows == nil) {
        filterSectionRows = [[NSMutableArray alloc] init];
    }else{
        [filterSectionRows removeAllObjects];
    }
    
    if(filterSections == nil){
        filterSections = [[NSMutableArray alloc] init];
    }else{
        [filterSections removeAllObjects];
    }
    
    if ((cityList == nil) || (cityList.count == 0)) {
        return;
    }
    
    if (sections == nil) {
        sections = [[NSMutableArray alloc] init];
    }else{
        [sections removeAllObjects];
    }
    
    if (sectionRows == nil) {
        sectionRows = [[NSMutableArray alloc] init];
    }else{
        [sectionRows removeAllObjects];
    }
    
    //处理城市列表
    [self dowithCityList];
    //添加热门城市
    [sections insertObject:hotHeader atIndex:0];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"HotCity" ofType:@"plist"];
    NSArray *hotCityIdList = [NSArray arrayWithContentsOfFile:path];
    if ((hotCityIdList != nil) && (hotCityIdList.count > 0)) {
        NSMutableArray *hotCityList = [[NSMutableArray alloc] init];
        for (NSNumber *m in hotCityIdList) {
            City *city = [self searchCityWithCityId:[m integerValue]];
            if (city != nil) {
                [hotCityList addObject:city];
            }
        }
        [sectionRows insertObject:hotCityList atIndex:0];
    }
    //添加定位城市
    NSArray *gpsCityList = nil;
    City *gpsCity = [self searchCityWithCityName:myCityName];
    if (gpsCity != nil) {
        gpsCityList = [NSArray arrayWithObject:gpsCity];
    }else{
        City *nullCity = [[City alloc] init];
        nullCity.cityName = gpsCityHeader;
        gpsCityList = [NSArray arrayWithObject:nullCity];
    }
    
    [sections insertObject:gpsCityHeader atIndex:0];
    [sectionRows insertObject:gpsCityList atIndex:0];
    //初始化数据源
    [filterSectionRows addObjectsFromArray:sectionRows];
    [filterSections addObjectsFromArray:sections];
    //刷新tableview
    [_tableView reloadData];
}

-(void)dowithCityList
{
    for (City *m in cityList) {
        NSString *character = [[m.initials substringToIndex:1] uppercaseString];
        [self addDifferentCharacterIntoSectionsArray:character];
    }
    
    [sections sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch|NSCaseInsensitiveSearch];
    }];
    
    for (NSString *head in sections) {
        NSString *likeStr = [NSString stringWithFormat:@"%@*",head];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.initials like[cd] %@",likeStr];
        NSArray *filterArr = [cityList filteredArrayUsingPredicate:predicate];
        
        NSMutableArray *sectionRowsMember = [[NSMutableArray alloc] initWithCapacity:filterArr.count];
        for (City *c in filterArr) {
            [sectionRowsMember addObject:c];
        }
        if (sectionRowsMember.count > 0) {
            [sectionRows addObject:sectionRowsMember];
        }
    }
}

-(void)addDifferentCharacterIntoSectionsArray:(NSString *)character
{
    if (character) {
        if (![sections containsObject:character]) {
            [sections addObject:character];
        }
    }
}
-(City *)searchCityWithCityId:(NSInteger)cityId
{
    City *city = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityId = %ld",cityId];
    NSArray *array = [cityList filteredArrayUsingPredicate:predicate];
    
    if ((array != nil) && (array.count > 0)) {
        city = [array lastObject];
    }
    return city;
}
-(City *)searchCityWithCityName:(NSString *)cityName
{
    City *city = nil;
    //如果有市 把市去掉
    NSRange range = [cityName rangeOfString:@"市"];
    NSString * cityStr = cityName;
    if (range.length>0) {
        cityStr = [cityName substringToIndex:range.location];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityName = %@",cityStr];
    NSArray *array = [cityList filteredArrayUsingPredicate:predicate];
    
    if ((array != nil) && (array.count > 0)) {
        city = [array lastObject];
    }
    return city;
}

-(void)filterCityListWithSearchText:(NSString *)searchText
{
    if (filterSectionRows == nil) {
        filterSectionRows = [[NSMutableArray alloc] init];
    }else{
        [filterSectionRows removeAllObjects];
    }
    
    if (filterSections == nil) {
        filterSections = [[NSMutableArray alloc] init];
    }else{
        [filterSections removeAllObjects];
    }
    
    if ((searchText == nil) || (searchText.length == 0)) {
        [filterSectionRows addObjectsFromArray:sectionRows];
        [filterSections addObjectsFromArray:sections];
    }else{
        NSString *nameLikeStr = [NSString stringWithFormat:@"*%@*",searchText];
        NSString *initialsLikeStr = [NSString stringWithFormat:@"%@*",searchText];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.cityName LIKE[cd] %@ OR SELF.initials LIKE[cd] %@",nameLikeStr,initialsLikeStr];
        for (NSInteger i = 0; i < sectionRows.count; i++) {
            NSArray *rows = [sectionRows objectAtIndex:i];
            NSArray *filterArr = [rows filteredArrayUsingPredicate:predicate];
            if ((filterArr == nil) || (filterArr.count == 0)) {
                continue;
            }
            [filterSectionRows addObject:filterArr];
            [filterSections addObject:[sections objectAtIndex:i]];
        }
    }
    [_tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self navigationControllerSetting];
}

-(void)navigationControllerSetting
{
    [self.navigationItem setTitle:@"医院名录"];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    [backItem setTitle:@""];
    [self.navigationItem setBackBarButtonItem:backItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestCityList
{
//    [[PHOrganizationManager defaultManager] requestOrganizetionListCallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dic = (NSDictionary *)responseObject;
//        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
//        if (code == 1) {
//            cityList = [[NSMutableArray alloc] init];
//            NSArray *resultArr = [dic objectForKey:@"Result"];
//            for (NSDictionary *cityDic in resultArr) {
//                City *city = [[City alloc] initWithDictionary:cityDic];
//                [cityList addObject:city];
//            }
//            [self initlizedSectionsAndSectionRows];
//        }else{
//            
//        }
//    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    
    
    
    [PHGroupHttpRequest searchAllCityListDone:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            cityList = [[NSMutableArray alloc] init];
            NSArray *resultArr = [dic objectForKey:@"Result"];
            for (NSDictionary *cityDic in resultArr) {
                City *city = [[City alloc] initWithDictionary:cityDic];
                [cityList addObject:city];
            }
            [self initlizedSectionsAndSectionRows];
            
        }else{
            
        }
        [hud hide:YES];
        
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        [hud hide:YES];
    }];
}

#pragma -mark searchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self performSelector:@selector(filterCityListWithSearchText:) withObject:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

#pragma -mark TableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPat
//{
//    return 44.0f;
//}
- (NSArray *) sectionIndexTitlesForABELTableView:(BATableView *)tableView {
    NSMutableArray *titles = [NSMutableArray arrayWithArray:filterSections];
    [titles removeObject:hotHeader];
    return titles;
}

-(void)scrollToRowWithHeaderTitle:(NSString *)title WithSection:(NSInteger)section
{
    section = [filterSections indexOfObject:title];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]
                      atScrollPosition:UITableViewScrollPositionTop
                              animated:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionMemberArr = [filterSectionRows objectAtIndex:indexPath.section];
    City *selectCity = [sectionMemberArr objectAtIndex:indexPath.row];
    
    PHCityHospitalAttentionTableViewController * phCityHopstialVC = [[PHCityHospitalAttentionTableViewController alloc]initWithCity:selectCity];
    
//    PHOrganizationSelectViewController *phOrganizationSelectVC = [[PHOrganizationSelectViewController alloc] initWithCity:selectCity];
//    phOrganizationSelectVC.delegate = self;
//    [self.navigationController pushViewController:phOrganizationSelectVC animated:YES];
    [self.navigationController pushViewController:phCityHopstialVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return filterSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionMemberArr = [filterSectionRows objectAtIndex:section];
    NSInteger result = sectionMemberArr.count;
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentify];
    }
    
    NSArray *sectionRowsMember = [filterSectionRows objectAtIndex:indexPath.section];
    id obj = [sectionRowsMember objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[City class]]){
        City *city = (City *)obj;
        if ([city.cityName isEqualToString:gpsCityHeader]) {
            [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"暂无定位城市" WithColor:[UIColor grayColor] WithFont:TitleLabelFont]];
        }else{
            [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:city.cityName WithColor:TitleLabelColor WithFont:TitleLabelFont]];
        }
    }else{
        [cell.textLabel setAttributedText:[self generateAttriuteStringWithStr:@"暂无定位城市" WithColor:[UIColor grayColor] WithFont:TitleLabelFont]];
    }
    
    NSString *header = [filterSections objectAtIndex:indexPath.section];
    if ([header isEqualToString:gpsCityHeader]) {
        if ([obj isKindOfClass:[City class]])
        {
            City *city = (City *)obj;
            if ([city.cityName isEqualToString:gpsCityHeader]) {
                cell.detailTextLabel.text = nil;
            }else{
                cell.detailTextLabel.text = @"GPS定位";
            }
        }else{
            cell.detailTextLabel.text = nil;
        }
    }else{
        cell.detailTextLabel.text = nil;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *result = nil;
    NSString *header = [filterSections objectAtIndex:section];
    if ([header isEqualToString:gpsCityHeader]) {
        result = nil;
    }else{
        result = [filterSections objectAtIndex:section];
    }
    return result;
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

#pragma -mark scrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
}

#pragma -mark CityDelegate
-(void)popViewWithOrganization:(Organization *)organizaiton{
    if ([_delegate respondsToSelector:@selector(popViewWithOrganization:)]) {
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate popViewWithOrganization:organizaiton];
    }
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [hud removeFromSuperview];
    hud = nil;
}@end
