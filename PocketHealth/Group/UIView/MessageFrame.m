//
//  MessageFrame.m
//  15-QQ聊天布局
//
//  Created by Liu Feng on 13-12-3.
//  Copyright (c) 2013年 Liu Feng. All rights reserved.
//



#import "MessageFrame.h"
#import "OneForOneMessage.h"
#import "CommonUtil.h"

@implementation MessageFrame

- (void)setMessage:(OneForOneMessage *)message{
    
    _message = message;
    
    // 0、获取屏幕宽度
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    // 1、计算时间的位置
    if (_showTime){
        
        CGFloat timeY = kMargin;
//        CGSize timeSize = [_message.time sizeWithAttributes:@{UIFontDescriptorSizeAttribute: @"16"}];
        NSString *timeStr = [CommonUtil TimeStrWithInterval:message.time];
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
    if (_message.code == MessageCodeText) {
        MessageContentType type = [_message messageContentType];
        if (type == MessageContentText) {
            //modify by yangfan
//            _messageLabel = [[OHAttributedLabel alloc]initWithFrame:CGRectZero];
//            [self creatAttributedLabel:message.content Label:_messageLabel];
            _messageLabel = [[UILabel alloc]initWithFrame:CGRectZero];
            [self createAttributedLabel:_messageLabel WithContentStr:_message.content];
            
            
            
            NSLog(@"%f %f",_messageLabel.bounds.size.width , _messageLabel.bounds.size.height);
            
            
            contentSize = CGSizeMake(CGRectGetWidth(_messageLabel.frame), CGRectGetHeight(_messageLabel.frame));
        }else if (type == MessageContentVoice){
            NSTimeInterval timelength = 0;
            NSArray *array = [_message.content componentsSeparatedByString:@".amr|"];
            if ((array != nil) || (array.count >= 2)) {
                timelength = [[array lastObject] doubleValue];
            }
            float w = (320-kIconWH-kMargin*2-50)/30;
            w = 20+w*timelength;
            if(w<20)
                w = 20;
            if(w>170)
                w = 170;
            
            contentSize = CGSizeMake(w, 19);
        }else if(type == MessageContentImage){
            contentSize = CGSizeMake(80, 100);
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
//    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:contentStr attributes:attributesDictionary];
    
    
    NSAttributedString * myString = [[NSAttributedString alloc]initWithAttributedString:[CommonUtil transformAddFaceExpressionWithOrgstr:contentStr attributesWithDic:attributesDictionary] ];
//    //如果有图片之类的匹配
//    [myString appendAttributedString:[CommonUtil transformAddFaceExpressionWithOrgstr:contentStr]];
    
    
    
    
    
    
    attrLabel.bounds =[self sizeWithString:myString];
    attrLabel.attributedText = myString;
}
// 定义成方法方便多个label调用 增加代码的复用性
- (CGRect)sizeWithString:(NSAttributedString *)string
{
//    NSRange range =NSMakeRange(0,string.length );
//    NSDictionary *dic = [string attributesAtIndex:0 effectiveRange:&range];//获取该段attstr的属性字典
    
    
    CGRect paragraphRect =
    [string boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width*3/5, CGFLOAT_MAX)
                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 context:nil];
    
//    CGRect frame = cell.textLabel.frame;
//    [cell.textLabelsetFrame:CGRectMake(frame.origin.x,frame.origin.y, size.width, size.height)];
    paragraphRect.size.height = paragraphRect.size.height<20?20:paragraphRect.size.height;
    
    return paragraphRect;
}

@end
