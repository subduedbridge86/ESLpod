#import "ViewController.h"

@implementation ViewController
float ipodVol=0.01;
float systemVol=0;
long songCount=0;
int repeatCount=0;
int second,minute,maxsecond,maxminute,playback;
CMTime tm;
int senderval;
int maxback;

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
    [super viewDidLoad];
    UIImage *imageForThumb = [UIImage imageNamed:@"slider.png"];
    [autoseek setThumbImage:imageForThumb forState:UIControlStateNormal];
    [autoseek setThumbImage:imageForThumb forState:UIControlStateHighlighted];
    [self.view addSubview:autoseek]; 
    
    ttableView.delegate = self;
    ttableView.dataSource = self;
    
    mypod=[[ESLpod alloc]init];
    [mypod audioSession];
    
    [mypod feed];
    [mypod bufferSet];
    
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
    
    ipodVol = [ud floatForKey:@"ipodvol"];
    _avPlayer.volume=ipodVol;
    NSString *ipodVoltext = [NSString stringWithFormat:@"%.0f", ipodVol*2000];
    ipodVolLabel.text=ipodVoltext;
    _ipodvol.value=ipodVol;
    
    mypod.feedVol=[ud floatForKey:@"feedvol"];
    [mypod mixUnitvol];
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", mypod.feedVol*100];
    fbVolLabel.text=fbVoltext;
    _feedvol.value=mypod.feedVol;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        
    _nameData=[ud objectForKey:@"nameData"];
    
    _mediaitemData=[ud objectForKey:@"_mediaitemData"];
    songCount=[ud floatForKey:@"songCount"];
    [self AutoScroll];
    if (_mediaitemData!=NULL) {
        _mediaItemCollection2 = [NSKeyedUnarchiver unarchiveObjectWithData:_mediaitemData];
        MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:songCount];
        [self songtext];
        _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
        _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
        
        _avPlayer.volume=ipodVol;
        [self startTimer];
    }
    }
}

- (void)avPlayDidFinish:(NSNotification*)notification
{
    if(_mediaItemCollection2.count != 0){               //１曲以上選ばれているか
        if (songCount==_mediaItemCollection2.count-1) {//最後なら1曲目へ
            NSLog(@"次の曲通知");
            songCount=0;
            [self saveCount];
            
            [self nextandback];
            if ((repeatCount==2)||(repeatCount==1)) {
                [_avPlayer play];
            }else{
                [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            }
        }
        else{           //次の曲へ
            if (repeatCount==1) {
                
            }else{
            songCount++;
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
    
    songCount=0;
    [self saveCount];
    //曲名取得
    _mediaItemCollection2=mediaItemCollection;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
    _mediaitemData = [NSKeyedArchiver archivedDataWithRootObject:_mediaItemCollection2];
    NSUserDefaults *ud4=[NSUserDefaults standardUserDefaults];
    [ud4 setObject:_mediaitemData forKey:@"_mediaitemData"];
    }
    
    MPMediaItem *item = [mediaItemCollection.items objectAtIndex:0];
    [self songtext];
    
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];    //変換
    _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    _avPlayer.volume=ipodVol;
    [_avPlayer play];
    
    [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
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
    [ttableView reloadData];
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
    UITableViewCell *cell = [ttableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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
    songCount=(int)indexPath.row;
    [self saveCount];
    [self nextandbackplay];
    //[ttableView reloadData];
}


- (IBAction)backSong:(id)sender {
    if(_mediaItemCollection2 != 0){                     //１曲以上選ばれているか
        if (CMTimeGetSeconds(_avPlayer.currentTime)<2.9) {
            
            if (songCount==0) {                             //最初なら最後の曲へ
                songCount=_mediaItemCollection2.count-1;
                [self saveCount];
            }
            else {
                songCount--;    //前の曲へ
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
        
        if (songCount==_mediaItemCollection2.count-1) {//最後なら1曲目へ
            songCount=0;
            [self saveCount];
        }
        else{           //次の曲へ
            songCount++;
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
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    _avPlayer.volume=ipodVol;
    
}

-(void)nextandbackplay{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    _avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    _avPlayer.volume=ipodVol;
    
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
    ipodVol = sender.value;
    _avPlayer.volume=ipodVol;
    
    NSString *ipodVoltext = [NSString stringWithFormat:@"%.0f", ipodVol*2000];
    ipodVolLabel.text=ipodVoltext;
    
    NSUserDefaults *ud1=[NSUserDefaults standardUserDefaults];
    [ud1 setFloat:ipodVol forKey:@"ipodvol"];
}

- (IBAction)feedSliderChanged:(UISlider*)sender {   //フィードバック音のボリューム変更スライダー
    mypod.feedVol=sender.value;
    if (feedonoffstate.on) {
        [mypod mixUnitvol];
    }
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", mypod.feedVol*100];
    fbVolLabel.text=fbVoltext;
    
    NSUserDefaults *ud2=[NSUserDefaults standardUserDefaults];
    [ud2 setFloat:mypod.feedVol forKey:@"feedvol"];
}

- (IBAction)feedonoff:(UISwitch *)sender {
    if (sender.on) {
        [mypod feed];
        [mypod mixUnitvol];
    }else{
        [mypod auClose];
    }
}

-(void)saveCount{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
    NSUserDefaults *ud5=[NSUserDefaults standardUserDefaults];
    [ud5 setFloat:songCount forKey:@"songCount"];
    }
}
-(void)songtext{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:songCount];
    titlelabel.text =[item valueForProperty:MPMediaItemPropertyTitle];
    albumlabel.text =[item valueForProperty:MPMediaItemPropertyAlbumTitle];

    NSString *playbackstr=[item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    playback=playbackstr.intValue;
    autoseek.maximumValue=playback;
}
-(void)startTimer{
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timertext) userInfo:nil repeats:YES];
}
-(void)timertext{
    second=fmodf(CMTimeGetSeconds(_avPlayer.currentTime),60);
    minute=CMTimeGetSeconds(_avPlayer.currentTime)/60;
    _timestr=[NSString stringWithFormat:@"%02d:%02d",minute,second];
    timelabel.text=_timestr;

    
    maxback=playback-CMTimeGetSeconds(_avPlayer.currentTime);
    maxsecond=maxback%60;
    maxminute=maxback/60;
    _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",maxminute,maxsecond];
    maxtimelabel.text=_maxtimelabelstr;
    [autoseek setValue:CMTimeGetSeconds(_avPlayer.currentTime) animated:YES];
    //autoseek.value=CMTimeGetSeconds(_avPlayer.currentTime);
}
- (IBAction)seekslider:(UISlider *)sender {
    [_timer invalidate];
    tm= CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC);
    //timelabel.text=CMTimeGetSeconds(tm);
    
    if ([_avPlayer rate]==0) {  //曲が停止中なら再生
        [_avPlayer seekToTime:tm];
    }else{  //曲が再生中なら停止
        [_avPlayer pause];
        [_avPlayer seekToTime:tm];
        [_avPlayer play];
    }
    NSLog(@"%f",CMTimeGetSeconds(_avPlayer.currentTime));
    
    senderval=sender.value;
    second=senderval%60;
    minute=sender.value/60;
    _timestr=[NSString stringWithFormat:@"%02d:%02d",minute,second];
    timelabel.text=_timestr;
    maxback=playback-CMTimeGetSeconds(_avPlayer.currentTime);
    maxsecond=maxback%60;
    maxminute=maxback/60;
    _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",maxminute,maxsecond];
    maxtimelabel.text=_maxtimelabelstr;
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
    if (repeatCount==0) {//1
        repeatCount=1;
        [sender setTitle:@"1曲リピート" forState:UIControlStateNormal];
        _repeatbtn.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [_repeatbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else if (repeatCount==1){//all
        [sender setTitle:@"全曲リピート" forState:UIControlStateNormal];
        repeatCount=2;
        _repeatbtn.backgroundColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [_repeatbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{//non
        repeatCount=0;
        [sender setTitle:@"リピートなし" forState:UIControlStateNormal];
        _repeatbtn.backgroundColor = [UIColor clearColor];
        [_repeatbtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    }
}

-(void)AutoScroll{
    if (songCount<_nameData.count) {
        
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:songCount inSection:0];
        
        [ttableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}


@end
