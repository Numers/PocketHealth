//
//  PHAddDetailHotTypeTableViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/21.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHAddDetailHotTypeTableViewController.h"
#import "Group.h"
#import "UIImageView+WebCache.h"
#import "PHGroupHttpRequest.h"
#import "CustomSubtitleTableViewCell.h"

static NSString * identifierHotTypeTableViewCell = @"identifierHotTypeTableViewCell";
@interface PHAddDetailHotTypeTableViewController ()
{
    NSMutableArray * groupArray;
}
@end

@implementation PHAddDetailHotTypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    groupArray = [[NSMutableArray alloc]init];
    [self createHotTypeList];
    self.title = _titleName;
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomSubtitleTableViewCell" bundle:nil] forCellReuseIdentifier:identifierHotTypeTableViewCell];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createHotTypeList{
    
    [PHGroupHttpRequest requestBarListByTypeId:_hotTypeId done:^(AFHTTPRequestOperation *operation, id responseObject) {
        //
        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
            [groupArray removeAllObjects];
            NSDictionary * dic = (NSDictionary *)responseObject;
            NSArray * result = [dic objectForKey:@"Result"];
            for (NSDictionary * groupDIc in result) {
                NSError * error ;
                Group * tmpGroup = [MTLJSONAdapter modelOfClass:[Group class] fromJSONDictionary:groupDIc error:&error];
                if (!error) {
                    [groupArray addObject:tmpGroup];
                }
            }
        }
        [self.tableView reloadData];
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        //
    }];
}
#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return groupArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    CustomSubtitleTableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:identifierHotTypeTableViewCell];
    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (groupArray!=nil) {
        //
        Group * group = groupArray[indexPath.row];
        cell.customLabel.text = group.groupName;
        cell.customDetailLabel.text = group.groupBriefIntroduction;
        [cell.customImageView sd_setImageWithURL:[NSURL URLWithString:group.groupHeadImage]];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Group *group = groupArray[indexPath.row];
    if (group) {
//        [self.navigationController popToRootViewControllerAnimated:NO];
        if ([self.delegate respondsToSelector:@selector(pushCHatViewWIthGroup:)]) {
            [self.delegate pushCHatViewWIthGroup:group];
        }
    }
    //delegate
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