//
//  PGAddDetailFindNewGroupHotTypeCollectionViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PGAddDetailFindNewGroupHotTypeCollectionViewController.h"
#import "TopImageAndLabelCollectionViewCell.h"
#import "PHGroupHttpRequest.h"
#import "CommonUtil.h"

//#import "UIImageView+Webcache.h"
#import "UIImageView+WebCache.h"
#import "GlobalVar.h"

#define kOneLineObject 4
@interface PGAddDetailFindNewGroupHotTypeCollectionViewController ()
{
    NSArray * hotTypeArray;
    int marginWidth;
}
@end

@implementation PGAddDetailFindNewGroupHotTypeCollectionViewController

static NSString * const reuseIdentifierPGAddDetailFindNewGroupHotTypeCell = @"PGAddDetailFindNewGroupHotTypeCell";
-(id)initWithFrame:(CGRect )frame collectionViewLayout:(UICollectionViewLayout *)layout WithHotArray:(NSArray *)hotArray{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.collectionView.frame = frame;
        hotTypeArray = hotArray;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
//    hotTypeArray = [[NSArray alloc]init];
    //网络请求一个array
    [self requestHotType];
    // Register cell classes

    [self.collectionView registerNib:[UINib nibWithNibName:@"TopImageAndLabelCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifierPGAddDetailFindNewGroupHotTypeCell];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource  = self;
    marginWidth = ([UIScreen mainScreen].bounds.size.width - 30)/kOneLineObject/2;
    NSLog(@"%u",marginWidth);
    // Do any additional setup after loading the view.
}
-(void)setHotTypeArray:(NSArray *)hotTypeArray{
    [self.collectionView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)requestHotType{
//    [PHGroupHttpRequest searchHopTypeGroupWithdone:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //
//        
//        if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
//            NSDictionary * dic = (NSDictionary *)responseObject;
//            NSLog(@"%@",dic);
//            hotTypeArray = [dic objectForKey:@"Result"];
//            [self.collectionView reloadData];
//        }
//    } error:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //
//    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return kOneLineObject;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(45, 65);
}
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 15, 0, 15);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return marginWidth;
}
//minimumLineSpacing
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TopImageAndLabelCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierPGAddDetailFindNewGroupHotTypeCell forIndexPath:indexPath];
    
    
    if (hotTypeArray.count!=0) {
        NSDictionary * resultDic;
        if (indexPath.section == 0) {
            resultDic = hotTypeArray[indexPath.row];
        }else if (indexPath.section == 1){
            resultDic = hotTypeArray[indexPath.row+kOneLineObject];
        }
        
        NSString * imageName = [resultDic objectForKey:@"Btimg"];
        NSString * btName = [resultDic objectForKey:@"Btname"];
        NSURL * imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ServerBaseURL,imageName]];
        NSLog(@"imageUrl : %@",imageUrl);
        [cell.topImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"groupHomeGroupAttentionCellIcon"]];
        
        cell.label.text =btName;
        // Configure the cell
//        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/
//定义每个UICollectionView 的 margin


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell * cell = (UICollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor redColor];
    
    int hotTypeInt ;
    NSDictionary * resultDic;
    if (hotTypeArray.count!=0) {
        
        if (indexPath.section == 0) {
            resultDic = hotTypeArray[indexPath.row];
        }else if (indexPath.section == 1){
            resultDic = hotTypeArray[indexPath.row+kOneLineObject];
        }
    }
    hotTypeInt = [[resultDic objectForKey:@"Btid"]intValue];;
    NSString * title = [resultDic objectForKey:@"Btname"];
    if ([self.delegate respondsToSelector:@selector(sendSelectBtid:withTitle:)]) {
        [self.delegate sendSelectBtid:hotTypeInt withTitle:title];
    }
}
/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
