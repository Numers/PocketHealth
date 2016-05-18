//
//  PHCalculateView.h
//  PocketHealth
//
//  Created by macmini on 15-1-27.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PHCalculateViewDelegate<NSObject>
-(void)calculate;
@end
@interface PHCalculateView : UITableViewHeaderFooterView
@property(nonatomic, assign) id<PHCalculateViewDelegate> delegate;
@end
