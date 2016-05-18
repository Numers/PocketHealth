//
//  PHDetailsHeadViewController.m
//  PocketHealth
//
//  Created by macmini on 15-1-18.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHDetailsHeadViewController.h"
#import "UIImageView+WebCache.h"
#import "Organization.h"
#import "GlobalVar.h"

@implementation PHDetailsHeadViewController

-(void)drawDotLine
{
    UIGraphicsBeginImageContext(_imgDotLine.frame.size);   //开始画线
    [_imgDotLine.image drawInRect:CGRectMake(0, 0, _imgDotLine.frame.size.width, _imgDotLine.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    
    CGFloat lengths[] = {10.0f,5.0f};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, [UIColor darkGrayColor].CGColor);
    
    CGContextSetLineDash(line,0,lengths,2);  //画虚线
    CGContextMoveToPoint(line, 0.0, 20.0);    //开始画线
    CGContextAddLineToPoint(line, _imgDotLine.frame.size.width, 20.0);
    CGContextStrokePath(line);
    
    _imgDotLine.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)setupWithOrganization:(Organization *)org WithBackGroupImage:(NSString *)backImage
{
    [_imgHeadImage sd_setImageWithURL:[NSURL URLWithString:org.organizationHeadImage] placeholderImage:[UIImage imageNamed:DefaultOrganizationHeadImage]];
    [_imgBackGroundImage sd_setImageWithURL:[NSURL URLWithString:backImage] placeholderImage:[UIImage imageNamed:@"usercenter-userheadbackgroundimage"]];
    _lblOrganizationName.text = org.organizationName;
    if ((org.organizationLevel == nil) || (org.organizationLevel.length == 0)) {
        [_lblLevel setHidden:YES];
    }else{
        _lblLevel.text = org.organizationLevel;
    }
}
@end
