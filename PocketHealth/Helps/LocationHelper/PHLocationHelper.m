//
//  PHLocationHelper.m
//  PocketHealth
//
//  Created by macmini on 15-1-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHLocationHelper.h"
#import "GlobalVar.h"
#import "PHAppStartManager.h"
#import "PHUpdateUserInfoManager.h"
#import "PHWeathManager.h"
#import "CommonUtil.h"
static PHLocationHelper *phLocationHelper;
@implementation PHLocationHelper
+(id)defaultHelper
{
    if (phLocationHelper == nil) {
        phLocationHelper = [[PHLocationHelper alloc] init];
    }
    return phLocationHelper;
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

-(void)uploadMyLocationInfo
{
    if ([CLLocationManager locationServicesEnabled]){
        [self startLocation];
    }
}

-(void)sendMyLocation:(NSString *)location
{
    [[PHUpdateUserInfoManager defaultManager] updateUserInfoWithParameter:location WithProperty:@"Userlocation" CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

-(void)getWeathInfoWithLat:(float)lat WithLng:(float)lng
{
    NSString *latAndLng = [NSString stringWithFormat:@"%f:%f",lat,lng];
    [[PHWeathManager defaultManager] requestWeathInfo:latAndLng CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSInteger code = [[dic objectForKey:@"Code"] integerValue];
        if (code == 1) {
            NSDictionary *resultDic = [dic objectForKey:@"Result"];
            NSNumber *moodNumber = [resultDic objectForKey:@"MoodNumber"];
            if (([moodNumber isKindOfClass:[NSNull class]]) || (moodNumber == nil)) {
                mood = 0.f;
            }else{
                mood = [moodNumber floatValue];
            }
            
            NSNumber *pmNumber = [resultDic objectForKey:@"Pm25"];
            if (([pmNumber isKindOfClass:[NSNull class]]) || (pmNumber == nil)) {
                pmValue = 0.f;
            }else{
                pmValue = [pmNumber floatValue];
            }
            
            uv = [resultDic objectForKey:@"Uv"];
            temperature = [resultDic objectForKey:@"Temperature"];
            
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            [CommonUtil localUserDefaultsValue:[NSNumber numberWithDouble:now] forKey:KMY_LastLocationTime];
            
        }else{
            mood = 0.f;
            pmValue = 0.f;
        }
        
        if ([self.delegate respondsToSelector:@selector(requestWeathInfoComplete:WithPMValue:)]) {
            [self.delegate requestWeathInfoComplete:mood WithPMValue:pmValue];
        }
    } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
        [CommonUtil HUDShowText:@"网络连接失败" InView:[[UIApplication sharedApplication] keyWindow]];
        mood = 0.f;
        pmValue = 0.f;
        if ([self.delegate respondsToSelector:@selector(requestWeathInfoComplete:WithPMValue:)]) {
            [self.delegate requestWeathInfoComplete:mood WithPMValue:pmValue];
        }
    }];
}

-(void)setMoodNumber:(float)m
{
    mood = m;
}

-(float)returnPMValue
{
    return pmValue;
}

-(float)returnSuggestMoodNumber
{
    return mood;
}

-(NSString *)returnUV
{
    return uv;
}

-(NSString *)returnTemperature
{
    return temperature;
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
        [self getWeathInfoWithLat:location.coordinate.latitude WithLng:location.coordinate.longitude];
        
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
                //                        NSString *state = placemark.administrativeArea;
                //                        NSString *area = placemark.subLocality;
                Member *host = [[PHAppStartManager defaultManager] userHost];
                host.location = [NSString stringWithFormat:@"%@",currentCity];
                [[PHAppStartManager defaultManager] setHostMember:host];
                [self sendMyLocation:host.location];
            }
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
