//
//  PNIFoodCategory.h
//  PocketHealth
//
//  Created by YangFan on 15/1/26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "mantle.h"

@interface PNIFoodCategory : MTLModel<MTLJSONSerializing>

@property (nonatomic ,strong) NSString * categroyName;
@property (nonatomic) NSInteger categroyId;
@property (nonatomic) NSInteger sumCalories;
@property (nonatomic) NSInteger sumWeight;
@property (nonatomic,strong) NSString * headImg;
@property (nonatomic , strong) NSArray * categroyDetail;
@end

@interface CategroyDetail : MTLModel<MTLJSONSerializing>
@property (nonatomic , strong) NSString * detailName;
@property (nonatomic ) NSInteger  calorie;
@property (nonatomic ) NSInteger  weightUnit;
@property (nonatomic , strong) NSString * weightUnitName;
@property (nonatomic) NSInteger detailId;

@property (nonatomic) NSInteger weight;
@property (nonatomic,strong) NSString * imageUrl;
@property (nonatomic) NSInteger number;
@end