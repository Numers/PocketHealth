//
//  PHSexSelectView.m
//  PocketHealth
//
//  Created by macmini on 15-1-26.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHSexSelectView.h"
#define RadioButtonWidthAndHeight 17.0f
#define LabelHeight 21.0f
#define LabelWidth 20.0f
#define margin 15.0f

@implementation PHSexSelectView
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        sexManRadioBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, (frame.size.height - RadioButtonWidthAndHeight)/2, RadioButtonWidthAndHeight, RadioButtonWidthAndHeight)];
        [sexManRadioBtn addTarget:self action:@selector(clickManRadio) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sexManRadioBtn];
        
        lblSexMan = [[UILabel alloc] initWithFrame:CGRectMake(RadioButtonWidthAndHeight+5, (frame.size.height - LabelHeight)/2, LabelWidth, LabelHeight)];
        lblSexMan.text = @"男";
        [self addSubview:lblSexMan];
        
        sexWomanRadioBtn = [[UIButton alloc] initWithFrame:CGRectMake(lblSexMan.frame.origin.x + LabelWidth + margin, (frame.size.height - RadioButtonWidthAndHeight)/2, RadioButtonWidthAndHeight, RadioButtonWidthAndHeight)];
        [sexWomanRadioBtn addTarget:self action:@selector(clickWomanRadio) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sexWomanRadioBtn];
        
        lblSexWoman = [[UILabel alloc] initWithFrame:CGRectMake(sexWomanRadioBtn.frame.origin.x + RadioButtonWidthAndHeight+5, (frame.size.height - LabelHeight)/2, LabelWidth, LabelHeight)];
        lblSexWoman.text = @"女";
        [self addSubview:lblSexWoman];
    }
    return self;
}

-(void)clickManRadio
{
    [self selectSexManRadio];
}

-(void)clickWomanRadio
{
    [self selectSexWomanRadio];
}

-(void)selectSexManRadio
{
    if (selectSexCode != sexMan) {
        [self selectSex:sexMan];
        if ([self.delegate respondsToSelector:@selector(changeSexNotify:)]) {
            [self.delegate changeSexNotify:sexMan];
        }
    }
}

-(void)selectSexWomanRadio
{
    if (selectSexCode != sexWoman) {
        [self selectSex:sexWoman];
        if ([self.delegate respondsToSelector:@selector(changeSexNotify:)]) {
            [self.delegate changeSexNotify:sexWoman];
        }
    }
}

-(void)selectSex:(sexCode)code
{
    selectSexCode = code;
    if (code == sexMan) {
        [sexManRadioBtn setBackgroundImage:[UIImage imageNamed:@"monitoring-sexManSelectRadion"] forState:UIControlStateNormal];
        [sexWomanRadioBtn setBackgroundImage:[UIImage imageNamed:@"monitoring-sexNoSelectRadio"] forState:UIControlStateNormal];
    }
    
    else if (code == sexWoman) {
        [sexManRadioBtn setBackgroundImage:[UIImage imageNamed:@"monitoring-sexNoSelectRadio"] forState:UIControlStateNormal];
        [sexWomanRadioBtn setBackgroundImage:[UIImage imageNamed:@"monitoring-sexWomanSelectRadio"] forState:UIControlStateNormal];
    }
    
    else{
        [sexManRadioBtn setBackgroundImage:[UIImage imageNamed:@"monitoring-sexNoSelectRadio"] forState:UIControlStateNormal];
        [sexWomanRadioBtn setBackgroundImage:[UIImage imageNamed:@"monitoring-sexNoSelectRadio"] forState:UIControlStateNormal];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end