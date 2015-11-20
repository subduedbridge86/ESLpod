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
@property MPMediaItemCollection *mediaItemCollection;
@property NSString * mediaTitle;
@property NSMutableArray * titleArray;
@property int nowPlayingIndex;
@property BOOL MediaSelectable;
@property (weak, nonatomic) IBOutlet UITableView *StreamTable;

@end

@implementation MultiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewdidload");
    self.myMulti=[[MultipeerHost alloc]init];
    self.myMulti.delegate=self;
    self.StPlayer=[[StreamingPlayer alloc]init];
    [self.StPlayer start];
    self.converter=[[AudioConverter alloc]init];
    self.MediaSelectable=NO;

    if (self.MediaSelectable) {
        MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
        
        picker.delegate = self;
        
        picker.allowsPickingMultipleItems = YES;        // 複数選択可
        
        [self presentViewController:picker animated:YES completion:nil];
    }
    
    

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
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];     //キャンセルで曲選択を終わる
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection       //曲選択後
{
    self.titleArray=[[NSMutableArray alloc]init];
    self.mediaItemCollection=mediaItemCollection;
    for (int i = 0;i < self.mediaItemCollection.count; i++) {
        MPMediaItem *nameitem1=[self.mediaItemCollection.items objectAtIndex:i];
        NSString*name = [nameitem1 valueForProperty:MPMediaItemPropertyTitle];
        [self.titleArray addObject:name];
    }
    [self.myMulti startHost];
}
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
    NSLog(@"%ld",(long)indexPath.row);
    self.nowPlayingIndex=(int)indexPath.row;
    MPMediaItem *item = [_mediaItemCollection.items objectAtIndex:self.nowPlayingIndex];
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
    //[ttableView reloadData];
}

- (IBAction)StreamBtnTap:(id)sender {
    self.MediaSelectable=YES;
       //Libraryを開く

    
}

- (IBAction)ListenBtnTap:(id)sender {
    self.MediaSelectable=NO;
    [self.myMulti startClient];
}
-(void)recvDataPacket:(NSData *)data{
    [self.StPlayer recvAudio:data];
}

@end
