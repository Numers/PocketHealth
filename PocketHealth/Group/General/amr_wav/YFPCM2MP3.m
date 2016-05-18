//
//  YFPCM2MP3.m
//  HZMedical
//
//  Created by YangFan on 14-8-14.
//
//

#import "YFPCM2MP3.h"
#import "lame.h"

@implementation YFPCM2MP3

+(NSString *)audio_PCMtoMP3WithSourceFileName:(NSString *)cafFilePath outPutFileName:(NSString *)outPutFile
{
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:outPutFile error:nil])
    {
        
        //        NSLog(@"删除");
    }
    if (![fileManager fileExistsAtPath:outPutFile]) {
        [fileManager createFileAtPath:outPutFile contents:nil attributes:nil];
    }
    
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);//skip file header
        
        FILE *mp3 = fopen([outPutFile cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        
        SInt64 total = 0;
        for (int i = 0; i < PCM_SIZE / 2; i++)
        {
            total += abs(((SInt16 *)pcm_buffer)[i]);
        }
        //        averageSample  =  sin(M_PI * abs(total * 6 / PCM_SIZE) / 32767 / 2) * 20.0f;
        
        //        NSLog(@"--------------------------------------------avager:%lf",averageSample);
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        return outPutFile;
    }
}
@end
