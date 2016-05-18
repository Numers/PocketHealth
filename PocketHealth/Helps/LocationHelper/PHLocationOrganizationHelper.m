//
//  PHLocationOrganizationHelper.m
//  PocketHealth
//
//  Created by macmini on 15-1-19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHLocationOrganizationHelper.h"
#import "GlobalVar.h"
#import "Organization.h"
#import "PHInputPhysicalExamManager.h"

@implementation PHLocationOrganizationHelper
-(void)startLocationOrganization
{
    if ([CLLocationManager locationServicesEnabled]) {
        [self startLocation];
    }
}

-(void)startLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1000.0f;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= IOS_8_0)
    {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
}

-(void)requestNearestOrganizationWithLat:(float)lat WithLon:(float)lon
{
    [[PHInputPhysicalExamManager defaultManager] requestNearestOrganizetionWithLat:lat WithLon:lon CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSError *error = nil;
            Organization *organization = [MTLJSONAdapter modelOfClass:[Organization class] fromJSONDictionary:resultDic error:&error];
            if (!error) {
                if(organization.organizationId == 0)
                {
                    organization = nil;
                }
                
                if ([self.delegate respondsToSelector:@selector(returnNearestOrganization:)]) {
                    [self.delegate returnNearestOrganization:organization];
                }
            }else{
                if ([self.delegate respondsToSelector:@selector(returnNearestOrganization:)]) {
                    [self.delegate returnNearestOrganization:nil];
                }
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(returnNearestOrganization:)]) {
                [self.delegate returnNearestOrganization:nil];
            }
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(returnNearestOrganization:)]) {
            [self.delegate returnNearestOrganization:nil];
        }
    }];
}

#pragma -mark CLLocaitonManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    if (location.horizontalAccuracy == -1) {
        [self startLocation];
    }else{
        NSLog(@"%.2f,%.2f",location.coordinate.latitude,location.coordinate.longitude);
        [manager stopUpdatingLocation];
    
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
            if (array.count > 0) {
                CLPlacemark *placemark = [array objectAtIndex:0];
                NSString *locality = placemark.locality;
                if (!locality) {
                    //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                    locality = placemark.administrativeArea;
                }

                NSString *currentCity = [locality stringByReplacingOccurrencesOfString:@"市" withString:@""];
                if ([_delegate respondsToSelector:@selector(returnCityName:)]) {
                    [_delegate returnCityName:currentCity];
                }
            }
            [self requestNearestOrganizationWithLat:location.coordinate.latitude WithLon:location.coordinate.longitude];
        }];

    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if ([error code] == kCLErrorDenied)
    {
        //访问被拒绝
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
    }
    [manager stopUpdatingLocation];
}
@end
