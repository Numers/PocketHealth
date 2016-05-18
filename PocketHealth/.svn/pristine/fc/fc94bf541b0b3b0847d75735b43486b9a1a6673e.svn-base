//
//  PHInterestingGroupViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHInterestingGroupViewController.h"
#import "PHInterestingGroupTableViewCell.h"
#import "Group.h"

static NSString *CellIdentify = @"PHInterestingGroupViewCell";
@interface PHInterestingGroupViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *interestingGroupList;
}
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation PHInterestingGroupViewController
-(id)initWithGroups:(NSMutableArray *)groupList
{
    self = [super init];
    if (self) {
        if (groupList != nil) {
            interestingGroupList = [NSArray arrayWithArray:groupList];
        }else{
            interestingGroupList = [[NSArray alloc] init];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"%lf,%lf",self.view.frame.size.width,self.view.frame.size.height);
    CGFloat height;
    if (interestingGroupList.count == 0) {
        height = 0;
    }else{
        height = interestingGroupList.count * 87.0f + 25;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:@"PHInterestingGroupTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentify];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate and datasoucre
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (interestingGroupList.count == 0) {
        return 0;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return interestingGroupList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 87.0f;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"机构群组";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PHInterestingGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentify];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            //Data processing
            Group *group = [interestingGroupList objectAtIndex:indexPath.row];
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update Interface
                [cell setupWithGroup:group];
            });
        }
    });
    return cell;
}
#pragma mark - tableview点击cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Group *group = [interestingGroupList objectAtIndex:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(selectGroupCellWithGroup:)]) {
        [self.delegate selectGroupCellWithGroup:group];
    }
}
@end
