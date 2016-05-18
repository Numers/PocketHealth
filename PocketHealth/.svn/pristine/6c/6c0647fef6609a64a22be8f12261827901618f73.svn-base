//
//  PHOrganizationManager.m
//  PocketHealth
//
//  Created by macmini on 15-1-10.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHOrganizationManager.h"
static PHOrganizationManager *phOrganizationManager;
static AFHTTPRequestOperationManager *requestManager;
@implementation PHOrganizationManager
+(id)defaultManager
{
    if (phOrganizationManager == nil) {
        phOrganizationManager = [[PHOrganizationManager alloc] init];
        requestManager = [AFHTTPRequestOperationManager manager];
        [requestManager.requestSerializer setTimeoutInterval:TimeOut];
    }
    return phOrganizationManager;
}

-(void)requestOrganizetionListCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_OrganizationInfoList_API stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [requestManager POST:url parameters:nil success:calldoneBack failure:callErrorBack];
}

-(void)requestCityListCallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_Get_CityList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:AFNetWorkKey,@"key",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}

-(void)requestOrganizationListByCityId:(NSInteger)cityId CallDoneBack:(ApiDoneCallback)calldoneBack CallErrorBack:(ApiErrorCallback)callErrorBack
{
    NSString *url = [PH_Search_Hospital_WithCityID stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:AFNetWorkKey,@"key",[NSString stringWithFormat:@"%ld",(long)cityId],@"id",nil];
    [requestManager POST:url parameters:parameters success:calldoneBack failure:callErrorBack];
}
@end
