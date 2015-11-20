//
//  MultiViewController.m
//  eslpods
//
//  Created by 椛島優 on 2015/11/20.
//  Copyright © 2015年 椛島優. All rights reserved.
//

#import "MultiViewController.h"

@interface MultiViewController ()
/////////
@property MPMusicPlayerController * controler;
@property MultipeerHost * myMulti;
@property StreamingPlayer * StPlayer;
@property AudioConverter *converter;
/////////

@end

@implementation MultiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myMulti=[[MultipeerHost alloc]init];
    self.myMulti.delegate=self;
    self.StPlayer=[[StreamingPlayer alloc]init];
    [self.StPlayer start];
    self.converter=[[AudioConverter alloc]init];
    
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:0];
    
    
   
    NSURL *url=[item valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                           initWithAsset:urlAsset
                                           presetName:AVAssetExportPresetAppleM4A];
    
    exportSession.outputFileType = [[exportSession supportedFileTypes] objectAtIndex:0];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [[docDir stringByAppendingPathComponent:[item valueForProperty:MPMediaItemPropertyTitle]] stringByAppendingPathExtension:@"m4a"];
    NSString *savePath=[filePath stringByDeletingPathExtension];
    savePath=[savePath stringByAppendingPathExtension:@"caf"];
    exportSession.outputURL = [NSURL fileURLWithPath:filePath];
    
    [exportSession setTimeRange:CMTimeRangeMake(kCMTimeZero, [urlAsset duration])];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // ファイルを移動
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:savePath error:nil];
    
    // ディレクトリを作成
    [fileManager createDirectoryAtPath:docDir
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
    
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"export session completed");
            
            NSLog(@"%@",exportSession.outputURL);
            NSURL*SaveURL=[NSURL fileURLWithPath:savePath];
            UInt32 fileType;
            
            //変換するフォーマット
            AudioStreamBasicDescription outputFormat;
            memset(&outputFormat, 0, sizeof(AudioStreamBasicDescription));
            
            if(1)
            {
                outputFormat.mSampleRate		= 44100.0;
                outputFormat.mFormatID			= kAudioFormatLinearPCM;
                outputFormat.mFormatFlags		= kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
                outputFormat.mFramesPerPacket	= 1;
                outputFormat.mChannelsPerFrame	= 2;
                outputFormat.mBitsPerChannel	= 16;
                outputFormat.mBytesPerPacket	= 4;
                outputFormat.mBytesPerFrame		= 4;
                outputFormat.mReserved			= 0;
                fileType = kAudioFileCAFType;
            }
            
            [self.converter convertFrom:exportSession.outputURL toURL:SaveURL format:outputFormat fileType:fileType];
            
            //変換するフォーマット
            
            
            AudioSessionInitialize(NULL, NULL, NULL, NULL);
            AudioSessionSetActive(YES);
            UInt32 audioCategory;
            audioCategory = kAudioSessionCategory_AudioProcessing;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                    sizeof(audioCategory),
                                    &audioCategory);
            
            NSString *ssavePath=[filePath stringByDeletingPathExtension];
            ssavePath=[ssavePath stringByAppendingPathExtension:@"aac"];
            NSURL*SsaveURL=[NSURL fileURLWithPath:ssavePath];
            
            //変換するフォーマット(AAC)
            
            memset(&outputFormat, 0, sizeof(AudioStreamBasicDescription));
            outputFormat.mSampleRate       = 44100.0;
            outputFormat.mFormatID         = kAudioFormatMPEG4AAC;//AAC
            outputFormat.mChannelsPerFrame = 1;
            
            UInt32 size = sizeof(AudioStreamBasicDescription);
            AudioFormatGetProperty(kAudioFormatProperty_FormatInfo,
                                   0, NULL,
                                   &size,
                                   &outputFormat);
            
            ExtAudioConverter *extConverter = [[ExtAudioConverter alloc]init];
            [extConverter convertFrom:SaveURL toURL:SsaveURL format:outputFormat];
            
            audioCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                    sizeof(audioCategory),
                                    &audioCategory);
            
            NSData*data=[[NSData alloc]initWithContentsOfURL:SsaveURL];
            [self.myMulti sendData:data];
        }else{
            NSLog(@"error");
        }
    }];
    
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)StreamBtnTap:(id)sender {
    [self.myMulti startHost];
}

- (IBAction)ListenBtnTap:(id)sender {
    [self.myMulti startClient];
}
-(void)recvDataPacket:(NSData *)data{
    [self.StPlayer recvAudio:data];
}

@end
