//
//  PHPNIInsideTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHPNIInsideTableViewController.h"
#import "PNIFoodCategory.h"
#import "PHRNIInsideHeadViewController.h"
#import "PHRNIInsideTableViewCell.h"
#import "PKYStepper.h"

#import "UIImageView+Webcache.h"
//#import "UIImageView+AFNetworking.h"


#import "CommonUtil.h"
#import "CalculateViewFrame.h"

static NSString * indetifierPHRNIInsideTableViewCell = @"PHRNIInsideTableViewCell" ;
@interface PHPNIInsideTableViewController ()
{
    PNIFoodCategory * category;
}
@end

@implementation PHPNIInsideTableViewController

-(id)initWithPNIFoodCategory:(PNIFoodCategory *)cateDetail{
    self = [super init];
    if (self) {
        //
        category = cateDetail;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = category.categroyName;
    CGRect frame = [CalculateViewFrame viewFrame:self.navigationController withTabBarController:nil];
    self.tableView.frame = frame;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PHRNIInsideTableViewCell" bundle:nil] forCellReuseIdentifier:indetifierPHRNIInsideTableViewCell];
    PHRNIInsideHeadViewController * phheadVC = [[PHRNIInsideHeadViewController alloc]init];
    self.tableView.tableHeaderView = phheadVC.view;
    self.tableView.allowsSelection = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem * rightBarBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveMyOptional)];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveMyOptional{
    category.sumCalories = 0;
    category.sumWeight = 0;
    for (CategroyDetail * cateDetail in category.categroyDetail) {
        category.sumCalories += cateDetail.number * cateDetail.calorie;
        category.sumWeight += cateDetail.number * cateDetail.weight;
    }
    NSLog(@"%@",category);
    //委托出去
//    if (category.sumCalories != 0) {
        if ([self.delegate respondsToSelector:@selector(changeCategroyInArray:)]) {
            [self.delegate changeCategroyInArray:category];
        }
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return category.categroyDetail.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PHRNIInsideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indetifierPHRNIInsideTableViewCell];
    if (cell == nil) {
        cell = [[PHRNIInsideTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indetifierPHRNIInsideTableViewCell];
    }
    
    CategroyDetail * detail =category.categroyDetail[indexPath.row];

    NSAttributedString * cr = [[NSMutableAttributedString alloc]initWithString:@"\n"];
    NSString * detailDownStr = [NSString stringWithFormat:@"(一%@约%ld克)",detail.weightUnitName,(long)detail.weight];
    
    
    NSAttributedString * detailStr = [[NSMutableAttributedString alloc]initWithString:detailDownStr];
    NSMutableAttributedString * showStr = [[NSMutableAttributedString alloc]initWithString:detail.detailName];
    [showStr appendAttributedString:cr];
    [showStr appendAttributedString:detailStr];
    cell.labelDetail.attributedText = showStr;
    
    
//    cell.labelDetail.text = [NSString stringWithFormat:@"%@(约%ld克)",detail.detailName,(long)detail.weight];
    
//    if (detail.number==0) {
//        cell.labelCalorie.textColor = [UIColor lightGrayColor];
//        cell.labelCalorie.text = [NSString stringWithFormat:@"%ld/%ld",(long)detail.calorie,(long)detail.weightUnit];
//    }else{
//        cell.labelCalorie.textColor = [UIColor blackColor];
//        cell.labelCalorie.text = [NSString stringWithFormat:@"%ld/%ld",(long)detail.calorie*(int)detail.number,(long)detail.weightUnit*(int)detail.number];
//    }
    
    cell.labelCalorie.text = [self stringWithCalorie:detail.calorie Gram:detail.weightUnit];
    
    CGRect stepperFrame = cell.stepperContentView.bounds;
    PKYStepper * stepper = [[PKYStepper alloc]initWithFrame:stepperFrame];
    
    stepper.valueChangedCallback = ^(PKYStepper * stepper ,float count){
        stepper.countLabel.text = [NSString stringWithFormat:@"%@",@(count)];
        detail.number = (int)count;
        if (detail.number==0) {
            cell.labelCalorie.textColor = [UIColor lightGrayColor];
            cell.labelCalorie.text = [self stringWithCalorie:detail.calorie Gram:detail.weightUnit];
//            cell.labelCalorie.text = [NSString stringWithFormat:@"%ld/%ld",(long)detail.calorie,(long)detail.weightUnit];
        }else{
            cell.labelCalorie.textColor = [UIColor blackColor];
            cell.labelCalorie.text = [NSString stringWithFormat:@"%ld大卡/%ld克",(long)detail.calorie*(int)detail.number,(long)detail.weightUnit*(int)detail.number];
        }
        
        
    };
    stepper.value = detail.number;
    [stepper setup];
    [cell.stepperContentView addSubview:stepper];
    

    NSLog(@"%@",detail.imageUrl);

    [cell.ImageViewHead sd_setImageWithURL:[NSURL URLWithString:detail.imageUrl]];
    // Configure the cell...
    
    return cell;
}
-(NSString *)stringWithCalorie:(long)calorieStr Gram:(long)gramStr{
    return  [NSString stringWithFormat:@"%ld大卡/%ld克",(long)calorieStr,(long)gramStr];
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

@end
