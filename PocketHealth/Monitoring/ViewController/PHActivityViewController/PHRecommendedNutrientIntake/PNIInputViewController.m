//
//  PNIInputViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/31.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PNIInputViewController.h"

#import "PHRNIHeadViewController.h"

#import "PHRNITableViewCell.h"

#import "PHPNIInsideTableViewController.h"
#import "UINavigationController+PHNavigationController.h"
#import "MBProgressHUD.h"
//数据
#import "PHMonitoringHttpRequest.h"
#import "CommonUtil.h"
#import "CalculateViewFrame.h"
#import "PNIFoodCategory.h"
#import "Member.h"
#import "PHAppStartManager.h"
#import "UIImageView+WebCache.h"
#import "JSONKit.h"
#import "PHMonitoringCalorieHelper.h"

#import "GlobalVar.h"



@interface PNIInputViewController ()<PHPNIInsideTableViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * pnicategoryArray;
    PHPNIInsideTableViewController * phpniinsideVC;
    NSMutableArray * pnicategoryLocalDicArray;
    NSMutableArray * pnicategoryLocalObjectArray;
    
    
}

@end

static NSString * indentifierPHRNITableViewCell = @"indentifierPHRNITableViewCell" ;
@implementation PNIInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //请求网络或者本地缓存 获取食物热量list
    
    self.title = @"日均摄入量";
    [self requestFootCalorie];
    [self.navigationController setOtherViewNavigation];
    
   
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:nil];
//    self.tableView.frame = frame;
    self.tableView = [[UITableView alloc]initWithFrame:frame];
    [self.tableView registerNib:[UINib nibWithNibName:@"PHRNITableViewCell" bundle:nil] forCellReuseIdentifier:indentifierPHRNITableViewCell];
    PHRNIHeadViewController * phpniHeadVC = [[PHRNIHeadViewController alloc]init];
    
    self.tableView.tableHeaderView = phpniHeadVC.view;
    
    
    UIBarButtonItem * rightBarBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveToMemberCalorie)];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
//    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:@"sdfsdf" subTitle:@"sdfsdf" dismissalDelay:0.0 touchHandler:^{
//        [self.minimalNotification dismiss];
//    }];
//    
//    [self.view addSubview:self.minimalNotification];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    //    [self.minimalNotification show];
    
}
-(void)saveToMemberCalorie{
    Member * host = [[PHAppStartManager defaultManager] userHost];
    
    
    //保存大卡array
    NSInteger sumCalorie = 0;
    for (PNIFoodCategory * category in pnicategoryArray) {
        sumCalorie += category.sumCalories;
    }
    
    [[PHMonitoringCalorieHelper defaultManager] saveCalorieToPlistWithDic:pnicategoryLocalDicArray];//保存大卡array
    
    host.calorie = sumCalorie;
    NSLog(@" 将 大卡目标设置为 %ld ",(long)host.calorie);
    [[PHAppStartManager defaultManager]setHostMember:host];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - requestFootCalorie
-(void)requestFootCalorie{
    
    //获取本地list
    pnicategoryLocalObjectArray= [[NSMutableArray alloc]init];
    pnicategoryLocalDicArray = [[NSMutableArray alloc]init];
    if([[PHMonitoringCalorieHelper defaultManager]getCalorieFromPlist]){
        pnicategoryLocalObjectArray = [[PHMonitoringCalorieHelper defaultManager]getCalorieFromPlist];
        
        for (PNIFoodCategory * category in pnicategoryLocalObjectArray) {
            NSDictionary * categoryDic = [MTLJSONAdapter JSONDictionaryFromModel:category];
            [pnicategoryLocalDicArray addObject:categoryDic];
        }
        NSLog(@"%@",pnicategoryLocalDicArray);
    }
    
    
    
    pnicategoryArray = [[NSMutableArray alloc]init];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"加载中...";
    //    hud.margin = 10.f;hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    
    
    
    
    [PHMonitoringHttpRequest requestCalorieListFromServerDone:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            NSDictionary * dic = (NSDictionary *)responseObject;
            NSArray * dicResult = [dic objectForKey:@"Result"];
            
            for (NSDictionary * pniDic in dicResult) {
                NSError * error;
                PNIFoodCategory * foodCategory = [MTLJSONAdapter modelOfClass:[PNIFoodCategory class] fromJSONDictionary:pniDic error:&error];
                if (!error) {
                    [pnicategoryArray addObject:foodCategory];
                }
            }
            
            NSLog(@"pniarray count %lu " , (unsigned long)pnicategoryLocalObjectArray.count);
            [self settingTableViewDatasourse];
            
            [self.tableView reloadData];
        }
        [hud hide:YES];
        
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        [hud hide:YES];
    }];
}
-(void)settingTableViewDatasourse{
    if (pnicategoryLocalObjectArray) {
        //处理array 使其内部为 对象
        
        if (pnicategoryLocalObjectArray.count!=0) {
            NSMutableArray * gettingIDArray = [NSMutableArray array];
            for (PNIFoodCategory * category in pnicategoryLocalObjectArray) {
                [gettingIDArray addObject:[NSNumber numberWithInt:category.categroyId]];
            }
            NSPredicate *deleteDuplicate = [NSPredicate predicateWithFormat:@"NOT (SELF.categroyId IN %@)",gettingIDArray];
            NSArray * tmpArray =[pnicategoryArray filteredArrayUsingPredicate:deleteDuplicate];
            if (tmpArray!=nil) {
                if (tmpArray.count>0) {
                    [pnicategoryArray removeAllObjects];
                    [pnicategoryArray addObjectsFromArray:tmpArray];
                    for (PNIFoodCategory * catetmp in pnicategoryLocalObjectArray) {
                        [pnicategoryArray insertObject:catetmp atIndex:0];
                    }
                }
            }
            //                    [pnicategoryArray addObjectsFromArray:tmpArray];
            //                    NSLog(@"pniarray count %lu " , (unsigned long)pnicategoryLocalObjectArray.count);
        }
        
    }

}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return pnicategoryArray.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return @"大卡";
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForFooterInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(8, 4, [UIScreen mainScreen].bounds.size.width/2-8*2, 20);
    label.lineBreakMode=NSLineBreakByWordWrapping;
    label.numberOfLines=0;
//    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
//    label.shadowColor = [UIColor grayColor];
//    label.shadowOffset = CGSizeMake(-1.0, 1.0);
//    label.font = [UIFont boldSystemFontOfSize:13];
    label.text = @"您的日均摄入量";
    
    UILabel * calorieLabel = [[UILabel alloc]init];
    calorieLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2, 4, [UIScreen mainScreen].bounds.size.width/2-8*2, 20);
    
    NSInteger sumCalorie = 0;
    for (PNIFoodCategory * category in pnicategoryArray) {
        sumCalorie += category.sumCalories;
    }
    
    NSString * sumCalorieStr = [NSString stringWithFormat:@"%ld",(long)sumCalorie];
    NSMutableAttributedString * showStr = [[NSMutableAttributedString alloc]initWithString:sumCalorieStr];
    [showStr addAttribute:NSForegroundColorAttributeName value:PH_Blue range:NSMakeRange(0,sumCalorieStr.length)];
    
    
    NSAttributedString * attrStr = [[NSAttributedString alloc]initWithString:@"大卡"];
    
    [showStr appendAttributedString:attrStr];
    
    
    calorieLabel.attributedText = showStr;
    calorieLabel.textAlignment = UITextAlignmentRight;
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    [view addSubview:calorieLabel];
    view.backgroundColor = [UIColor lightGrayColor];
    return view;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHRNITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifierPHRNITableViewCell forIndexPath:indexPath];
    
    if (pnicategoryArray.count!=0) {
        PNIFoodCategory * pniFoodcate = pnicategoryArray[indexPath.row];
        cell.calorieLabel.text = [NSString stringWithFormat:@"%ld 大卡",(long)pniFoodcate.sumCalories];
        cell.mainLabel.text = pniFoodcate.categroyName;
        cell.gramLabel.text = [NSString stringWithFormat:@"%ld 克",(long)pniFoodcate.sumWeight];
        NSLog(@"%@",pniFoodcate.headImg);
        [cell.HeadImageView sd_setImageWithURL:[NSURL URLWithString:pniFoodcate.headImg]];
    }
    // Configure the cell...
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PNIFoodCategory * pniFoodCate = pnicategoryArray[indexPath.row];
    phpniinsideVC = nil;
    phpniinsideVC = [[PHPNIInsideTableViewController alloc]initWithPNIFoodCategory:pniFoodCate];
    phpniinsideVC.delegate = self;
    //    [self.navigationController presentViewController:phpniinsideVC animated:YES completion:nil];
    [self.navigationController pushViewController:phpniinsideVC animated:YES];
}
#pragma mark - PHPNIInsideTableViewControllerDelegate
-(void)changeCategroyInArray:(PNIFoodCategory *)category{
    if ([pnicategoryArray containsObject:category]) {
        //
    }
    
    for (PNIFoodCategory * cateThis in pnicategoryArray) {
        if (cateThis.categroyId == category.categroyId) {
            [pnicategoryArray removeObject:cateThis];
            [pnicategoryArray insertObject:category atIndex:0];
            

            //查询当前数组中是否有该条数据 有就不插入
            NSPredicate *deleteDuplicate = [NSPredicate predicateWithFormat:@"SELF.categroyId = %ld",cateThis.categroyId];
            NSArray * resuleArray = [pnicategoryLocalObjectArray filteredArrayUsingPredicate:deleteDuplicate];
            if (resuleArray.count == 0) {
                [pnicategoryLocalDicArray addObject:[MTLJSONAdapter JSONDictionaryFromModel:cateThis]];
                [pnicategoryLocalObjectArray addObject:category];
            }else{
                PNIFoodCategory * categroyTmp =  resuleArray[0];
                [pnicategoryLocalObjectArray removeObject:categroyTmp];
//                [pnicategoryArray removeObject:categroyTmp];
                for (NSDictionary * tmpDic  in pnicategoryLocalDicArray) {
                    NSInteger  cateId = [[tmpDic objectForKey:@"Fctypeid"]integerValue];
                    if (cateId == cateThis.categroyId) {
                        [pnicategoryLocalDicArray removeObject:tmpDic];
                        break;
                    }
                }
                [pnicategoryLocalDicArray addObject:[MTLJSONAdapter JSONDictionaryFromModel:cateThis]];
            }
            [self.tableView reloadData];
            break;
        }
    }
    
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
