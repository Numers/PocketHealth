//
//  PNIFoodCategory.m
//  PocketHealth
//
//  Created by YangFan on 15/1/26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PNIFoodCategory.h"
#import "GlobalVar.h"

@implementation PNIFoodCategory

+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"categroyName" : @"Fctypename" ,
             @"categroyId" : @"Fctypeid",
             @"categroyDetail" : @"FoodCaloriesBase",
             @"headImg":@"ParentImg"
             };
}
+(NSValueTransformer *)categroyDetailJSONTransformer{

    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[CategroyDetail class]];
}

+(NSValueTransformer *)headImgJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        
        NSRange range = [str rangeOfString:ServerBaseURL];
        if (range.length) {
            return str;
        }
        
        NSString * url = [NSString stringWithFormat:@"%@%@",PH_CalorieHeadImage_Pre,str];
        return url;
    }
                                                         reverseBlock:^(NSString *num) {
                                                             return num;
                                                         }];
}

@end

@implementation CategroyDetail
+(NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
             @"detailName" : @"Fcname",
             @"calorie" : @"Fccalories",
             @"weightUnit" :@"Fcunitweight",
             @"detailId" :@"Fcid" ,
             @"weight" : @"Fcweight",
             @"imageUrl" : @"Fcimg",
             @"number" :@"number",
             @"weightUnitName" :@"Fcunitname"
             };
}
+(NSValueTransformer *)imageUrlJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        NSRange range = [str rangeOfString:ServerBaseURL];
        if (range.length) {
            return str;
        }
        
        NSString * url = [NSString stringWithFormat:@"%@%@",ServerBaseURL,str];
        return url;
    }
                                                         reverseBlock:^(NSString *num) {
                                                             return num;
                                                         }];
}

@end
