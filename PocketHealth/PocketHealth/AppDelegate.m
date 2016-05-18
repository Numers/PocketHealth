//
//  AppDelegate.m
//  PocketHealth
//
//  Created by macmini on 15-1-5.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//
/**
 *
 */
#import "AppDelegate.h"

#import "CommonUtil.h"
#import "PHAppStartManager.h"


//聊天所需要数据库
#import "SGroupDB.h"
#import "SGroupMemberDB.h"
#import "SGroupMessageDB.h"
#import "SFirendDB.h" //输入单词错误 请忽略
#import "SOneForOneMessageDB.h"
#import "SNotificationMessage.h"
#import "SMonitorExerciseDB.h"
#import "Exercise.h"
#import "SSleepingDB.h"
#import "Sleeping.h"

#import "CommonUtil.h"


#import "ClientHelper.h"
#import "PHSocketManagerHelper.h"


#import "KMCGeigerCounter.h"
#import "PHUploadPushInfo.h"

//单位秒
#define kSleepSecondIsSleepSelect 60*5
#define kStepsDelayTime 180

#define SUPPORT_IOS8 1
UIBackgroundTaskIdentifier bgTask;
@interface AppDelegate ()
{
    CMMotionManager *cmMotionManager;
    CMRotationMatrix rotation;
    
    //5s以上手机可用
    CMStepCounter *_stepCounter;
    NSInteger _stepsAtBeginOfLiveCounting;
    float px;
    float py;
    float pz;
    
    
    NSTimeInterval theLastSlientTime;
    NSTimeInterval theWakeupTime;
    BOOL isChange;
    BOOL isSleeping;
    BOOL startCountStepsAndSleep;
    //睡眠记录线程队列
    dispatch_queue_t sleepTimeSaveQueue;
    dispatch_group_t sleepGroup;
    __block bool sleepIsGo ;
    
    NSThread  * sleepThread;
    
    NSTimer * timeToSaveDB;
    NSTimer * timeSleepToSaveDB;
    //当前基础步伐数
    NSInteger stepsBase;

//    Member * host;

}
@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //push register
    [BPush setupChannel:launchOptions]; // 必须
    
    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
    [self registerLocalNotification];
//    [KMCGeigerCounter sharedGeigerCounter].enabled = YES;


    
    
    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
    
    [self initChatServerAndDB];
    
    //初始化聊天服务器以及本地聊天数据库
    [self initSleepDate];
    
    
    if (![CMStepCounter isStepCountingAvailable])
    {
        //初始化 自己编写的 后台运动动作
        [self initBackgroundStepsCountAndSleepTime];
    }else{
        //调用系统方法
        [self initCMSteps];
    }
    //测试使用 观察键值
    [self addObserver:self forKeyPath:@"numSteps" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"numM7Steps" options:0 context:NULL];
    
    [[PHAppStartManager defaultManager] startApp];
    [self.window makeKeyAndVisible];
    [self startUpAnimateView];
    return YES;
}

-(void)startUpAnimateView
{
    //开始
    view = [[PHAppStartView alloc] initWithFrame:self.window.bounds];
    [self.window addSubview:view];
    [self.window bringSubviewToFront:view];  //放到最顶层;
    [view startAnimate];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:AnimateDuration];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView: view cache:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    view.alpha = 0.f;
    [UIView commitAnimations];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [view removeFromSuperview];
}

-(void)registerLocalNotification
{
#if SUPPORT_IOS8
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else
#endif
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}
#if SUPPORT_IOS8
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    [BPush registerDeviceToken:deviceToken]; // 必须
    
    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
}

// 必须，如果正确调用了setDelegate，在bindChannel之后，结果在这个回调中返回。
// 若绑定失败，请进行重新绑定，确保至少绑定成功一次
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
    if ([BPushRequestMethod_Bind isEqualToString:method])
    {
        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
        
        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
        [CommonUtil localUserDefaultsValue:userid forKey:KMY_PUSH_USERID];
        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
        [CommonUtil localUserDefaultsValue:channelid forKey:KMY_PUSH_CHANNELID];
        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
        if(returnCode != BPushErrorCode_Success){
//            [BPush bindChannel];
            return;
        }
        
        Member *host = [[PHAppStartManager defaultManager] userHost];
        if (host != nil) {
            NSString *afkey = [host getHttpKey];
            NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:channelid,@"channelid",userid,@"buserid",[NSString stringWithFormat:@"%d",Device_IOS],@"devicetype", nil];
            [[PHUploadPushInfo defaultManager] uploadPushInfoWithDictionary:param WithAFNetWorkKey:afkey CallDoneBack:^(AFHTTPRequestOperation *operation, id responseObject) {
                
            } CallErrorBack:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        //NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [BPush handleNotification:userInfo]; // 可选
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    application.applicationIconBadgeNumber = 0;
    _isInitiativeExitChatConnect = YES;
    [ClientHelper close];
    if (![CMStepCounter isStepCountingAvailable])
    {
        //修改 自己编写的 后台运动动作
//        [motionManager stopAccelerometerUpdates];
        if (YES) {
            //注册后台
            UIApplication*    app = [UIApplication sharedApplication];
            dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_async(lowQueue, ^{
                //启动
                [self doCounting];

            });
            bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }];
        }
        //保存健康数据
        //1.修改记步信息 算是一种记录把 修改这里的时候请三思 //刷新今天的基础步伐数
//        NSString * steps  = [NSString stringWithFormat:@"applicationWillTerminate now steps is %ld",(long)_numSteps];
//        [self saveStepsRightNow: steps isCanMerge:YES];
        [self saveStepsRightNow];
        
//        [self refreshTodayBaseSteps];
    }
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (YES) {//这里添加是否登录的判断较为合适
        _isInitiativeExitChatConnect = NO; // 开启主动链接
        [self reconnectToChatHostAppdelegate];
//        [self performSelectorInBackground:@selector(reconnectToChatHostAppdelegate) withObject:nil];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   
}

- (void)applicationWillTerminate:(UIApplication *)application {
//    //保存健康数据
//    //1.保存记步信息
//    NSString * steps  = [NSString stringWithFormat:@"applicationWillTerminate now steps is %ld",(long)_numSteps];
//    [self saveStepsRightNow: steps];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - 聊天服务器函数
//聊天服务器数据库初始化
-(void)initChatServerAndDB{
    //ClientHelper 初始化
    [ClientHelper initClient];
    
    //创建群组数据库
    SGroupDB *sgroupDB                = [[SGroupDB alloc]init];
    [sgroupDB createDataBase];
    SGroupMemberDB * sgroupMemberDB   = [[SGroupMemberDB alloc]init];
    [sgroupMemberDB createDataBase];
    SGroupMessageDB * sgroupMessageDB = [[SGroupMessageDB alloc]init];
    [sgroupMessageDB createDataBase];
    SFirendDB *sfriendDB              = [[SFirendDB alloc]init];
    [sfriendDB createDataBase];
    SOneForOneMessageDB * smeesageDB           = [[SOneForOneMessageDB alloc]init];
    [smeesageDB createDataBase];
    
    //91唱新增
    SNotificationMessage *snotifiDB = [[SNotificationMessage alloc]init];
    [snotifiDB createDataBase];
    
    //健康检查部分数据库
    SMonitorExerciseDB * smExerciseDB = [[SMonitorExerciseDB alloc]init];
    [smExerciseDB createDataBase];
    
    SSleepingDB * ssleepDB = [[SSleepingDB alloc]init];
    [ssleepDB createDataBase];
}
-(void)reconnectToChatHostAppdelegate{
    [[PHSocketManagerHelper defaultManager] reConnectSocketChatHost];
//    NSLog(@"reconnect chat host");
//    [ClientHelper connectToHost];
}

#pragma mark - 计算步伐函数 自定义的
-(void)initBackgroundStepsCountAndSleepTime{
    
    cmMotionManager = [[CMMotionManager alloc] init];
    cmMotionManager.accelerometerUpdateInterval = 1.0 / 60.0;
    
    //开启应用 数据清空
    [self clearSteps];
    //获取今天的基础步伐
    [self refreshTodayBaseSteps];
    
    
    
    
    UIApplication*    app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(lowQueue, ^{
        //
        [self doCounting];
    });
    
    [self saveStepsToDB];//开启线程去保存数据
}
-(void)doCounting{
    
    
    cmMotionManager.deviceMotionUpdateInterval = 1 / 30;

    [cmMotionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            float xx = accelerometerData.acceleration.x;
            float yy = accelerometerData.acceleration.y;
            float zz = accelerometerData.acceleration.z;
            
            
//            NSLog(@"acceleration x %f y %f z %f ", xx,yy, zz);
            
            float dot = (px * xx) + (py * yy) + (pz * zz);
            float a = ABS(sqrt(px * px + py * py + pz * pz));
            float b = ABS(sqrt(xx * xx + yy * yy + zz * zz));
            
            dot /= (a * b);
            
            if (dot <= 0.81) {
                if (!isSleeping) {
                    isSleeping = YES;
                    [self performSelector:@selector(stepWakeUp) withObject:nil afterDelay:0.28];
                    self.numSteps ++;
                    NSLog(@"**********    %ld ****************",(long)_numSteps);
                }
            }
            px = xx; py = yy; pz = zz;
//            [self performSelector:@selector(createStartThreadToSaveStepsCountWhen24Clock) withObject:nil afterDelay:0.3];
            
        });
    }];
}
#pragma mark - 计算步伐 系统CMSteps
-(void)initCMSteps{
    
    
    _stepCounter = [[CMStepCounter alloc] init];
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit
                                    | NSMonthCalendarUnit
                                    | NSDayCalendarUnit
                                               fromDate:now];
    NSDate *beginOfDay = [calendar dateFromComponents:components];
    [_stepCounter queryStepCountStartingFrom:beginOfDay
                                          to:now
                                     toQueue:[NSOperationQueue mainQueue]
                                 withHandler:^(NSInteger numberOfSteps,
                                               NSError *error) {
                                     
                                     if (error)
                                     {
                                         NSLog(@"%@", [error localizedDescription]);
                                         self.numM7Steps = -1;
                                     }
                                     else
                                     {
                                         self.numM7Steps = numberOfSteps;
                                         [self _startLiveCounting];
                                     }
                                 }];
    //添加写数据库方法
    [self saveStepsToDBWithM7];
//    NSString * stringStep = [NSString stringWithFormat:@"%ld",(long)_numSteps];
//    NSTimeInterval timeinterval = [[NSDate date]timeIntervalSince1970];
//    int timeLeftToday = (long)timeinterval % 3600;
//    [self performSelector:@selector(createStartThreadToSaveStepsCountWhen24Clock:) withObject:stringStep afterDelay:timeLeftToday];
}
- (void)_startLiveCounting
{
    _stepsAtBeginOfLiveCounting = self.numM7Steps;
    [_stepCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue]
                                         updateOn:1
                                      withHandler:^(NSInteger numberOfSteps,
                                                    NSDate *timestamp,
                                                    NSError *error) {
                                          self.numM7Steps = _stepsAtBeginOfLiveCounting
                                          + numberOfSteps;
                                          NSLog(@"Number of steps add = %ld", (long)numberOfSteps);
                                      }];
    
    NSLog(@"Started live step counting");
}
#pragma mark  - 键值观察
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//    NSLog(@"%ld",(long)self.numSteps);

    if ([keyPath isEqualToString:@"numSteps"]) {
        
        self.stepsToday = [NSNumber numberWithInteger:self.numSteps + stepsBase];
        [self performSelectorOnMainThread:@selector(changeSleepQueue) withObject:nil waitUntilDone:NO];

        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kRefreshNStepsNow" object: self.stepsToday];
    }else if ([keyPath isEqualToString:@"numM7Steps"]){
        NSLog(@"m7 steps change now M7steps is %ld",(long)self.numM7Steps);
         self.stepsToday = [NSNumber numberWithInteger:self.numM7Steps];
        [self performSelectorOnMainThread:@selector(changeSleepQueue) withObject:nil waitUntilDone:NO];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kRefreshNStepsNow" object: self.stepsToday];
    }
    //发送通知
    
    
    
    
}
#pragma mark - 初始化睡眠统计queue
-(void)initSleepDate{
    theLastSlientTime = [[NSDate date]timeIntervalSince1970];
//    sleepTimeSaveQueue = dispatch_queue_create("sleepDateQueue", NULL);
//    sleepGroup = dispatch_group_create();
}
#pragma mark - 数据库处理步伐 睡眠
-(void)saveStepsToDB{
    timeToSaveDB = [NSTimer scheduledTimerWithTimeInterval:kStepsDelayTime target:self selector:@selector(saveStepsRightNow) userInfo:nil repeats:YES];
    [timeToSaveDB fire];
    timeSleepToSaveDB = [NSTimer scheduledTimerWithTimeInterval:kSleepSecondIsSleepSelect target:self selector:@selector(sleepTimerRepeat) userInfo:nil repeats:YES];
}
#pragma mark -  含有m7处理器时候的处理数据方法
-(void)saveStepsToDBWithM7{
    timeToSaveDB = [NSTimer scheduledTimerWithTimeInterval:kStepsDelayTime target:self selector:@selector(saveM7StepsRightNow) userInfo:nil repeats:YES];
    [timeToSaveDB fire];
    timeSleepToSaveDB = [NSTimer scheduledTimerWithTimeInterval:kSleepSecondIsSleepSelect target:self selector:@selector(sleepTimerRepeat) userInfo:nil repeats:YES];
}
-(void)saveSleepToDB{
    NSLog(@"saveSleepToDB load %@",[CommonUtil TimeStrYYYYMMDDWithInterval:theLastSlientTime]);
    //获取当前时间
    SSleepingDB * sleepDB = [[SSleepingDB alloc]init];
    //查询数据库中是否存在 如果存在就修改 不存在就保存
    long long memberId = [[PHAppStartManager defaultManager] userHost] .memberId;
    
//    NSTimeInterval i = [[NSDate date]timeIntervalSince1970] - theLastSlientTime;
//    NSInteger duration = i/60>1?i/60:1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
//                if (![sleepDB isExistSleepingData:theLastSlientTime WithBelongId:memberId belongSleepDateHour:[CommonUtil TimeStrYYYYMMDDHHWithInterval:theLastSlientTime]]) {
        if (![sleepDB isExistSleepingData:theLastSlientTime WithBelongId:memberId belongSleepDateHour:[CommonUtil sleepTimeBelongDateWithHH:[CommonUtil HHTimeStrNow]]]) {
                    //
                    
                   
                     NSLog(@"saveSleepToDB load is %@",[CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:theLastSlientTime]);
                    //查看数据库中是否含有同样开始时间的数据 如果没有 就保存新鲜数据
                    Sleeping * sleeping = [[Sleeping alloc]init];
                    sleeping.belongMemberId = memberId;
                    sleeping.lastSleepTime = theLastSlientTime ;
                    
                    sleeping.wakeupSleepTime = [[NSDate date]timeIntervalSince1970];
                    //        sleeping.belongSleepDate = [CommonUtil TimeStrYYYYMMDDWithInterval:sleeping.wakeupSleepTime + 3600*3];
                    
                    //获取当前时间的小时数据 并返回所属的日期
                    NSString * comBelongDate =  [CommonUtil sleepTimeBelongDateWithHH:[CommonUtil HHTimeStrNow]];
                    sleeping.belongSleepDate = comBelongDate;
                    
                    sleeping.isUpload = NO;
                    
                    
                    
                    
                    
                    NSTimeInterval i2 = sleeping.wakeupSleepTime - theLastSlientTime;
                    NSInteger duration2 = i2/60>1?i2/60:0;
                    
                    if (duration2 != 0) {
                        sleeping.sleepDuration = duration2;
                        [sleepDB saveSleeping:sleeping];
                    }
                
            }
           else{
               //如果有数据存在 那么修改它的结束时间为当前时间 （说明被没小时线程所修改）
               //        BOOL flag =[sleepDB mergeSleepingWakeupTimeTo:[[NSDate date]timeIntervalSince1970] WithBelongId:memberId WithStartSleepTime:theLastSlientTime];
               
               NSTimeInterval i2 = [[NSDate date]timeIntervalSince1970] - theLastSlientTime;
               NSInteger duration2 = i2/60>1?i2/60:1;
               
               BOOL flag =[sleepDB mergeSleepingWakeupTimeTo:[[NSDate date]timeIntervalSince1970] WithLastSleepTime:theLastSlientTime WithBelongId:memberId WithDuration:duration2];
               flag?NSLog(@"sleepDB 修改成功"):NSLog(@"sleepDB 修改失败");
           }
    });
    
//    theWakeupTime = theLastSlientTime;
    //更新最后安静时间
//    theLastSlientTime = [[NSDate date]timeIntervalSince1970];
    
    
}
#pragma mark - 改变睡眠有无m7处理器都一样
-(void)changeSleepQueue{
     NSTimeInterval intverval = [[NSDate date]timeIntervalSince1970]- theLastSlientTime;
    
    if (intverval > kSleepSecondIsSleepSelect) {
        //更新数据库
        [self saveSleepToDB];
    }
    theLastSlientTime = [[NSDate date]timeIntervalSince1970];
    
    NSLog(@"queue %@",[CommonUtil TimeStrYYYYMMDDHHMMSSWithInterval:theLastSlientTime]);
}
-(void)sleepTimerRepeat{
    [self saveSleepToDB];
    
//    theLastSlientTime = [[NSDate date]timeIntervalSince1970];
}
-(void)stepWakeUp{
    isSleeping = NO;
}
//普通记步存数据库方法
-(void)createStartThreadToSaveStepsCount{
//    [self saveStepsRightNow:steps isCanMerge:NO];
    [self saveStepsRightNow];
    //计算当前与下一个小时点的时间差
//    [self performSelector:@selector(saveStepsRightNow:) withObject:steps afterDelay:120];
//    //清空内存记步数据 如果含有m7处理器则不需要
//    [self performSelector:@selector(clearSteps) withObject:nil afterDelay:86400];
}
//m7记步存数据库方法
-(void)createM7StartThreadToSaveStepCount{
    [self saveM7StepsRightNow];
//    NSInteger delayTime = kStepsDelayTime;
//    [self performSelector:@selector(saveM7StepsRightNow:) withObject:m7steps afterDelay:delayTime ];
}
-(void)saveStepsRightNow{
     long long memberId = [[PHAppStartManager defaultManager] userHost].memberId;
    if (self.numSteps == 0 || memberId == 0 ) {
        return;
    }
    //保存数据到数据库 一天存24次步伐数据
    SMonitorExerciseDB * smExerciseDB = [[SMonitorExerciseDB alloc]init];
    
    NSString * belongTime = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];
    //每小时一直保存 记步数据不做修改操作
//    Exercise * exercise = [[Exercise alloc]init];
//    
//    exercise.belongMemberId = memberId;
//    exercise.createTime = [[NSDate date]timeIntervalSince1970];
//    //    exercise.steps = [steps integerValue];
//    exercise.steps = self.numSteps;
//    exercise.belongDateTime = belongTime;
//    [smExerciseDB saveMonitorExercise:exercise];
    
    //如果isCanMerge Yes 存在 那么就修改下数据
    
    //查询数据库数据
    if (![smExerciseDB isExistTheSameBelongDate:belongTime WithMemberId:memberId]) {
        Exercise * exercise = [[Exercise alloc]init];
        exercise.belongMemberId = memberId;
        exercise.createTime = [[NSDate date]timeIntervalSince1970];
        //    exercise.steps = [steps integerValue];
        exercise.steps = self.numSteps;
        exercise.belongDateTime = belongTime;
        [smExerciseDB saveMonitorExercise:exercise];
        //存入数据库 然后清除现在的记步数据
    }else{
        //存入数据库 然后清除现在的记步数据
        [smExerciseDB mergeLastStepsRecordWithBelongId:memberId WithSteps:self.numSteps WithBelongDateTime:belongTime];
        
    }
    //刷新今天的基础步伐数
    NSString * belongTimeTodayall = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    stepsBase = [smExerciseDB selectTodayStepsWithMemberId:memberId WithDataTime:belongTimeTodayall];
    self.stepsToday = [NSNumber numberWithInteger:stepsBase];
    [self clearSteps];

}
-(void)saveM7StepsRightNow{
    //保存数据到数据库 一天存24次步伐数据
    SMonitorExerciseDB * smExerciseDB = [[SMonitorExerciseDB alloc]init];
    long long memberId = [[PHAppStartManager defaultManager] userHost].memberId;
    
    //首先获取今天 现在时刻之前的所有步伐
    NSString * belongTime = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSInteger tmpTodayBeforeSteps = [smExerciseDB selectTodayStepsWithMemberId:memberId WithDataTime:belongTime];
    
    NSInteger tmpSaveSteps = self.numM7Steps - tmpTodayBeforeSteps;
    
    if (memberId == 0 || tmpSaveSteps <= 0) {
        NSString * compareTime = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970] - kStepsDelayTime];
        if (![compareTime isEqualToString:belongTime]) {
            self.numM7Steps = 0;//手动清空数据
        }
        return;
    }
    
   
    
    //整理数据 判断数据库是否含有该条数据 进行存或者改
    NSString * belongTimeWithHour = [CommonUtil TimeStrYYYYMMDDHHWithInterval:[[NSDate date] timeIntervalSince1970]];

    if (![smExerciseDB isExistTheSameBelongDate:belongTimeWithHour WithMemberId:memberId]) {
        Exercise * exercise = [[Exercise alloc]init];
        exercise.belongMemberId = memberId;
        exercise.createTime = [[NSDate date]timeIntervalSince1970];
        //    exercise.steps = [steps integerValue];
        exercise.steps = tmpSaveSteps;
        exercise.belongDateTime = belongTimeWithHour;
        [smExerciseDB saveMonitorExercise:exercise];
    }else{
        //存入数据库 m7不需要清除数据
        [smExerciseDB mergeLastStepsRecordWithBelongId:memberId WithSteps:tmpSaveSteps WithBelongDateTime:belongTimeWithHour];
    }
}
-(void)clearSteps{
    _numSteps = 0;
}
#pragma mark -  返回昨天的睡眠数据 
-(NSNumber *)returnYesterdaySleepMinutes:(long long)memberId{
    SSleepingDB * sleepDB = [[SSleepingDB alloc]init];
    NSString * sleepDuration = [sleepDB selectTodaySleepingMinutes:memberId];
//    NSString * yesterdayStr = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date]timeIntervalSince1970]];
//    NSString * sleepDuration = [sleepDB selectOnedaySleepingMinutesWithYYMMDD:yesterdayStr WithMember:memberId];
    return [NSNumber numberWithInteger:[sleepDuration integerValue]];
}
#pragma mark - 刷新今天的基础步伐- 5s以下only
-(void)refreshTodayBaseSteps{
    long long memberId = [[PHAppStartManager defaultManager] userHost] .memberId;
    if (memberId!=0) {
        SMonitorExerciseDB * smExerciseDB = [[SMonitorExerciseDB alloc]init];
        NSString * todayStr = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
        stepsBase = [smExerciseDB selectTodayStepsWithMemberId:memberId WithDataTime:todayStr];
        self.stepsToday = [NSNumber numberWithInteger:stepsBase];
    }
}
#pragma mark - 停止记步以及睡眠数据的采集
-(void)stopStepsAndSleepCount{
    if (![CMStepCounter isStepCountingAvailable])
    {
        [cmMotionManager stopAccelerometerUpdates];
    
    }else{
        [_stepCounter stopStepCountingUpdates];
    }
}
#pragma mark － M7 处理0点数据以及数据校准 给外部调用
-(void)clearStepsWithZero{
    
    long long memberId = [[PHAppStartManager defaultManager] userHost].memberId;
    SMonitorExerciseDB * smExerciseDB = [[SMonitorExerciseDB alloc]init];
    //首先获取今天 现在时刻之前的所有步伐
    NSString * belongTime = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
    NSInteger tmpTodayBeforeSteps = [smExerciseDB selectTodayStepsWithMemberId:memberId WithDataTime:belongTime];
    
    if (![CMStepCounter isStepCountingAvailable]) {
        if (self.numSteps - tmpTodayBeforeSteps <=0) {
            self.numSteps = 0;
        }
    }else{
        NSInteger tmpSaveSteps = self.numM7Steps - tmpTodayBeforeSteps;
        if (memberId == 0 || tmpSaveSteps <= 0) {
            NSString * compareTime = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970] - kStepsDelayTime];
            if (![compareTime isEqualToString:belongTime]) {
                self.numM7Steps = 0;//手动清空数据
            }
        }
    }
   
    
    
    
//    if (![CMStepCounter isStepCountingAvailable])
//    {
//        //普通校准 暂时不需要
//        
//    }else{
//        //5s以上
//        long long memberId = [[PHAppStartManager defaultManager] userHost].memberId;
//        SMonitorExerciseDB * smExerciseDB = [[SMonitorExerciseDB alloc]init];
//        //首先获取今天 现在时刻之前的所有步伐
//        NSString * belongTime = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970]];
//        NSInteger tmpTodayBeforeSteps = [smExerciseDB selectTodayStepsWithMemberId:memberId WithDataTime:belongTime];
//        NSInteger tmpSaveSteps = self.numM7Steps - tmpTodayBeforeSteps;
//        
//        if (memberId == 0 || tmpSaveSteps <= 0) {
//            NSString * compareTime = [CommonUtil TimeStrYYYYMMDDWithInterval:[[NSDate date] timeIntervalSince1970] - kStepsDelayTime];
//            if (![compareTime isEqualToString:belongTime]) {
//                self.numM7Steps = 0;//手动清空数据
//            }
//        }
//    }
    
    

}
@end
