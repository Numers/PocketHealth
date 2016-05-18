//
//  GroupMessageFrame.m
//  PocketHealth
//
//  Created by YangFan on 15/1/7.
//  Copyright (c) 2015年 YiLiao. All rights reserved.
//

#import "GroupMessageFrame.h"
#import "GroupMessage.h"
#import "CommonUtil.h"

@implementation GroupMessageFrame
- (void)setMessage:(GroupMessage *)message{
    
    _message = message;
    //    _messageLabel=nil;
    
    
    // 0、获取屏幕宽度
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    // 1、计算时间的位置
    if (_showTime){
        
        CGFloat timeY = kMargin;
        //        CGSize timeSize = [_message.time sizeWithAttributes:@{UIFontDescriptorSizeAttribute: @"16"}];
        NSString *timeStr = [NSString stringWithString:[CommonUtil TimeStrWithInterval:_message.time]];
        CGSize timeSize = [timeStr sizeWithFont:kTimeFont];
        
        NSLog(@"----%@", NSStringFromCGSize(timeSize));
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + kTimeMarginW, timeSize.height + kTimeMarginH);
    }
    // 2、计算头像位置
    CGFloat iconX = kMargin;
    // 2.1 如果是自己发得，头像在右边
    if (_message.type == MessageTypeMe) {
        iconX = screenW - kMargin - kIconWH;
    }
    
    CGFloat iconY = CGRectGetMaxY(_timeF) + kMargin;
    _iconF = CGRectMake(iconX, iconY, kIconWH, kIconWH);
    
    // 3、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF) + kMargin;
    CGFloat contentY = iconY;
    CGSize contentSize;
    if (_message.code == MessageCodeGroupText||_message.code==MessageCodeJoinGroup) {
//        MessageContentType type = [_message messageContentType];
        
        MessageContentType type = _message.contentType;
        if (type == MessageContentText) {
            _messageLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
            [self creatAttributedLabel:_message.content Label:_messageLabel];
//            [self createAttributedLabel:_messageLabel WithContentStr:_message.content];
            
            
            contentSize = CGSizeMake(CGRectGetWidth(_messageLabel.frame), CGRectGetHeight(_messageLabel.frame));
        }else if (type == MessageContentVoice){
            NSTimeInterval timelength = 0;
            NSArray *array = [_message.content componentsSeparatedByString:@".amr|"];
            if ((array != nil) || (array.count >= 2)) {
                timelength = [[array lastObject] doubleValue];
            }
            float w = (320-kIconWH-kMargin*2-50)/30;
            w = 50+w*timelength;
            if(w<50)
                w = 50;
            if(w>200)
                w = 200;
            
            contentSize = CGSizeMake(w, 19);
        }else if(type == MessageContentImage){
            contentSize = CGSizeMake(80, 100);
        }
        else if (type==MessageContentRedPacket){
            contentSize=CGSizeMake(200, 80);
        }else if (type == MessageContentAddGroupMember||type == MessageContentRemoveAdmin||type==MessageContentRemoveGroupMember||type==MessageContentAddAdmin){
            _messageLabel = (OHAttributedLabel *)[[UILabel alloc]initWithFrame:CGRectZero];
            [self createAttributedLabel:_messageLabel WithContentStr:_message.content];
            contentSize = CGSizeMake(CGRectGetWidth(_messageLabel.frame), CGRectGetHeight(_messageLabel.frame));

        }
    }
    if (_message.type == MessageTypeMe) {
        contentX = iconX - kMargin - contentSize.width - kContentLeft - kContentRight;
    }
    
    _contentF = CGRectMake(contentX, contentY, contentSize.width + kContentLeft + kContentRight, contentSize.height + kContentTop + kContentBottom);
    
    // 4、计算高度
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_iconF))  + kMargin;
}

-(void)creatAttributedLabel:(NSString *)text Label:(OHAttributedLabel *)label{
    [label setNeedsDisplay];
    
    NSMutableArray *httpArr = [CustomMethod addHttpArr:text];
    NSMutableArray *phoneNumArr = [CustomMethod addPhoneNumArr:text];
    NSMutableArray *emailArr = [CustomMethod addEmailArr:text];
    
    NSString *expressionPlistPath = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    NSDictionary *expressionDic   = [[NSDictionary alloc]initWithContentsOfFile:expressionPlistPath];
    
    NSString *o_text = [CustomMethod transformString:text emojiDic:expressionDic];
    o_text = [NSString stringWithFormat:@"<font color='black' strokeColor='gray' face='Palatino-Roman'>%@",o_text];
    
    MarkUpParser *wk_markupParser = [[MarkUpParser alloc] init];
    NSMutableAttributedString* attString = [wk_markupParser attrStringFromMarkUp:o_text];
    NSRange range;
    range.location = 0;
    range.length = attString.length;
    if (_message.type == MessageTypeMe){
        [attString setTextColor:[UIColor whiteColor] range:range];
    }else{
        [attString setTextColor:[UIColor blackColor] range:range];
    }
    [attString setFont:[UIFont systemFontOfSize:16]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setAttString:attString withImages:wk_markupParser.images];
    
    NSString *string = attString.string;
    
    if ([emailArr count])
    {
        for (NSString *emailStr in emailArr)
        {
            [label addCustomLink:[NSURL URLWithString:emailStr] inRange:[string rangeOfString:emailStr]];
        }
    }
    
    if ([phoneNumArr count])
    {
        for (NSString *phoneNum in phoneNumArr)
        {
            [label addCustomLink:[NSURL URLWithString:phoneNum] inRange:[string rangeOfString:phoneNum]];
        }
    }
    if ([httpArr count])
    {
        for (NSString *httpStr in httpArr)
        {
            [label addCustomLink:[NSURL URLWithString:httpStr] inRange:[string rangeOfString:httpStr]];
        }
    }
    label.delegate = self;
    
    CGRect labelRect = label.frame;
    labelRect.size.width = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].width;
    labelRect.size.height = [label sizeThatFits:CGSizeMake(200, CGFLOAT_MAX)].height;
    
    label.frame = labelRect;
    
    label.underlineLinks = NO;
    [label.layer display];
}
-(void)createAttributedLabel:(UILabel *)attrLabel WithContentStr:(NSString *)contentStr{
    attrLabel.numberOfLines = 0;
    UIFont * font = [UIFont systemFontOfSize:14];
    NSDictionary *attributesDictionary;
    if (_message.type == MessageTypeMe){
        attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,[UIColor whiteColor],NSForegroundColorAttributeName,
                                nil];
    }else{
        attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,[UIColor blackColor],NSForegroundColorAttributeName,
                                nil];
    }
    
    //    //如果有图片之类的匹配
    //    NSString *expressionPlistPath = [[NSBundle mainBundle]pathForResource:@"expression" ofType:@"plist"];
    //    NSDictionary *expressionDic   = [[NSDictionary alloc]initWithContentsOfFile:expressionPlistPath];
    //
    //    NSString *o_text = [CustomMethod transformString:contentStr emojiDic:expressionDic];
    
    //    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    //    attachment.image = [UIImage imageNamed:@"Expression_11@2x.png"];
    //    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    //    [myString appendAttributedString:attachmentString];
    
    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:contentStr attributes:attributesDictionary];
    attrLabel.bounds =[self sizeWithString:myString];
    attrLabel.attributedText = myString;
    
}
// 定义成方法方便多个label调用 增加代码的复用性
- (CGRect)sizeWithString:(NSAttributedString *)string
{
    //    NSRange range =NSMakeRange(0,string.length );
    //    NSDictionary *dic = [string attributesAtIndex:0 effectiveRange:&range];//获取该段attstr的属性字典
    
    
    CGRect paragraphRect =
    [string boundingRectWithSize:CGSizeMake(200.f, CGFLOAT_MAX)
                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 context:nil];
    
    //    CGRect frame = cell.textLabel.frame;
    //    [cell.textLabelsetFrame:CGRectMake(frame.origin.x,frame.origin.y, size.width, size.height)];
    
    return paragraphRect;
}
@end