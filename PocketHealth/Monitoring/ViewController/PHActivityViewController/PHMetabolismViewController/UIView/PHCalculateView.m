//
//  PHCalculateView.m
//  PocketHealth
//
//  Created by macmini on 15-1-27.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "PHCalculateView.h"
#define ButtomHeight 50.f
#define Margin 8.f

@implementation PHCalculateView
- (IBAction)clickCalculateBtn:(id)sender {
    if ([self.delegate respondsToSelector:@selector(calculate)]) {
        [self.delegate calculate];
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
