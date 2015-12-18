#import "ViewController.h"

@interface ViewController()
@property float ipodVol;
@property float systemVol;
@property long songCount;
@property int repeatCount;
@property int second;
@property int minute;
@property int maxsecond;
@property int maxminute;
@property int playback;
@property CMTime tm;
@property int senderval;
@property int maxback;

@property MPMusicPlayerController *player;

@property AVQueuePlayer *avPlayer;
@property NSURL *url;
@property AVPlayerItem *playerItem;
@property MPMediaItemCollection *mediaItemCollection2;
//@property NSNotificationCenter *notification;
@property NSArray *nameData;
@property NSData *mediaitemData;
@property NSTimer *timer;
@property NSString *maxtimelabelstr;
@property NSString *timestr;
@property NSString *name1,*name2;

@property ESLpod *mypod,*mypod2;
//@property NSArray *mypodArray;

@property (weak, nonatomic) IBOutlet UITableView *songList;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *albumlabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *maxtimelabel;
@property (weak, nonatomic) IBOutlet UISlider *autoseek;
@property (weak, nonatomic) IBOutlet UIButton *playImage;

@property (weak, nonatomic) IBOutlet UILabel *ipodVolLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbVolLabel;

@property (weak, nonatomic) IBOutlet UISwitch *feedonoffstate;
@property (weak, nonatomic) IBOutlet UIButton *repeatbtn;

@property (weak, nonatomic) IBOutlet UISlider *ipodvol;
@property (weak, nonatomic) IBOutlet UISlider *feedvol;

@end

@implementation ViewController


#define feedTimes 3
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
/* Usage
 if (SYSTEM_VERSION_LESS_THAN(@"4.0")) {
 ...
 }
 
 if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.1")) {
 ...
 }*/

- (void)viewDidLoad
{
    _ipodVol=0.01;
    _systemVol=0;
    _songCount=0;
    _repeatCount=0;
    
    [super viewDidLoad];
    UIImage *imageForThumb = [UIImage imageNamed:@"slider.png"];
    [_autoseek setThumbImage:imageForThumb forState:UIControlStateNormal];
    [_autoseek setThumbImage:imageForThumb forState:UIControlStateHighlighted];
    [self.view addSubview:_autoseek]; 
    
    _songList.delegate = self;
    _songList.dataSource = self;

        _mypod=[[ESLpod alloc]init];
        [_mypod audioSession];
        [_mypod feed];
        [_mypod bufferSet];
    
    _mypod2=[[ESLpod alloc]init];
    [_mypod2 audioSession];
    [_mypod2 feed];
    [_mypod2 bufferSet];
    
    _player = [MPMusicPlayerController applicationMusicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeAudioSessionRoute:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(telephoneObserver:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(avPlayDidFinish:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
    ///前回のスラいだー値反映
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    
    _ipodVol = [ud floatForKey:@"ipodvol"];
    _avPlayer.volume=_ipodVol;
    NSString *ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*20000];
    _ipodVolLabel.text=ipodVoltext;
    _ipodvol.value=_ipodVol;
    
    _mypod.feedVol=[ud floatForKey:@"feedvol"];
    _mypod2.feedVol=[ud floatForKey:@"feedvol"];
    
    [_mypod mixUnitvol];
    [_mypod2 mixUnitvol];
    
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", _mypod.feedVol*100];
    _fbVolLabel.text=fbVoltext;
    _feedvol.value=_mypod.feedVol;
    

        
    _nameData=[ud objectForKey:@"nameData"];
    
    _mediaitemData=[ud objectForKey:@"_mediaitemData"];
    _songCount=[ud floatForKey:@"songCount"];
    [self AutoScroll];

        _mediaItemCollection2 = [NSKeyedUnarchiver unarchiveObjectWithData:_mediaitemData];
        MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
        [self songtext];
        _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
        _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
        
        _avPlayer.volume=_ipodVol;
        [self startTimer];
    
    
}

- (void)avPlayDidFinish:(NSNotification*)notification
{
    if(_mediaItemCollection2.count != 0){               //１曲以上選ばれているか
        if (_songCount==_mediaItemCollection2.count-1) {//最後なら1曲目へ
            NSLog(@"次の曲通知");
            _songCount=0;
            [self saveCount];
            
            [self nextandback];
            if ((_repeatCount==2)||(_repeatCount==1)) {
                [_avPlayer play];
            }else{
                [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            }
        }
        else{           //次の曲へ
            if (_repeatCount==1) {
                
            }else{
            _songCount++;
            }
            [self saveCount];
            [self nextandbackplay];
        }
        
    }
}


- (void)didChangeAudioSessionRoute:(NSNotification *)notification
{
    // ヘッドホンが刺さっていたか取得
    BOOL (^isJointHeadphone)(NSArray *) = ^(NSArray *outputs){
        for (AVAudioSessionPortDescription *desc in outputs) {
            if ([desc.portType isEqual:AVAudioSessionPortHeadphones]) {
                return YES;
            }
        }
        return NO;
    };
    
    // 直前の状態を取得
    AVAudioSessionRouteDescription *prevDesc = notification.userInfo[AVAudioSessionRouteChangePreviousRouteKey];
    
    if (isJointHeadphone([[[AVAudioSession sharedInstance] currentRoute] outputs])) {
        if (!isJointHeadphone(prevDesc.outputs)) {
            NSLog(@"ヘッドフォンが刺さった");
        }
    } else {
        if(isJointHeadphone(prevDesc.outputs)) {
            NSLog(@"ヘッドフォンが抜かれた");
            [_avPlayer pause];
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
        }
    }
}

-(void)telephoneObserver:(NSNotification *)notification{
    NSDictionary* userInfo = notification.userInfo;
    
    AVAudioSessionInterruptionType audioSessionInterruptionType = [userInfo[@"AVAudioSessionInterruptionTypeKey"] longValue];
    switch (audioSessionInterruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"割り込みの開始！");
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            [_avPlayer pause];
            break;
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"割り込みの終了！");
            [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
            [_avPlayer play];
            break;
            
        default:
            break;
    }
}

- (IBAction)pick:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
    
    picker.delegate = self;
    
    picker.allowsPickingMultipleItems = YES;        // 複数選択可
    
    [self presentViewController:picker animated:YES completion:nil];    //Libraryを開く
    
    
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];     //キャンセルで曲選択を終わる
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection       //曲選択後
{
    [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
    _songCount=0;
    [self saveCount];
    //曲名取得
    _mediaItemCollection2=mediaItemCollection;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
    _mediaitemData = [NSKeyedArchiver archivedDataWithRootObject:_mediaItemCollection2];
    NSUserDefaults *ud4=[NSUserDefaults standardUserDefaults];
    [ud4 setObject:_mediaitemData forKey:@"_mediaitemData"];
    }

    [self songtext];
     MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:0];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];    //変換
    _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    _avPlayer.volume=_ipodVol;
   // [_avPlayer play];

   // [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];

    _nameData=[[NSArray alloc]init];
    for (int i = 0;i < _mediaItemCollection2.count; i++) {
        MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
        
        _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
        _name2=[[nameitem1 valueForProperty:MPMediaItemPropertyAlbumTrackNumber]stringValue];

        NSString* str1 = [NSString stringWithFormat: @"%4@", _name2];
        NSLog(@"%@",str1);
        
        _nameData=[_nameData arrayByAddingObject:_name1];
        
        
        
        //NSLog(@"%@",[_nameData objectAtIndex:i]);
        NSLog(@"%@　%@",[[_mediaItemCollection2.items objectAtIndex:i]valueForProperty:MPMediaItemPropertyAlbumTrackNumber],[_nameData objectAtIndex:i]);
        
    }
    [_songList reloadData];
    [self AutoScroll];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
    NSUserDefaults *ud3=[NSUserDefaults standardUserDefaults];
    [ud3 setObject:_nameData forKey:@"nameData"];
    }
    
    [self startTimer];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger dataCount;
    
    // テーブルに表示するデータ件数を返す
    dataCount = self.nameData.count;
    
    return dataCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [_songList dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.nameData[indexPath.row];
    
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",(long)indexPath.row);
    _songCount=(int)indexPath.row;
    [self saveCount];
    [self nextandbackplay];
    //[ttableView reloadData];
}


- (IBAction)backSong:(id)sender {
    if(_mediaItemCollection2 != 0){                     //１曲以上選ばれているか
        if (CMTimeGetSeconds(_avPlayer.currentTime)<2.9) {
            
            if (_songCount==0) {                             //最初なら最後の曲へ
                _songCount=_mediaItemCollection2.count-1;
                [self saveCount];
            }
            else {
                _songCount--;    //前の曲へ
                [self saveCount];
            }
            
            if ([_avPlayer rate]==0) {  //曲が停止中なら停止
                [self nextandback];
            }else{  //曲が再生中なら停止
                [self nextandbackplay];
            }
        }
        else{[_avPlayer seekToTime:CMTimeMake(0, 600)];}
    }
    
}

- (IBAction)nextSong:(id)sender {
    
    
    //NSLog(@"%lu",(unsigned long)_mediaItemCollection2.count);
    if(_mediaItemCollection2.count != 0){               //１曲以上選ばれているか
        
        if (_songCount==_mediaItemCollection2.count-1) {//最後なら1曲目へ
            _songCount=0;
            [self saveCount];
        }
        else{           //次の曲へ
            
            if (_repeatCount!=1) {
            _songCount++;
            }
            
            [self saveCount];
        }
        if ([_avPlayer rate]==0) {  //曲が停止中なら停止
            [self nextandback];
        }else{  //曲が再生中なら停止
            [self nextandbackplay];
        }
        
        
    }
}

-(void)nextandback{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    _avPlayer.volume=_ipodVol;
    
}

-(void)nextandbackplay{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    _avPlayer.volume=_ipodVol;
    
    [_avPlayer play];
    [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
    
    
}


- (IBAction)pushPlay:(id)sender {
    if (_avPlayer!=nil){
        if ([_avPlayer rate]==0) {  //曲が停止中なら再生
            [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
            [_avPlayer play];
        }else{  //曲が再生中なら停止
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            [_avPlayer pause];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)ipodSliderChanged:(UISlider*)sender {   //曲のボリューム変更スライダー
    _ipodVol = sender.value;
    _avPlayer.volume=_ipodVol;
    
    NSString *ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*20000];
    _ipodVolLabel.text=ipodVoltext;
    
    NSUserDefaults *ud1=[NSUserDefaults standardUserDefaults];
    [ud1 setFloat:_ipodVol forKey:@"ipodvol"];
}

- (IBAction)feedSliderChanged:(UISlider*)sender {   //フィードバック音のボリューム変更スライダー
    _mypod.feedVol=sender.value;
    _mypod2.feedVol=sender.value;
    if (_feedonoffstate.on) {

        [_mypod mixUnitvol];
        [_mypod2 mixUnitvol];
        
    }
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", _mypod.feedVol*100];
    _fbVolLabel.text=fbVoltext;
    
    NSUserDefaults *ud2=[NSUserDefaults standardUserDefaults];
    [ud2 setFloat:_mypod.feedVol forKey:@"feedvol"];
}

- (IBAction)feedonoff:(UISwitch *)sender {
    if (sender.on) {
            _mypod=[[ESLpod alloc]init];
            [_mypod audioSession];
            [_mypod feed];
            [_mypod bufferSet];
        _feedvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        _fbVolLabel.textColor=[UIColor blackColor];
    }else{
        [_mypod auClose];
        _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
        _fbVolLabel.textColor=[UIColor lightGrayColor];
    }
}

-(void)saveCount{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
    NSUserDefaults *ud5=[NSUserDefaults standardUserDefaults];
    [ud5 setFloat:_songCount forKey:@"songCount"];
    }
}
-(void)songtext{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    _titlelabel.text =[item valueForProperty:MPMediaItemPropertyTitle];
    _albumlabel.text =[item valueForProperty:MPMediaItemPropertyAlbumTitle];

    NSString *playbackstr=[item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    _playback=playbackstr.intValue;
    _autoseek.maximumValue=_playback;
}
-(void)startTimer{
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timertext) userInfo:nil repeats:YES];
}
-(void)timertext{
    _second=fmodf(CMTimeGetSeconds(_avPlayer.currentTime),60);
    _minute=CMTimeGetSeconds(_avPlayer.currentTime)/60;
    _timestr=[NSString stringWithFormat:@"%02d:%02d",_minute,_second];
    _timelabel.text=_timestr;

    
    _maxback=_playback-CMTimeGetSeconds(_avPlayer.currentTime);
    _maxsecond=_maxback%60;
    _maxminute=_maxback/60;
    _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",_maxminute,_maxsecond];
    _maxtimelabel.text=_maxtimelabelstr;
    [_autoseek setValue:CMTimeGetSeconds(_avPlayer.currentTime) animated:YES];
    //autoseek.value=CMTimeGetSeconds(_avPlayer.currentTime);
}
- (IBAction)seekslider:(UISlider *)sender {
    [_timer invalidate];
    _tm= CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC);
    //timelabel.text=CMTimeGetSeconds(tm);
    
    if ([_avPlayer rate]==0) {  //曲が停止中なら再生
        [_avPlayer seekToTime:_tm];
    }else{  //曲が再生中なら停止
        [_avPlayer pause];
        [_avPlayer seekToTime:_tm];
        [_avPlayer play];
    }
    NSLog(@"%f",CMTimeGetSeconds(_avPlayer.currentTime));
    
    _senderval=sender.value;
    _second=_senderval%60;
    _minute=sender.value/60;
    _timestr=[NSString stringWithFormat:@"%02d:%02d",_minute,_second];
    _timelabel.text=_timestr;
    _maxback=_playback-CMTimeGetSeconds(_avPlayer.currentTime);
    _maxsecond=_maxback%60;
    _maxminute=_maxback/60;
    _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",_maxminute,_maxsecond];
    _maxtimelabel.text=_maxtimelabelstr;
   // autoseek.value=sender.value;
}


- (IBAction)feedUp:(UISlider *)sender {
    if (![_timer isValid]) {
//        tm = CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC);
//        [_avPlayer seekToTime:tm];
//        autoseek.value=sender.value;

        //[NSThread sleepForTimeInterval:1];
        [self startTimer];
        NSLog(@"aaaaaaaaaa%f",CMTimeGetSeconds(_avPlayer.currentTime));
    }
    

}

- (IBAction)repeatButton:(UIButton *)sender {
    NSLog(@"repeat押した");
    if (_repeatCount==0) {//1
        _repeatCount=1;
        [sender setTitle:@"1曲リピート" forState:UIControlStateNormal];
        _repeatbtn.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [_repeatbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if (_repeatCount==1){//all
        [sender setTitle:@"全曲リピート" forState:UIControlStateNormal];
        _repeatCount=2;
        _repeatbtn.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [_repeatbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{//non
        _repeatCount=0;
        [sender setTitle:@"リピートなし" forState:UIControlStateNormal];
        _repeatbtn.backgroundColor = [UIColor clearColor];
        [_repeatbtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    }
}

-(void)AutoScroll{
    if (_songCount<_nameData.count) {
        
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_songCount inSection:0];
        
        [_songList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (IBAction)BackToTheFirst:(id)sender {
    [_avPlayer pause];

    [_mypod auClose];
    [_mypod2 auClose];
//自分たち用
    
}

@end
