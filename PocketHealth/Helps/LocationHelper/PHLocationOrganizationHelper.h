//
//  PHLocationOrganizationHelper.h
//  PocketHealth
//
//  Created by macmini on 15-1-19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@class Organization;
@protocol PHLocationOrganizationDelegate<NSObject>
-(void)returnNearestOrganization:(Organization *)org;
-(void)returnCityName:(NSString *)cityName;
@end
@interface PHLocationOrganizationHelper : NSObject<CLLocationManagerDelegate,MKMapViewDelegate>
{
    CLLocationManager *locationManager;
}
@property(nonatomic, assign) id<PHLocationOrganizationDelegate> delegate;
-(void)startLocationOrganization;
@end
