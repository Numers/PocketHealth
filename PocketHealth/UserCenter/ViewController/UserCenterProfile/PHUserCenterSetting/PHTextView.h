//
//  PHTextView.h
//  PocketHealth
//
//  Created by macmini on 15-2-2.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PHTextView : UIView<UITextViewDelegate>
{
    UILabel *placeHolderLabel;
    UITextView *myTextView;
}
@property(nonatomic, strong) NSString *placeHolder;
-(void)inilizedView;
-(NSString *)text;
@end
