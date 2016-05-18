//
//  PHAddDetailFindNewGroupTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAddDetailFindNewGroupTableViewController.h"
//界面类
#import "PHChatHomeAddDetailResultViewController.h"
#import "PGAddDetailFindNewGroupHotTypeCollectionViewController.h"
#import "GroupChatGroupDetailMemberListTableViewCell.h"
#import "PHChathomeAddDetailTableViewCell.h" //这个就是传说中的对齐cell
#import "CustomSubtitleTableViewCell.h"

//数据类
#import "PHGroupHttpRequest.h"
#import "CommonUtil.h"
#import "GlobalVar.h"


//#import "UIImageView+AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "CalculateViewFrame.h"



#import "PHAppStartManager.h"
//界面子类
#import "PHAddDetailHotTypeTableViewController.h"
#import "PHChatHomeAddDetailResultIOS7ViewController.h"


#import "PHAddDetailGroupTableViewController.h"



static NSString *identifierCustomGroupChatAddDetailCell = @"xibCustomTableViewCellADDDetail";
@interface PHAddDetailFindNewGroupTableViewController ()<UISearchBarDelegate,PGAddDetailFindNewGroupHotTypeCollectionViewControllerDelegate,UIScrollViewDelegate>
{
    NSArray * sectionHeadTitleArray; //标题section
    
//    UITextField * searchTextField;
    PHChatHomeAddDetailResultViewController *AddDetailResultVC;
    PGAddDetailFindNewGroupHotTypeCollectionViewController * hottypeVC;
    
    NSMutableArray * interestingBarArray;
    NSArray * hotTypeArray;
    
    UIVisualEffectView *visualEffectView ;
    

    
}
@end

@implementation PHAddDetailFindNewGroupTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查找群";
     sectionHeadTitleArray= [[NSArray alloc]initWithObjects:@"请输入群号/关键字",@"热门分类",@"可能感兴趣的群", nil];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.tableView = [[UITableView alloc]init];
    //    self.tableViewMain.backgroundColor = [UIColor redColor];

//    self.tableView.frame = self.view.frame;
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:nil ];
    self.tableView.frame = frame;
    
    //searchController 初始化
    [self createSearchBarController];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSubtitleTableViewCell" bundle:nil] forCellReuseIdentifier:identifierCustomGroupChatAddDetailCell];
    [self.view addSubview:self.tableView];
    //定位地址
    [self locationSelect];
    //中间的热门分类初始化
    [self createHotType];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //下方感兴趣群数据源http请求获取
    [self createInterestBar];
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    

//    self.navigationController.navigationBar.translucent = true;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBar.translucent = false;
}
#pragma mark - 部分数据初始化
-(void)createInterestBar{
    interestingBarArray = [[NSMutableArray alloc]init];
    [PHGroupHttpRequest searchInterestBarWithdone:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            NSDictionary * dic = (NSDictionary *)responseObject;
            NSMutableArray * tmpArray = [dic objectForKey:@"Result"];
            for (NSDictionary * groupDic in tmpArray) {
                NSError * error;
                Group * group = [MTLJSONAdapter modelOfClass:[Group class] fromJSONDictionary:groupDic error:&error];
                if (!error) {
                    [interestingBarArray addObject:group];
                }
            }
        }
        [self.tableView reloadData];
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}
//定位最近机构用来显示附近医院
-(void)locationSelect{
#warning 添加显示最近机构的方法
}
#pragma mark - 界面初始化
#pragma mark - searchController 初始化
-(void)createSearchBarController{
    AddDetailResultVC = [[PHChatHomeAddDetailResultViewController alloc]init];
//    AddDetailResultVC.delegate = self;
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:AddDetailResultVC];
    CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
    AddDetailResultVC.tableViewY = self.searchController.searchBar.frame.size.height + statusBarViewRect.size.height;
    if (/* DISABLES CODE */ (NO)) {
        self.searchController.searchResultsUpdater = AddDetailResultVC;
        self.searchController.searchBar.delegate = self;
        [self.searchController.searchBar sizeToFit];
        self.definesPresentationContext = YES;
        self.searchController.searchBar.layer.borderWidth = 1;
        self.searchController.searchBar.layer.borderColor = [[UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f  blue:235.0f/255.0f  alpha:1] CGColor];
        self.searchController.searchBar.barTintColor = [UIColor colorWithRed:230.0f/255.0f green:235.0f/255.0f  blue:235.0f/255.0f  alpha:1];
    }else{
        self.searchBarIOS7 = [[UISearchBar alloc]init];
        self.searchBarIOS7.delegate = self;
        [self.searchBarIOS7 sizeToFit];
        
    }
    
    
}

#pragma mark -  热门分类初始化
-(void)createHotType{
    //请求服务器
    [PHGroupHttpRequest searchHopTypeGroupWithdone:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            NSDictionary * dic = (NSDictionary *)responseObject;
//            NSLog(@" hot gropu %@",dic);
            hotTypeArray = [dic objectForKey:@"Result"];
            [self.tableView reloadData];
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if (section == 2) {
        return interestingBarArray.count;
    }else{
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return sectionHeadTitleArray[section];
}
#pragma mark -  cell 高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height;
    switch (indexPath.section) {
        case 0:
        {
            height = 44;
        }
            break;
        case 1:{
            height = 170;
        }
            break;
        case 2:{
            height = 70;
        }
            break;
        default:
            height = 70;
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            UITableViewCell * cell = nil;
            NSString *identifierGroupChatAddDetailCell = [NSString stringWithFormat:@"PHGroupChatAddDetail%ldwith%ld",(long)indexPath.section,(long)indexPath.row];
            cell = [tableView  dequeueReusableCellWithIdentifier:identifierGroupChatAddDetailCell];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierGroupChatAddDetailCell];
            }
//            self.definesPresentationContext = YES;
            if (/* DISABLES CODE */ (NO)) {
                [cell.contentView addSubview:self.searchController.searchBar];
            }else{
                [cell.contentView addSubview:self.searchBarIOS7];
            }
            
//            searchTextField = nil;
//            searchTextField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
//            searchTextField.delegate = self;
//            [cell addSubview:searchTextField];
            return cell;
            
        }
            break;
        case 1:{
            UITableViewCell * cell = nil;
            NSString *identifierGroupChatAddDetailCell = [NSString stringWithFormat:@"PHGroupChatAddDetail%ldwith%ld",(long)indexPath.section,(long)indexPath.row];
            cell = [tableView  dequeueReusableCellWithIdentifier:identifierGroupChatAddDetailCell];
            cell = [[GroupChatGroupDetailMemberListTableViewCell alloc]init];
            UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
            hottypeVC = nil;
            if (IOS_VERSION_8_OR_ABOVE) {
                hottypeVC = [[PGAddDetailFindNewGroupHotTypeCollectionViewController alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150) collectionViewLayout:flowLayout WithHotArray:hotTypeArray];
            }else{
                hottypeVC = [[PGAddDetailFindNewGroupHotTypeCollectionViewController alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30) collectionViewLayout:flowLayout WithHotArray:hotTypeArray];
            }
            
            hottypeVC.delegate = self;
            [cell addSubview:hottypeVC.view];
            return cell;
        }
            break;
        case 2:{
            CustomSubtitleTableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:identifierCustomGroupChatAddDetailCell];

            if (!cell) {
                cell = [[CustomSubtitleTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierCustomGroupChatAddDetailCell];
            }

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (interestingBarArray.count!=0) {
                Group * interestGroup = interestingBarArray[indexPath.row];
                cell.customLabel.text =interestGroup.groupName;
                cell.customDetailLabel.text = interestGroup.groupBriefIntroduction;
                NSString *imageUrl = interestGroup.groupHeadImage;

//                cell.customImageView.frame = CGRectMake(0, 0, 45, 45);
          
                if (imageUrl!=nil) {
                    
                    [cell.customImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defult_groups_icons"]];
                }

            }
            return cell;
           
        }
            break;
        default:
            break;
    }

    
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            
        }
            break;
        case 1:{
            
        }
            break;
        case 2:{
            Group * group = interestingBarArray[indexPath.row];
//            [self.navigationController popToRootViewControllerAnimated:NO];
           
//            if ([self.delegate respondsToSelector:@selector(pushCHatViewWIthGroup:)]) {
//                [self.delegate pushCHatViewWIthGroup:group];
//            }
            //没明白这里为什么要用委托？ modify by yangfan 03/26/15
            PHAddDetailGroupTableViewController * phaddGroupDetail = [[PHAddDetailGroupTableViewController alloc]initWithGroup:group];
            [self.navigationController pushViewController:phaddGroupDetail animated:YES];
            
            
            
        }
            break;
        default:
            break;
    }
}
#pragma mark - sendSelectBtid 子界面 coll view 的委托
-(void)sendSelectBtid:(unsigned )btid withTitle:(NSString *)title{
    NSLog(@"%u",btid);
    //先推入群列表界面
    PHAddDetailHotTypeTableViewController * phhotTypeVC = [[PHAddDetailHotTypeTableViewController alloc]init];
    phhotTypeVC.hotTypeId = btid;
    phhotTypeVC.titleName = title;
    phhotTypeVC.delegate = [[PHAppStartManager defaultManager]returnPHGroupChatHomeView];
    [self.navigationController pushViewController:phhotTypeVC animated:YES];
    
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
#pragma mark - 搜索并添加到数组方法
-(void)searchGroupThenAddDetailArray:(NSString *)searchText{
    [AddDetailResultVC removeAllUserInResultArray];
    //调用搜索接口
    [PHGroupHttpRequest searchAllHospitalOnHttpServerWith:searchText done:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        NSLog(@"%@",responseObject);
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            NSArray * memberDicList = [responseObject objectForKey:@"Result"];
            [AddDetailResultVC reloadResultTableViewWithArray:memberDicList WithMemberType:MemberUserTypeDoctor];
        }else{
            
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}
#pragma mark - searchBarDelagete
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"beginText ");
    //毛玻璃效果
//    if (NO) {
//        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        visualEffectView.frame = self.tableView.bounds;
//        [self.tableView addSubview:visualEffectView];
//    }
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"search %@",searchBar.text);
    if ([searchBar.text isEqualToString:@""]) {
        return;
    }
    if (/* DISABLES CODE */ (NO)) {
//        [visualEffectView removeFromSuperview];
        self.navigationController.navigationBar.translucent = false;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        //向服务器请求群信息
        [self searchGroupThenAddDetailArray:searchBar.text];
    }
    
    
   
    
}
//ios7 用这个方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    if (!NO) {
        //
        [self searchGroupThenAddDetailArray:searchBar.text];
        PHChatHomeAddDetailResultIOS7ViewController * resultVC = [[PHChatHomeAddDetailResultIOS7ViewController alloc]initWithResultVC:AddDetailResultVC];
        [self.navigationController pushViewController:resultVC animated:YES];
    }
    
}
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (/* DISABLES CODE */ (NO)) {
        self.navigationController.navigationBar.translucent = false;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    else{
        
    }
    return YES;
}
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    if (NO) {
        self.navigationController.navigationBar.translucent = true;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }else{
        //推入结果界面
    }
    
    return YES;
}

#pragma mark - 滑动隐藏搜索的键盘
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBarIOS7 resignFirstResponder];
}

@end
