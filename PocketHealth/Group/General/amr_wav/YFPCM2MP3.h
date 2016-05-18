//
//  YFPCM2MP3.h
//  HZMedical
//
//  Created by YangFan on 14-8-14.
//
//

#import <Foundation/Foundation.h>

@interface YFPCM2MP3 : NSObject


+(NSString *)audio_PCMtoMP3WithSourceFileName:(NSString *)cafFilePath outPutFileName:(NSString *)outPutFile;
@end
