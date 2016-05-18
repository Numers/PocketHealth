//
//  PHLocationHelper.h
//  PocketHealth
//
//  Created by macmini on 15-1-16.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@protocol PHLocationHelperDelegate <NSObject>
-(void)requestWeathInfoComplete:(float)mood WithPMValue:(float)pm;
@end
@interface PHLocationHelper : NSObject<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
    float pmValue;
    NSString *uv;
    NSString *temperature;
    float mood;
}
@property(nonatomic, assign) id<PHLocationHelperDelegate> delegate;

+(id)defaultHelper;
-(void)uploadMyLocationInfo;
-(float)returnPMValue;
-(void)setMoodNumber:(float)m;
-(float)returnSuggestMoodNumber;
-(NSString *)returnUV;
-(NSString *)returnTemperature;
@end
