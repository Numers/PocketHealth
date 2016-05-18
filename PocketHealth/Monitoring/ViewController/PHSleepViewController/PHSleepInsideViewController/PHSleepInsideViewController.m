//
//  PHSleepInsideViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/24.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHSleepInsideViewController.h"
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#import "SSleepingDB.h"
#import "Sleeping.h"
#import "PHAppStartManager.h"
#import "CommonUtil.h"
#import "GlobalVar.h"

@interface PHSleepInsideViewController ()
{
    NSMutableArray * sleepCircelDataValueArray;
    NSMutableArray * sleepCircelColorArray;
    NSInteger sleepDuraion;
}
@end

@implementation PHSleepInsideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //获取数据库的睡眠详情
    [self getSleepingDetailArray];
    [self initSleepCircle];
    
    if (sleepDuraion>100) {
        self.labelSleepDetail.text = @"睡眠棒棒哒~";
    }else{
        self.labelSleepDetail.text = @"请养成良好的睡眠习惯！";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getSleepingDetailArray{
//    sleepCircelDataValueArray = [[NSMutableArray alloc]init];
//    sleepCircelColorArray = [[NSMutableArray alloc]init];
//    [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:0.f]];
//    [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:14.f]];
//    [sleepCircelColorArray addObject:RGB(84, 98, 119)];
//    [sleepCircelColorArray addObject:RGB(89, 196, 242)];
//    return;
    ///////////////////////////////////////////////////////////////////////////////
    SSleepingDB * sleepDb = [[SSleepingDB alloc]init];
    NSMutableArray * sleepDetailArray = [sleepDb selectSleepDetailArrayWithMemberId:[[PHAppStartManager defaultManager] userHost].memberId WithBelongSleepDate:[CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]]];
    
    sleepCircelDataValueArray = [[NSMutableArray alloc]init];
    sleepCircelColorArray = [[NSMutableArray alloc]init];
    
    //先插入起始点0
    [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:0.f]];
    
    for (Sleeping * sleeplist in sleepDetailArray) {
        float startTime = [self transformTimeTofloat:sleeplist.lastSleepTime];
        float endTime = [self transformTimeTofloat:sleeplist.wakeupSleepTime];
        sleepDuraion += sleeplist.sleepDuration;
//        if (sleeplist.lastSleepTime < [CommonUtil TimeIntervalZeroWithInterval:[[NSDate date] timeIntervalSince1970]]) {
        if (sleeplist.lastSleepTime < [CommonUtil TimeStrTransformInterval:sleeplist.belongSleepDate]) {
            startTime -= kTimeStart;
            if (startTime<=0) {
                startTime = 0.05; //0.05 * 60分钟的误差，图像圆环会精确显示，下同
            }
        }
        else{
            startTime += (24 - kTimeStart);
        }
//        if (sleeplist.wakeupSleepTime < [CommonUtil TimeIntervalZeroWithInterval:[[NSDate date] timeIntervalSince1970]]) {
        if (sleeplist.wakeupSleepTime < [CommonUtil TimeStrTransformInterval:sleeplist.belongSleepDate]) {
        endTime -= kTimeStart;
        }else{

            endTime += (24 - kTimeStart);
            if (endTime>=(KTimeEnd+(24 - kTimeStart))) {
                endTime = (KTimeEnd+(24 - kTimeStart)) - 0.05;
            }
        }
        NSLog(@" start %f  end %f",startTime , endTime);
        //去掉睡眠时间小于6分钟的点，这可能会使环错误，而且时常过小展示出来也无意义
        if ((endTime - startTime) < 0.05f) {
            continue;
        }
        //////////////////////////////////////////////////////////////////////////////
        NSNumber *lastObject = sleepCircelDataValueArray.lastObject;
        
        //将新的一段起始时间与前一段结束时间小于6分钟的时段进行合并，认为这是一段连续的睡眠时间
        if ((lastObject.floatValue <= startTime) && (startTime - lastObject.floatValue) < 0.05) {
            [sleepCircelDataValueArray removeLastObject];
        }else{
            [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:startTime]];
        }
        [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:endTime]];
        /////////////////////////////////////////////////////////////////////////////
        
//        NSNumber * lastObject =     sleepCircelDataValueArray.lastObject;
//        if (lastObject.floatValue == startTime) {
//            [sleepCircelDataValueArray removeLastObject];
//            [sleepCircelColorArray removeLastObject];
//            // 0 8 8 9 移除 前面第一个8 只插入 最后一个9
//            
//        }else{
//            [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:startTime]];
//            [sleepCircelColorArray addObject:RGB(84, 98, 119)];
//        }
//        
//        //[UIColor redColor]
//        //RGB(84, 98, 119)
//        [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:endTime]];
//        [sleepCircelColorArray addObject:RGB(89, 196, 242)];
    }
    ///////////////////////////////////////////////////////////////////////////////
    //最后插入结束点 change By BLC //根据睡眠数据整理画圆环所需要的颜色
    [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:14]];
    //for循环结束
    [sleepCircelColorArray addObject:[UIColor clearColor]];
    NSInteger pairs = sleepCircelDataValueArray.count / 2 - 1;
    for (NSInteger pair = 0; pair < pairs; pair ++ ) {
        [sleepCircelColorArray addObject:RGB(84, 98, 119)];
        [sleepCircelColorArray addObject:RGB(89, 196, 242)];
    }
    [sleepCircelColorArray addObject:RGB(84, 98, 119)];
    /////////////////////////////////////////////////////////////////////////////

//    if (sleepCircelDataValueArray.count==0) {
//        [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:0.f]];
//        [sleepCircelColorArray addObject:[UIColor clearColor]];
//        [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:KTimeEnd+24-kTimeStart]];
//        [sleepCircelColorArray addObject:RGB(84, 98, 119)];
//    }else{
//        NSNumber *startTime = sleepCircelDataValueArray.firstObject;
//        if (startTime.floatValue >0.0f) {//如果比0大 那么设置起始点为0 塞入数据
//            [sleepCircelDataValueArray insertObject:[NSNumber numberWithFloat:0] atIndex:0];
//            [sleepCircelColorArray insertObject:[UIColor clearColor] atIndex:0];
//        }else{
//            //如果等于0 那么就优化颜色显示
//            [sleepCircelColorArray removeObjectAtIndex:0];
//            [sleepCircelColorArray insertObject:[UIColor clearColor] atIndex:0];
//            
//        }
//        
//        NSNumber  *endTime = sleepCircelDataValueArray.lastObject;
//        if (endTime.integerValue< (KTimeEnd+24-kTimeStart)) {
//            //结束的时间如果比 最后的value值小 那么将最后一个点添上 value
//            [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:KTimeEnd+24-kTimeStart]];
//            [sleepCircelColorArray addObject:RGB(84, 98, 119)];
//        }
//        else if(endTime.integerValue == (KTimeEnd+24-kTimeStart)){
////            [sleepCircelDataValueArray addObject:[NSNumber numberWithFloat:KTimeEnd+24-kTimeStart]];
////            [sleepCircelColorArray addObject:RGB(89, 196, 242)];
//        }
//    }
    
    
    
}
-(float)transformTimeTofloat:(double)time{
    float hhmm = 0;
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSString *timeStr=[formatter stringFromDate:date];
    NSRange range = [timeStr rangeOfString:@":"];
    if (range.location!=NSNotFound) {
        NSString * rightMM  = [timeStr substringFromIndex:range.location+1];
        float mm = rightMM.floatValue/60;
        NSString * leftHH = [timeStr substringWithRange:NSMakeRange(0, range.location)];
        float hh = leftHH.floatValue;
        hhmm = mm + hh;
    }
    return hhmm;
}
-(void)initSleepCircle{
//    _sleepCircle.rangeValues = @[ @1.342f,                  @9.2f,                @10.0f,               @16.0f              ];

    if (sleepCircelColorArray==nil) {
        sleepCircelColorArray = [[NSMutableArray alloc]init];
    }
    if (sleepCircelDataValueArray==nil) {
        sleepCircelDataValueArray = [[NSMutableArray alloc]init];
    }
    _sleepCircle.rangeValues = sleepCircelDataValueArray;
    _sleepCircle.rangeColors = sleepCircelColorArray;
//    _sleepCircle.rangeValues = @[@0,@10,@11,@14];
//    _sleepCircle.rangeColors = @[RGB(84, 98, 119),RGB(232, 231, 33),RGB(232, 111, 33),RGB(232, 231, 33)];
//    _sleepCircle.rangeColors = @[ RGB(232, 111, 33),    RGB(232, 231, 33),  RGB(27, 202, 33),   RGB(231, 32, 43)    ];
//    _sleepCircle.rangeLabels = @[ @"VERY LOW",          @"LOW",             @"OK",              @"OVER FILL"        ];
    _sleepCircle.scaleDivisionsWidth = 0.008;
    _sleepCircle.scaleSubdivisionsWidth = 0.006;
    _sleepCircle.rangeLabelsWidth = 0.04;
    _sleepCircle.showRangeLabels = YES;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
