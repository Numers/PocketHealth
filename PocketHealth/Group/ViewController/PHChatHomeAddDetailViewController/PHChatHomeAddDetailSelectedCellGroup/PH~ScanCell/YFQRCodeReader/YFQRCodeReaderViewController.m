//
//  YFQRCodeReaderViewController.m
//  PocketHealth
//
//  Created by YangFan on 15/1/19.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "YFQRCodeReaderViewController.h"
#import "NSString+Additions.h"
#import "PHGroupHttpRequest.h"
#import "PHAppStartManager.h"

//界面子类
//#import "PHAddDetailMemberTableViewController.h"
#import "PHAddDetailGroupTableViewController.h"

#import "MBProgressHUD.h"

@interface YFQRCodeReaderViewController ()
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
}
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

#define kScanWinth [UIScreen mainScreen].bounds.size.width-10*4
#define kScanHeight [UIScreen mainScreen].bounds.size.height/2-100

#define kScanStr @"id="
@implementation YFQRCodeReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    
    
    self.view.frame =[UIScreen mainScreen].bounds;
    UILabel * labIntroudction= [[UILabel alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 50)];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.numberOfLines=0;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.textAlignment = UITextAlignmentCenter;
    labIntroudction.text=@"将二维码图像置于矩形方框内，离手机摄像头10CM左右，系统会自动识别。";
    [self.view addSubview:labIntroudction];
    
    
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"scan_x_ray"]];
    imageView.center = self.view.center;
    [self.view addSubview:imageView];
    
    upOrdown = NO;
    num =0;
    _line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scan_GridLine"]];
    _line.center = self.view.center;
    _lineFrame = _line.frame;
    _lineFrame.origin.y -= _line.frame.size.height;
    [self.view addSubview:_line];
    timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    //进入页面直接开始扫描
    [self startReading];
    
  
    //开始声音
//    [self loadBeepSound];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)animation1
{
    if (upOrdown == NO) {
        num +=3;
        CGRect tmpFrame = _line.frame;
        tmpFrame.origin.y += 3;
        _line.frame = tmpFrame;
        if (num >= _line.frame.size.height*2) {
            upOrdown = YES;
        }
    }
    else {
//        num -=2;
        num = 0;
//        CGRect tmpFrame = _lineFrame;
//        tmpFrame.origin.y -= _lineFrame.size.width ;
//        _lineFrame.origin.y -= _lineFrame.size.width;
        _line.frame = _lineFrame;
        upOrdown = NO;
    }
    
}
#pragma mark - 开启扫描
- (BOOL)startReading {
    NSError *error;

    // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
    // as the media type parameter.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Get an instance of the AVCaptureDeviceInput class using the previous device object.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        // If any error occurs, simply log the description of it and don't continue any more.
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // Initialize the captureSession object.
    _captureSession = [[AVCaptureSession alloc] init];
    // Set the input device on the capture session.
    [_captureSession addInput:input];
    
    
    // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];

    //阴影加入
    
//    CALayer* containerLayer = [CALayer layer];
//    containerLayer.shadowColor = [UIColor blackColor].CGColor;
//    containerLayer.shadowRadius = 10.f;
//    containerLayer.shadowOffset = CGSizeMake(0.f, 5.f);
//    containerLayer.shadowOpacity = 1.f;
//    
//    // use the image's layer to mask the image into a circle
//    _viewPreview.layer.cornerRadius = roundf(_viewPreview.frame.size.width/2.0);
//    _viewPreview.layer.masksToBounds = YES;
    
    // add masked image layer into container layer so that it's shadowed
//    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
//    [self.view.layer addSublayer:_viewPreview.layer];
    [self.view.layer insertSublayer:_viewPreview.layer atIndex:0];
    

    
    
    [_captureSession startRunning];
    
    return YES;
}
-(void)stopReading{
    // Stop video capture and make the capture session object nil.
    [_captureSession stopRunning];
    _captureSession = nil;
    
    // Remove the video preview layer from the viewPreview view's layer.
    [_videoPreviewLayer removeFromSuperlayer];
}

-(void)loadBeepSound{
    // Get the path to the beep.mp3 file and convert it to a NSURL object.
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    
    NSError *error;
    
    // Initialize the audio player object using the NSURL object previously set.
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        // If the audio player cannot be initialized then log a message.
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        // If the audio player was successfully initialized then load it in memory.
        [_audioPlayer prepareToPlay];
    }
}
#pragma mark - 扫描之后的委托
#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        // Get the metadata object.
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // If the found metadata is equal to the QR code metadata then update the status label's text,
            // stop reading and change the bar button item's title and the flag's value.
            // Everything is done on the main thread.
//            [_lblStatus performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
            NSString * scanStr =[metadataObj stringValue];
            NSLog(@"%@",scanStr);
            
            
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
//            [_bbitemStart performSelectorOnMainThread:@selector(setTitle:) withObject:@"Start!" waitUntilDone:NO];
            
            
            // If the audio player is not nil, then play the sound effect.
            if (_audioPlayer) {
                [_audioPlayer play];
            }
            //字符串判断 如果是 群 推入群简介 如果是 用户 推入用户 简介 如果是网页推入网页
            //正则匹配
            if ([scanStr isUrl]) {
                
                NSLog(@"url is %@",scanStr);
                //查找id
                NSRange range = [scanStr rangeOfString:kScanStr];
                if (range.length > 0) {
                    NSString * resultStr = [scanStr substringFromIndex:range.location+range.length];
                    
                    NSRange range2 = [resultStr rangeOfString:@"&"];
                    if (range2.location>0) {
                        NSString * keyid = [resultStr substringToIndex:range2.location];
                        NSString * keyType = [resultStr substringFromIndex:range2.location+6];//&type= 6个字符
                        MemberUserType memberType = (MemberUserType)[keyType integerValue];
                        NSNumber * number = [keyid asNumber];
                        //推入id 为 number 的 群或者用户
                        int GMid = [number intValue];
                        if (memberType==MemberUserTypeAdmin) {
                            //推入医院号的详情界面
                            
                            

                            
                        }else{
                            
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self requestAndPushMember:GMid];
                        });
                        

                        
                    }else{
                        NSLog(@"error");
                    }
                    

                }else{
                    //网页跳转
                    
                    //推入一个网页
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //
                        [self.navigationController popViewControllerAnimated:NO];
                        if ([self.delegate respondsToSelector:@selector(pushWebViewByDelegateNavi:)]) {
                            [self.delegate pushWebViewByDelegateNavi:[NSURL URLWithString:scanStr]];
                        }
                    });
                    
                }
            }else{
                //提示错误格式
            }
        }
    }
    
    
}
-(void)requestAndPushGroup:(unsigned)gid{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"载入中";
    
    [hud showAnimated:YES whileExecutingBlock:^{
        [PHGroupHttpRequest requestAllGroupUsersWithGid:gid done:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
                NSError *error;
                NSDictionary * dic = (NSDictionary *)responseObject;
                NSDictionary * groupDic = [[dic objectForKey:@"Result"]objectForKey:@"GroupInfo"];
                Group * tmpGroup = [MTLJSONAdapter modelOfClass:[Group class] fromJSONDictionary:groupDic error:&error];
                
                [self.navigationController popViewControllerAnimated:NO];
                if ([self.delegate respondsToSelector:@selector(pushAddViewByDelegateNavi:)]) {
                    [self.delegate pushAddViewByDelegateNavi:tmpGroup];
                }
                
                
                
            }
        } error:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
        }];
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
    
    
    
}
-(void)requestAndPushMember:(long long)memberId{
    
    [self.navigationController popViewControllerAnimated:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.margin = 10.f;
    hud.labelText = @"正在加载";
    
    [hud show:YES];
    [hud showAnimated:YES whileExecutingBlock:^{
        //推用户简介界面 http 获取用户详情
        [PHGroupHttpRequest requestMemberInfo:memberId done:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            if ([CommonUtil isValidateHttpResponseObject:responseObject]) {
                //获取member对象
                NSDictionary * memberDic = (NSDictionary *)responseObject;
                NSDictionary * resultDic = [memberDic objectForKey:@"Result"];
                NSError * error ;
                Member * member = [MTLJSONAdapter modelOfClass:[Member class] fromJSONDictionary:resultDic error:&error];
                //                [[PHAppStartManager defaultManager]popToTabBarControllerWithIndex:1];
                
                
                
                if ([self.delegate respondsToSelector:@selector(pushAddViewByDelegateNavi:)]) {
                    [self.delegate pushAddViewByDelegateNavi:member];
                }
                
                
            }
        } error:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            hud.labelText =@"网络错误";
            [hud hide:YES afterDelay:1];
        }];
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
    
    
    
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
