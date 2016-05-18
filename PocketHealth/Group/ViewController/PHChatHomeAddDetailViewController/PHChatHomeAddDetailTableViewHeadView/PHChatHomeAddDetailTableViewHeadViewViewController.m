//
//  PHChatHomeAddDetailTableViewHeadViewViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/9.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHChatHomeAddDetailTableViewHeadViewViewController.h"

#import "PHChatHomeAddDetailResultViewController.h"



@interface PHChatHomeAddDetailTableViewHeadViewViewController ()<UISearchBarDelegate>
{
    
}
//@property (strong, nonatomic) IBOutlet UIView *searchView;
@property (strong , nonatomic) UISearchController * mySearchController;

@end

@implementation PHChatHomeAddDetailTableViewHeadViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.chatAddSearchBar.delegate = self;
//    
//    PHChatHomeAddDetailResultViewController *AddDetailResultVC = [[PHChatHomeAddDetailResultViewController alloc]init];
//    self.mySearchController = [[UISearchController alloc]initWithSearchResultsController:AddDetailResultVC];
//    self.mySearchController.searchResultsUpdater = AddDetailResultVC;
//    [self.searchView addSubview: self.mySearchController.searchBar ];
//    self.definesPresentationContext = YES;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - searchBar  所有动作发送委托出去
#pragma mark - searchBar 开始编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;    {
    //发送委托到上层addDetail界面
    if ([self.delegate respondsToSelector:@selector(PHChatHomeAddDetailTableViewHeadViewSearchBarBeginEditing)]) {
        [self.delegate PHChatHomeAddDetailTableViewHeadViewSearchBarBeginEditing];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
