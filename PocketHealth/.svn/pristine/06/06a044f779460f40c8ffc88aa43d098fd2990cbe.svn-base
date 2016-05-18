//
//  PHMonitoringCalorieHelper.m
//  PocketHealth
//
//  Created by YangFan on 15/1/28.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHMonitoringCalorieHelper.h"
#import "PNIFoodCategory.h"
#import "JSONKit.h"
#import "GlobalVar.h"
#import "PHAppStartManager.h"


static PHMonitoringCalorieHelper * phCalorieHelper;
static NSString * caloriePlist ;
@implementation PHMonitoringCalorieHelper

+(id)defaultManager
{
    if (phCalorieHelper == nil) {
        phCalorieHelper = [[PHMonitoringCalorieHelper alloc] init];

        caloriePlist = [NSString stringWithFormat:@"%lld.plist",[[PHAppStartManager defaultManager] userHost].memberId];
    }
    return phCalorieHelper;
}

-(void)saveCalorieToPlistWithDic:(NSMutableArray *)inputArray
{//array 里面是整理好的字典
    if (inputArray==nil) {
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *selfInfoPath = [documentsPath stringByAppendingPathComponent:caloriePlist];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:selfInfoPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:selfInfoPath error:nil];
        
    }
    
//    NSLog(@"%@",inputArray);
    BOOL isSuccess = [inputArray writeToFile:selfInfoPath atomically:YES];
    isSuccess?NSLog(@"success "):NSLog(@"faild");
    
}

-(NSMutableArray *)getCalorieFromPlist
{

    NSMutableArray * calorieArray = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *selfInfoPath = [documentsPath stringByAppendingPathComponent:caloriePlist];
    
    BOOL flag = [[NSFileManager defaultManager] fileExistsAtPath:selfInfoPath];
    if (flag)
    {
        
        NSArray * tmpGetArray  = [[NSArray alloc ]initWithContentsOfFile:selfInfoPath];
        NSLog(@"%@",tmpGetArray);
        NSMutableArray * tmpArray = [NSMutableArray array];
        for (NSDictionary * categroyDic in tmpGetArray) {
            NSError * error;
            PNIFoodCategory * categroy = [MTLJSONAdapter modelOfClass:[PNIFoodCategory class] fromJSONDictionary:categroyDic error:&error];
            if (!error) {
                
                [tmpArray addObject:categroy];
            }
        }
        calorieArray = [NSMutableArray arrayWithArray:tmpArray];
        
        
    }
//    PNIFoodCategory * categroyaaa = (PNIFoodCategory *)calorieArray[0];
//    NSLog(@"%@",categroyaaa);
    return calorieArray;
    //返回带字典的数组
}

@end
