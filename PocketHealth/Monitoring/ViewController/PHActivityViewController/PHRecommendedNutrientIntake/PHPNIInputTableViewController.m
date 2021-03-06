//
//  PHPNIInputTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPNIInputTableViewController.h"

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

//界面子类
#import "JFMinimalNotification.h"



@interface PHPNIInputTableViewController ()<PHPNIInsideTableViewControllerDelegate>

{
    NSMutableArray * pnicategoryArray;
    PHPNIInsideTableViewController * phpniinsideVC;
    NSMutableArray * pnicategoryLocalDicArray;
    NSMutableArray * pnicategoryLocalObjectArray;
}
@property (nonatomic , strong) JFMinimalNotification *minimalNotification;
@end


static NSString * indentifierPHRNITableViewCell = @"indentifierPHRNITableViewCell" ;
@implementation PHPNIInputTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //请求网络或者本地缓存 获取食物热量list
    
    [self requestFootCalorie];
    [self.navigationController setOtherViewNavigation];

    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:nil];
    self.tableView.frame = frame;
    [self.tableView registerNib:[UINib nibWithNibName:@"PHRNITableViewCell" bundle:nil] forCellReuseIdentifier:indentifierPHRNITableViewCell];
    PHRNIHeadViewController * phpniHeadVC = [[PHRNIHeadViewController alloc]init];

    self.tableView.tableHeaderView = phpniHeadVC.view;
    
    
    UIBarButtonItem * rightBarBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveToMemberCalorie)];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    
//    self.minimalNotification = [JFMinimalNotification notificationWithStyle:JFMinimalNotificationStyleError title:@"sjdfklsdjfkd" subTitle:@"sjdfsdjlf" dismissalDelay:0.0 touchHandler:^{
//        //点击后做自己的事
//        [self.minimalNotification dismiss];
//    }];
//    [self.view addSubview:self.minimalNotification];
//    [self.minimalNotification show];

//    self.minimalNotification.presentFromTop = YES;

    
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
    NSInteger sumCalorie = 0;

    //保存卡路里array

    for (PNIFoodCategory * category in pnicategoryArray) {
        sumCalorie += category.sumCalories;
    }

    [[PHMonitoringCalorieHelper defaultManager] saveCalorieToPlistWithDic:pnicategoryLocalDicArray];//保存卡路里array
    
    host.calorie = sumCalorie;
    NSLog(@" 将 卡路里目标设置为 %ld ",(long)host.calorie);
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
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
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
            if (pnicategoryLocalObjectArray) {
                //处理array 使其内部为 对象
                
                if (pnicategoryLocalObjectArray.count!=0) {
                    
//                    NSMutableArray * tmpArray = [NSMutableArray array];
//                    for (<#type *object#> in <#collection#>) {
//                        <#statements#>
//                    }
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
                    NSLog(@"pniarray count %lu " , (unsigned long)pnicategoryLocalObjectArray.count);
                }
                
            }
            
            [self.tableView reloadData];
        }
        [hud hide:YES];
        
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
        [hud hide:YES];
    }];
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return pnicategoryArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHRNITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifierPHRNITableViewCell forIndexPath:indexPath];
    
    if (pnicategoryArray.count!=0) {
        PNIFoodCategory * pniFoodcate = pnicategoryArray[indexPath.row];
        cell.calorieLabel.text = [NSString stringWithFormat:@"%ld",(long)pniFoodcate.sumCalories];
        cell.mainLabel.text = pniFoodcate.categroyName;
        cell.gramLabel.text = [NSString stringWithFormat:@"%ld",(long)pniFoodcate.sumWeight];
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
            
            
            [pnicategoryLocalDicArray addObject:[MTLJSONAdapter JSONDictionaryFromModel:cateThis]];
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
#pragma mark -  底部labelx显示

@end
