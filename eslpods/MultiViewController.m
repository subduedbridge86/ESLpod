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
@property MultipeerHost * myMulti;

@property AudioConverter *converter;
/////////

@property NSMutableArray * titleArray;
@property int nowPlayingIndex;
@property AVAudioPlayer *player;
@property NSMutableArray * URLarray;
@property NSInteger numberOfPeer;


@property NSTimer *timer;//数秒ごとにスライダーを更新させるため
@property int playback;//変換したendTimeを更新部に受け渡し
@property int maxback;//受け渡し先の残り時間計算
@property int currentsecond;//現在の秒
@property int currentminute;//現在の分
@property int endsecond;//残りの秒
@property int endminute;//残りの分
@property NSString *timestr;//現在の分:秒
@property NSString *maxtimelabelstr;//残りの分:秒


@property (weak, nonatomic) IBOutlet UITableView *StreamTable;
@property (weak, nonatomic) IBOutlet UILabel *StreamerLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *autoseek;

@end

@implementation MultiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startTimer];
    self.myMulti=[[MultipeerHost alloc]init];
    [self.myMulti startHost];
    self.converter=[[AudioConverter alloc]init];
    self.StreamTable.delegate=self;
    self.StreamTable.dataSource=self;
    self.titleArray=[[NSMutableArray alloc]init];
    self.URLarray=[[NSMutableArray alloc]init];
    for (int i = 0;i < self.mediaItemCollection.count; i++) {
        MPMediaItem *nameitem=[self.mediaItemCollection.items objectAtIndex:i];
        
     NSString*title=[nameitem valueForProperty:MPMediaItemPropertyTitle];
        [self.titleArray addObject:title];
        
        
    }
    [self.StreamTable reloadData];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        for (int i = 0;i < self.mediaItemCollection.count; i++) {
        MPMediaItem *item = [self.mediaItemCollection.items objectAtIndex:i];
        NSURL * url = [self convertItemtoAAC:item];
        [self.URLarray addObject:url];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLabelNum)
                                                 name:@"conn"
                                               object:self.myMulti];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeLabelNum)
                                                 name:@"disconn"
                                               object:self.myMulti];
    
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
//mediapicker関連

///tableView関連
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger dataCount;
    
    // テーブルに表示するデータ件数を返す
    dataCount = self.titleArray.count;
    
    return dataCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [self.StreamTable dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
    self.nowPlayingIndex=(int)indexPath.row;
    NSURL *url = [self.mediaItemCollection.items[self.nowPlayingIndex] valueForProperty:MPMediaItemPropertyAssetURL];
    NSString *songTitle=[self.mediaItemCollection.items[self.nowPlayingIndex] valueForProperty:MPMediaItemPropertyTitle];
    self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    [self.player prepareToPlay];
    [self.player play];
    NSData*data=[[NSData alloc]initWithContentsOfURL:self.URLarray[self.nowPlayingIndex]];
    [self.myMulti sendStr:@"sta"];
    [self.myMulti sendStr:songTitle];
    [NSThread sleepForTimeInterval:1.0];
    [self.myMulti sendData:data];
   
   
}

-(NSURL *)convertItemtoAAC:(MPMediaItem *)item{
   
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
    NSURL*SaveURL=[NSURL fileURLWithPath:savePath];
    NSString *ssavePath=[filePath stringByDeletingPathExtension];
    ssavePath=[ssavePath stringByAppendingPathExtension:@"aac"];
    NSURL*SsaveURL=[NSURL fileURLWithPath:ssavePath];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (exportSession.status == AVAssetExportSessionStatusCompleted) {
            NSLog(@"export session completed");
            
            NSLog(@"%@",exportSession.outputURL);
            
            UInt32 fileType;
            
            //変換するフォーマット
            AudioStreamBasicDescription outputFormat;
            memset(&outputFormat, 0, sizeof(AudioStreamBasicDescription));
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
            
            [self.converter convertFrom:exportSession.outputURL toURL:SaveURL format:outputFormat fileType:fileType];
            
            //変換するフォーマット
            AudioSessionInitialize(NULL, NULL, NULL, NULL);
            AudioSessionSetActive(YES);
            UInt32 audioCategory;
            audioCategory = kAudioSessionCategory_AudioProcessing;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                                    sizeof(audioCategory),
                                    &audioCategory);
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
            
          
            
        }else{
            NSLog(@"error");
        }
    }];
    
    return SsaveURL;
    
}

-(void)changeLabelNum{
    self.numberOfPeer=self.myMulti.mSession.connectedPeers.count;
    NSString*str=@"接続人数 ";
    NSString*numstr=[NSString stringWithFormat:@"%ld",(long)self.numberOfPeer];
    dispatch_async(
                   dispatch_get_main_queue(),
                   ^{
                       // ここに実行したいコード
                       self.StreamerLabel.text=[str stringByAppendingString:numstr];
                   }
                   );
    
}

-(void)startTimer{//数秒ごとにtimertextを呼び出す
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timertext) userInfo:nil repeats:YES];
    
    NSString *playbackstr=[NSString stringWithFormat:@"%f", _player.duration];
    _playback=playbackstr.intValue;
    _autoseek.maximumValue=_playback;
    
}
-(void)timertext{
    _currentsecond=fmodf(_player.currentTime,60);
    _currentminute=_player.currentTime/60;
    _timestr=[NSString stringWithFormat:@"%02d:%02d",_currentminute,_currentsecond];
    _currentTimeLabel.text=_timestr;
    
    _maxback=_playback-_player.currentTime;
    _endsecond=_maxback%60;
    _endminute=_maxback/60;
    _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",_endminute,_endsecond];
    _endTimeLabel.text=_maxtimelabelstr;
    [_autoseek setValue:_player.currentTime animated:YES];
    //autoseek.value=CMTimeGetSeconds(_avPlayer.currentTime);
}

@end
