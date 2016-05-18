//
//  PHDetailsOtherInfoViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHDetailsOtherInfoViewController.h"
#import "PHDetailsOtherInfoTableViewCell.h"
#import "PHDetailsHeadViewController.h"
#import "PHDetailsIntroductionTableViewCell.h"
#import "Organization.h"
#import "PHGetMemberInfoManager.h"

static NSString *CellIdentify = @"DetailsOtherInfoTableViewCell";
static NSString *CellIdentify1 = @"DetailsIntroductionTableViewCell";
static NSString *HeaderViewIdentify = @"HeaderViewIdentify";
@interface PHDetailsOtherInfoViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    PHDetailsHeadViewController *phDetailsHeadVC;
    Organization *organization;
    NSString *backGroupImage;
    
    UIButton *attentionAndChatBtn;
    UIButton * removeAttentionBtn;
}
@property(nonatomic ,strong) UITableView *tableView;
@end

@implementation PHDetailsOtherInfoViewController
-(id)initWithOrganizaiton:(Organization *)org
{
    self = [super init];
    if (self) {
        organization = org;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = ViewBackGroundColor;
    self.view.backgroundColor = ViewBackGroundColor;
    // Do any additional setup after loading the view from its nib.
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 511.0f);
    self.tableView = [[UITableView alloc] initWithFrame:frame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"PHDetailsOtherInfoTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentify];
    [self.tableView registerNib:[UINib nibWithNibName:@"PHDetailsIntroductionTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentify1];
    [self.tableView registerNib:[UINib nibWithNibName:@"PHDetailsHeadViewController" bundle:nil] forHeaderFooterViewReuseIdentifier:HeaderViewIdentify];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    //如果已经关注 那么出现一个删除 一个进入按钮 >1 已关注 0 未关注
    if (organization.utuid > 0) {
        //
        [self createAttentionAndChatBtn];
        [attentionAndChatBtn setTitle:@"进入聊天" forState:UIControlStateNormal];
        [self createRemoveAttentionBtn];
        removeAttentionBtn.hidden = NO;//显示取消关注按钮
        
    }else{
        [self createAttentionAndChatBtn];
        [attentionAndChatBtn setTitle:@"关注" forState:UIControlStateNormal];
        removeAttentionBtn.hidden = YES;//不显示取消关注按钮
    }
    
    [self.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 720)];
    
    [self getOrganizationInfoWithOrgId:organization.userId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//创建下方按钮
-(void)createAttentionAndChatBtn{
    attentionAndChatBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 590, [UIScreen mainScreen].bounds.size.width - 40, 40)];
    [attentionAndChatBtn addTarget:self action:@selector(clickGoChatView) forControlEvents:UIControlEventTouchUpInside];
    [attentionAndChatBtn setBackgroundImage:[UIImage imageNamed:@"confirm-button"] forState:UIControlStateNormal];
    
    [attentionAndChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:attentionAndChatBtn];
}
-(void)createRemoveAttentionBtn{
    removeAttentionBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 590 +50, [UIScreen mainScreen].bounds.size.width - 40, 40)];
    [removeAttentionBtn addTarget:self action:@selector(clickDontAttention) forControlEvents:UIControlEventTouchUpInside];
    [removeAttentionBtn setBackgroundImage:[UIImage imageNamed:@"confirm-button"] forState:UIControlStateNormal];
    [removeAttentionBtn setTitle:@"取消关注" forState:UIControlStateNormal];
    [removeAttentionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:removeAttentionBtn];
    
}
-(void)getOrganizationInfoWithOrgId:(long long)orgId
{
    [[PHGetMemberInfoManager defaultManager] requestMemberInfo:orgId done:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            backGroupImage = [NSString stringWithFormat:@"%@%@",ServerBaseURL,[resultDic objectForKey:@"Userbgimg"]];
            NSLog(@"%@",resultDic);
            NSDictionary *orgInfoDic = [resultDic objectForKey:@"OrganInfo"];
            NSError *error = nil;
            Organization *org = [MTLJSONAdapter modelOfClass:[Organization class] fromJSONDictionary:orgInfoDic error:&error];
            if (!error) {
                organization = [org copy];
                [_tableView reloadData];
            }
            [self changeAttentionBtnStatus:organization];
        }else{
            
        }
    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
-(void)changeAttentionBtnStatus:(Organization *)org{
    if (org.utuid>0) {
        [attentionAndChatBtn setTitle:@"进入聊天" forState:UIControlStateNormal];
        
        if (!removeAttentionBtn) {
            [self createRemoveAttentionBtn];
        }
        removeAttentionBtn.hidden = NO;//显示取消关注按钮
        
    }else{
        [attentionAndChatBtn setTitle:@"关注" forState:UIControlStateNormal];
        removeAttentionBtn.hidden = YES;//不显示取消关注按钮
    }
}
-(void)clickGoChatView
{
    if ([self.delegate respondsToSelector:@selector(clickGoChatViewWithOrganization:result:)]) {
        [self.delegate clickGoChatViewWithOrganization:organization result:^(BOOL flag) {
            if (flag == YES) {
                organization.utuid = 1;
                [self changeAttentionBtnStatus:organization];
            }
        }];
    }
}
-(void)clickDontAttention{
    //dontAttentionOrganization
    
    if ([self.delegate respondsToSelector:@selector(dontAttentionOrganization:result:)]) {
        [self.delegate dontAttentionOrganization:organization result:^(BOOL flag)  {
            if (flag) {
                organization.utuid = 0;
                [self changeAttentionBtnStatus:organization];
            }
            
        }];
    }
    
}
-(void)clickSwitchBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(selectAcceptMessageSwitchViewWithOrganization:)]) {
        [self.delegate selectAcceptMessageSwitchViewWithOrganization:organization];
    }
}

#pragma mark - tableview delegate and datasoucre
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return 6;
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 95;
    }
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 240.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    phDetailsHeadVC = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderViewIdentify];
    [phDetailsHeadVC setupWithOrganization:organization WithBackGroupImage:backGroupImage];
    return phDetailsHeadVC;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identify = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    switch (indexPath.row) {
        case 0:
        {
            PHDetailsIntroductionTableViewCell *phDetailsIntroductionTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentify1];
            [phDetailsIntroductionTableViewCell.lblTextLabel setText:@"简介"];
            [phDetailsIntroductionTableViewCell.lblIntroduction setText:organization.organizationIntroduction];
            return phDetailsIntroductionTableViewCell;
        }
            break;
        case 1:
        {
            PHDetailsOtherInfoTableViewCell *phDetailsOtherInfoTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentify];
            [phDetailsOtherInfoTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [phDetailsOtherInfoTableViewCell.lblTextLabel setText:@"电话"];
            [phDetailsOtherInfoTableViewCell.lblDetailLabel setText:organization.organizationTel];
            return phDetailsOtherInfoTableViewCell;
        }
            break;
        case 2:
        {
            PHDetailsOtherInfoTableViewCell *phDetailsOtherInfoTableViewCell = [tableView dequeueReusableCellWithIdentifier:CellIdentify];
            [phDetailsOtherInfoTableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [phDetailsOtherInfoTableViewCell.lblTextLabel setText:@"地址"];
            [phDetailsOtherInfoTableViewCell.lblDetailLabel setText:organization.organizationAddress];
            return phDetailsOtherInfoTableViewCell;
        }
            break;
        case 3:
        {
            UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (tableViewCell == nil) {
                tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
            }
            
            [tableViewCell.textLabel setText:@"二维码名片"];
            [tableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            return tableViewCell;
        }
            break;
//        case 4:
//        {
//            UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
//            if (tableViewCell == nil) {
//                tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
//                [tableViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
//            }
//            
//            [tableViewCell.textLabel setText:@"接受消息"];
//            UISwitch *sw = [[UISwitch alloc] init];
//            [sw addTarget:self action:@selector(clickSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
//            [tableViewCell setAccessoryView:sw];
//            return tableViewCell;
//        }
//            break;
        case 4:
        {
            UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:identify];
            if (tableViewCell == nil) {
                tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
            }
            [tableViewCell.textLabel setText:@"加群验证"];
            [tableViewCell.detailTextLabel setText:@"不需要验证加入"];
            [tableViewCell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            return tableViewCell;
        }
            break;
        default:
            break;
    }
    return nil;
}
#pragma mark - tableview点击cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            if ([self.delegate respondsToSelector:@selector(selectIntroductionCellWithOrganization:)]) {
                [self.delegate selectIntroductionCellWithOrganization:organization];
            }
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            if ([self.delegate respondsToSelector:@selector(selectQRCodeCellWithOrganization:)]) {
                [self.delegate selectQRCodeCellWithOrganization:organization];
            }
        }
            break;
        case 4:
        {
            if ([self.delegate respondsToSelector:@selector(selectJoinValidateCellWithOrganization:)]) {
                [self.delegate selectJoinValidateCellWithOrganization:organization];
                            }
        }
            break;
//        case 5:
//        {
//            if ([self.delegate respondsToSelector:@selector(selectJoinValidateCellWithOrganization:)]) {
//                [self.delegate selectJoinValidateCellWithOrganization:organization];
//            }
//        }
//            break;
            
        default:
            break;
    }
}
@end
