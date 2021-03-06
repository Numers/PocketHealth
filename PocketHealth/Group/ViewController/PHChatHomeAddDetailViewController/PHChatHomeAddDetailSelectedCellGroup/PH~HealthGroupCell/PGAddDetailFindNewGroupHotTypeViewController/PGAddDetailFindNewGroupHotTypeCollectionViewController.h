//
//  PGAddDetailFindNewGroupHotTypeCollectionViewController.h
//  PocketHealth
//
//  Created by YangFan on 15/1/18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PGAddDetailFindNewGroupHotTypeCollectionViewControllerDelegate <NSObject>

-(void)sendSelectBtid:(unsigned)btid withTitle:(NSString *)title;

@end
@interface PGAddDetailFindNewGroupHotTypeCollectionViewController : UICollectionViewController


-(id)initWithFrame:(CGRect )frame collectionViewLayout:(UICollectionViewLayout *)layout WithHotArray:(NSArray *)hotArray;
//@property (nonatomic , strong) NSArray * hotTypeArray;
@property (nonatomic,weak) id<PGAddDetailFindNewGroupHotTypeCollectionViewControllerDelegate>delegate;

@end
