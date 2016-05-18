//
//  PHAppStartView.h
//  PocketHealth
//
//  Created by macmini on 15-2-7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#define AnimateDuration 2.5f

@interface PHAppStartView : UIView
{
    UIImageView *imageViewBig;
    UIImageView *imageViewSmall;
}
-(void)startAnimate;
@end
