//
//  GroupMessageCell.h
//  ylmm
//
//  Created by macmini on 14-7-1.
//  Copyright (c) 2014年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class GroupMessageFrame;
@interface GroupMessageCell : UITableViewCell
{
    UIButton     *_timeBtn;
//    UIImageView *_iconView;
    UIButton    *_contentBtn;
    UIButton   *_iconViewBtn;
}

@property (nonatomic, strong) GroupMessageFrame *messageFrame;
@property (nonatomic,strong)UIImageView *iconView;
@property (nonatomic,strong)UIImageView *indentityIconView; //这个是用于群内的标识 群主 管理员身份
@property (nonatomic,strong) UILabel *labelNickName; //用户昵称显示

@property (nonatomic,strong) UIImageView *voiceNotReadRedPointView; //语音未读的红点
@property (nonatomic, assign) id<AVAudioPlayerDelegate> delegate;
@property (nonatomic, assign) SEL didTouch;
@property (nonatomic, assign) SEL didTouchIcon;
@property (nonatomic) NSInteger index;

@property (nonatomic, strong) UIActivityIndicatorView *juhua;

@property (nonatomic,strong) UIImageView *failedImg;



@end
