//
//  GroupChatGroupDetailMemberViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/17.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupChatGroupDetailMemberViewController.h"
#import "UIImageView+WebCache.h"
#import "GroupMember.h"

static NSString *memberCellIdentifier = @"MemberCollectViewCell";
@interface GroupChatGroupDetailMemberViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    int headCount;
}
@end

@implementation GroupChatGroupDetailMemberViewController
-(id)initWithFrame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        if (!_groupMemberList) {
            _groupMemberList = [[NSMutableArray alloc]init];
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.memberListCollectView.delegate = self;
    self.memberListCollectView.dataSource = self;
    [self.memberListCollectView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:memberCellIdentifier];
    self.memberListCollectView.backgroundColor = [UIColor whiteColor];
    NSLog(@"self.groupMemberList %lu",(unsigned long)self.groupMemberList.count);
    
//    for (GroupMember *gmember in self.groupMemberList) {
//        NSLog(@"%@",gmember.nickName);
//    }
    headCount = [UIScreen mainScreen].bounds.size.width / (40+10);
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.groupMemberCount.text = [NSString stringWithFormat:@"%lu人",(unsigned long)self.groupMemberList.count];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger tmpCount = self.groupMemberList.count<headCount?self.groupMemberList.count:headCount;
    return  tmpCount;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:memberCellIdentifier forIndexPath:indexPath];
//    if (cell!=nil) {
//        <#statements#>
//    }
    
    GroupMember * gmember = self.groupMemberList[indexPath.row];
    if (gmember!=nil) {
        UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        NSLog(@"%@",gmember.headImage);
        [imageView sd_setImageWithURL:[NSURL URLWithString:gmember.headImage] placeholderImage:[UIImage imageNamed:@"usercenter-QR-code"]];
        [cell addSubview:imageView];
    }
    
    return cell;
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