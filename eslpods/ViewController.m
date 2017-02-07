#import "ViewController.h"
//lightning
@interface ViewController()
@property float ipodVol;
//@property float speakerVol;
//@property float systemVol;
@property long songCount;
@property int repeatCount;
@property int rateCount;
@property float rateValue;
@property float getSecond;
@property int second;
@property int minute;
@property int maxsecond;
@property int maxminute;
@property int playback;
@property CMTime tm;
@property int senderval;
@property int maxback;
@property BOOL miccount;
@property float newValue;
@property float oldValue;
@property BOOL seekPlaying;
@property BOOL headphoneConnect;
@property NSString* ipodVoltext;
@property BOOL addFlag;
@property BOOL nextikuFlag;
@property BOOL mictuketetaFlag;

@property float lastplayfloat,laststopfloat;
@property CMTime lastplaytime,laststoptime;
@property BOOL lastplaying;

@property MPMusicPlayerController *player;


@property NSDictionary *songinfo;

@property AVAudioSessionPortDescription *desc;

//@property AVQueuePlayer *avPlayer;
@property NSURL *url;
@property AVPlayerItem *playerItem;
@property MPMediaItemCollection *mediaItemCollection2;
//@property NSNotificationCenter *notification;
@property NSMutableArray *nameData;
@property NSData *mediaitemData;
@property NSTimer *timer;
@property NSString *maxtimelabelstr;
@property NSString *timestr;
@property NSString *name1,*name2;

@property ESLpod *mypod1,*mypod2,*mypod3;
//@property NSArray *mypodArray;

@property (weak, nonatomic) IBOutlet UITableView *songList;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UILabel *albumlabel;
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *maxtimelabel;
@property (weak, nonatomic) IBOutlet UISlider *autoseek;
@property (weak, nonatomic) IBOutlet UILabel *musicIcon;

@property (weak, nonatomic) IBOutlet UIButton *playImage;
@property (weak, nonatomic) IBOutlet UIButton *micimage;
@property (weak, nonatomic) IBOutlet UIButton *repeatImage;

@property (weak, nonatomic) IBOutlet UIButton *rateButton;

@property (weak, nonatomic) IBOutlet UILabel *ipodVolLabel;
@property (weak, nonatomic) IBOutlet UILabel *fbVolLabel;
@property (weak, nonatomic) IBOutlet UILabel *delaytimeLabel;


@property (weak, nonatomic) IBOutlet UISlider *ipodvol;
@property (weak, nonatomic) IBOutlet UISlider *feedvol;
@property (weak, nonatomic) IBOutlet UISlider *delaytime;
@property (weak, nonatomic) IBOutlet UIButton *lastplay;
@property (weak, nonatomic) IBOutlet UISlider *lastplaytopslider;
@property (weak, nonatomic) IBOutlet UISlider *lastplaystopslider;
@property UIImage *imageForThumb;

@property UIBarButtonItem *editButton,*anotherButton;


@end

@implementation ViewController


#define feedTimes 3
#define IPOD_VOL 1000
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

-(void)addRemoteCommandCenter{
    MPRemoteCommandCenter *rcc = [MPRemoteCommandCenter sharedCommandCenter];
    [rcc.togglePlayPauseCommand addTarget:self action:@selector(avtoggle:)];
    [rcc.playCommand addTarget:self action:@selector(avplay:)];
    [rcc.pauseCommand addTarget:self action:@selector(avpause:)];
    [rcc.nextTrackCommand addTarget:self action:@selector(avnextTrack:)];
    [rcc.previousTrackCommand addTarget:self action:@selector(avprevTrack:)];
}

- (void)avtoggle:(MPRemoteCommandEvent*)event{
    NSLog(@"avtoggle");
    [self pushPlay];
}

- (void)avplay:(MPRemoteCommandEvent*)event{
    [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
    [self playwithRate];
    _seekPlaying=YES;
    
    [_mypod1 feed];
    [_mypod1 bufferSet];
    [_mypod1 mixUnitvol];
    [_mypod1 delayUnittime];
    [_mypod1 delayUnittime2];
    [_mypod1 delayUnittime3];
    [_mypod1 delayUnittime4];
    [_mypod1 delayUnittime5];
    [_mypod2 feed];
    [_mypod2 bufferSet];
    [_mypod2 mixUnitvol];
    [_mypod2 delayUnittime];
    [_mypod2 delayUnittime2];
    [_mypod2 delayUnittime3];
    [_mypod2 delayUnittime4];
    [_mypod2 delayUnittime5];
    [_mypod3 feed];
    [_mypod3 bufferSet];
    [_mypod3 mixUnitvol];
    [_mypod3 delayUnittime];
    [_mypod3 delayUnittime2];
    [_mypod3 delayUnittime3];
    [_mypod3 delayUnittime4];
    [_mypod3 delayUnittime5];
    
    _feedvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _fbVolLabel.textColor=[UIColor blackColor];
    _delaytime.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _delaytimeLabel.textColor=[UIColor blackColor];
    [_micimage setImage : [ UIImage imageNamed : @"miconbutton.png" ] forState : UIControlStateNormal];
    _miccount=YES;
}

- (void)avpause:(MPRemoteCommandEvent*)event{
    [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
    [avPlayer pause];
    _seekPlaying=NO;
    
    [_mypod1 auClose];
    [_mypod2 auClose];
    [_mypod3 auClose];

    _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
    _fbVolLabel.textColor=[UIColor lightGrayColor];
    _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
    _delaytimeLabel.textColor=[UIColor lightGrayColor];
    [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
    _miccount=NO;
}

- (void)avnextTrack:(MPRemoteCommandEvent*)event{
    [self nextsong];
}

- (void)avprevTrack:(MPRemoteCommandEvent*)event{
    [self backsong];
}

- (void)viewDidLoad
{
    self.title = @"";
    _editButton=self.editButtonItem;
    self.navigationItem.rightBarButtonItem =_editButton;
    _anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRow:)];
    self.navigationItem.leftBarButtonItem = _anotherButton;
    
    _lastplaytopslider.userInteractionEnabled=NO;
    _lastplaystopslider.userInteractionEnabled=NO;
    _imageForThumb = [UIImage imageNamed:@"slider_white.png"];
    [_lastplaytopslider setThumbImage:_imageForThumb forState:UIControlStateNormal];
    [_lastplaystopslider setThumbImage:_imageForThumb forState:UIControlStateNormal];
    
    _ipodVol=0.0;
    //_systemVol=0;書いたらスライダーの色が変わらなくなる
    _songCount=0;
    _miccount=YES;
    _addFlag=NO;
    _rateValue=1;
    _laststopfloat=0;
    [self lastplaydisable];
    [self resetlastplayslider];
    _nextikuFlag=YES;
    _lastplaying=NO;

    
    [super viewDidLoad];
    _imageForThumb = [UIImage imageNamed:@"slider.png"];
    [_autoseek setThumbImage:_imageForThumb forState:UIControlStateNormal];
    [self.view addSubview:_autoseek];
    
    _songList.delegate = self;
    _songList.dataSource = self;
    
    _mypod1=[[ESLpod alloc]init];
    [_mypod1 audioSession];
    _mypod2=[[ESLpod alloc]init];
    [_mypod2 audioSession];
    _mypod3=[[ESLpod alloc]init];
    [_mypod3 audioSession];
    
    
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
                                               object:avPlayer];
    ///前回のスライダー値反映
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    
    
    
    _mypod1.feedVol=[ud floatForKey:@"feedvol"];
    _mypod2.feedVol=[ud floatForKey:@"feedvol"];
    _mypod3.feedVol=[ud floatForKey:@"feedvol"];
    
    
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", _mypod1.feedVol*100];
    _fbVolLabel.text=fbVoltext;
    _feedvol.value=_mypod1.feedVol;
    
    _mypod1.delayTime=[ud floatForKey:@"delayTime"];
    _mypod2.delayTime=[ud floatForKey:@"delayTime"];
    _mypod3.delayTime=[ud floatForKey:@"delayTime"];

    
    NSString *delaytimetext;
    if (_mypod1.delayTime*5 < 9.95) {
        delaytimetext = [NSString stringWithFormat:@"%.1f", _mypod1.delayTime*5];
        _delaytimeLabel.text=delaytimetext;
    }else{
        _delaytimeLabel.text=@"10.";
    }
    _delaytime.value=_mypod1.delayTime;
    
    _mediaitemData=[ud objectForKey:@"_mediaitemData"];
    _songCount=[ud floatForKey:@"songCount"];
    
    @try{
        _mediaItemCollection2 = [NSKeyedUnarchiver unarchiveObjectWithData:_mediaitemData];
        if (_mediaItemCollection2.count>=1) {
            MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
            _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
            avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
            [self songtext];
            
            _nameData=[[NSMutableArray alloc]init];
            for (int i = 0;i < _mediaItemCollection2.count; i++) {
                MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
                
                _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
                
                //_name2=[[nameitem1 valueForProperty:MPMediaItemPropertyAlbumTrackNumber]stringValue];
                //NSString* str1 = [NSString stringWithFormat: @"%4@", _name2];
                //NSLog(@"%@",str1);
                if (_name1!=nil) {
                    [_nameData addObject:_name1];
                }
                //NSLog(@"%d曲目　%@",i,[_nameData objectAtIndex:i]);
            }
        }
    }
    @catch(NSException *ex){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"曲情報が変更されました" message:@"曲を再選択して下さい" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK!" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            // cancelボタンが押された時の処理
            [self cancelButtonPushed];
        }]];

        [self presentViewController:alertController animated:YES completion:nil];
        avPlayer=nil;
        _timelabel.text=[NSString stringWithFormat:@"00:00"];
        _maxtimelabel.text=[NSString stringWithFormat:@"-00:00"];
        _titlelabel.text=[NSString stringWithFormat:@"曲が選択されていません"];
        self.title = @"曲が選択されていません";

    }
    
    
    [self addRemoteCommandCenter];
    //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    [_songList reloadData];
    [self AutoScroll];
    
    avPlayer.volume=_ipodVol;
    [self startTimer];
    
    _repeatCount=[ud floatForKey:@"repeatCount"];
    if (_repeatCount==1) {//1曲
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat11.png" ] forState : UIControlStateNormal];
    }else if (_repeatCount==0){//all
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat0.png" ] forState : UIControlStateNormal];
    }else{//non
        [_repeatImage setImage : [ UIImage imageNamed : @"repeata.png" ] forState : UIControlStateNormal];
    }

    NSArray *out = _mypod1->session.currentRoute.outputs;
    _desc = [out lastObject];
    //NSLog(@"%@",_desc);
    if ([_desc.portType isEqual:AVAudioSessionPortHeadphones])
    {
        NSLog(@"起動時イヤホン接続中");
        [self ipodLabelDefault];
        [_mypod1 feed];
        [_mypod1 bufferSet];
        [_mypod1 mixUnitvol];
        [_mypod1 delayUnittime];
        [_mypod1 delayUnittime2];
        [_mypod1 delayUnittime3];
        [_mypod1 delayUnittime4];
        [_mypod1 delayUnittime5];
        [_mypod2 feed];
        [_mypod2 bufferSet];
        [_mypod2 mixUnitvol];
        [_mypod2 delayUnittime];
        [_mypod2 delayUnittime2];
        [_mypod2 delayUnittime3];
        [_mypod2 delayUnittime4];
        [_mypod2 delayUnittime5];
        [_mypod3 feed];
        [_mypod3 bufferSet];
        [_mypod3 mixUnitvol];
        [_mypod3 delayUnittime];
        [_mypod3 delayUnittime2];
        [_mypod3 delayUnittime3];
        [_mypod3 delayUnittime4];
        [_mypod3 delayUnittime5];
        
        _feedvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        _fbVolLabel.textColor=[UIColor blackColor];
        _delaytime.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        _delaytimeLabel.textColor=[UIColor blackColor];
        
        [_micimage setImage : [ UIImage imageNamed : @"miconbutton.png" ] forState : UIControlStateNormal];
        _miccount=YES;
        _mictuketetaFlag=YES;
    }else{
        NSLog(@"起動時イヤホン未接続");
        [self ipodLabelRed];
        [_mypod1 auClose];
        [_mypod2 auClose];
        [_mypod3 auClose];
        _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
        _fbVolLabel.textColor=[UIColor lightGrayColor];
        _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
        _delaytimeLabel.textColor=[UIColor lightGrayColor];
        
        [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
        _miccount=NO;
    }
    
    avPlayer.volume=_ipodVol;
    
    _ipodVolLabel.text=_ipodVoltext;
    _ipodvol.value=_ipodVol;
    
    
    
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"WSCoachMarksShown"];
    if (coachMarksShown == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"WSCoachMarksShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //画面取得
        UIScreen *sc = [UIScreen mainScreen];
        //ステータスバー込みのサイズ
        CGRect rect = sc.bounds;
        NSLog(@"%.1f, %.1f", rect.size.width, rect.size.height);
        //ステータスバーを除いたサイズ
        CGRect rect1 = sc.applicationFrame;
        NSLog(@"%.1f, %.1f", rect1.size.width, rect1.size.height);
        
        float labely21 = _timelabel.frame.origin.y-10;
        float labely22 = _ipodvol.frame.origin.y-10;

        float labely31 = _musicIcon.frame.origin.y;

        float labely41 = _micimage.frame.origin.y;
        
        float labely51 = _delaytime.frame.origin.y;
        
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{rect.size.width/2,rect.size.height/3},{0,0}}],
                                    @"caption": @"⚠\nこのアプリはイヤホンを\n接続して使用します"
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{rect.size.width/2,rect.size.height/3},{0,0}}],
                                    @"caption": @"⚠\n本体音量が小さいと\n音が聞こえないことがあります"
                                    },
                                @{//1//全体縦ー下側+余裕5＝プレイリスト
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{0,0},{rect.size.width,rect.size.height-(736-462)+5}}],
                                    @"caption": @"左上の＋ボタンで曲を\nプレイリストに追加します"
                                    },
                                @{//2//
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{0,rect.size.height-(736-462)+10},{rect.size.width,labely22-labely21}}],
                                    @"caption": @"曲のシークや再生速度、\nリピートを設定できます"
                                    },
                                @{//3
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{0,rect.size.height-(736-610)-10},{rect.size.width,_musicIcon.frame.size.height+15}}],
                                    @"caption": @"曲の音量を変更できます"
                                    },
                                @{//4
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{0,rect.size.height-(736-647)-8},{rect.size.width,_micimage.frame.size.height+15}}],
                                    @"caption": @"マイクのオンオフや\n音量を変更できます"
                                    },
                                @{//5
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{0,rect.size.height-(736-695)-12},{rect.size.width,_delaytime.frame.size.height+15}}],
                                    @"caption": @"声が返ってくるまでの\n遅延時間を変更できます"
                                    },
                                @{//6
                                    @"rect": [NSValue valueWithCGRect:(CGRect){{rect.size.width/2,rect.size.height/3},{0,0}}],
                                    @"caption": @"これで説明は終わりです\nどうぞお楽しみ下さい"
                                    },

                                ];
        WSCoachMarksView *coachMarksView = [[WSCoachMarksView alloc] initWithFrame:self.view.bounds coachMarks:coachMarks];
        
        [coachMarksView setMaskColor: [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75]];
        [self.view addSubview:coachMarksView];
        [coachMarksView start];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_songList setEditing:editing animated:YES];
    if (editing) {
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(trashRow:)];
        self.navigationItem.leftBarButtonItem = anotherButton;
        //            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
        //                                                                                       target:self action:@selector(addRow:)] ;
        //            [self.navigationItem setLeftBarButtonItem:addButton animated:YES]; // 追加ボタンを表示します。
    } else {
        //            [self.navigationItem setLeftBarButtonItem:nil animated:YES]; // 追加ボタンを非表示にします。
        NSIndexPath* indexPath2 = [NSIndexPath indexPathForRow:_songCount inSection:0];
        [_songList selectRowAtIndexPath:indexPath2 animated:NO scrollPosition:UITableViewScrollPositionNone];
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRow:)];
        self.navigationItem.leftBarButtonItem = anotherButton;
    }
}

- (void)addRow:(id)sender {
    if (_nameData!=nil) {
        _addFlag=YES;
        NSLog(@"yes");
    }
    
    MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
    picker.delegate = self;
    picker.allowsPickingMultipleItems = YES;        // 複数選択可
    [self presentViewController:picker animated:YES completion:nil];    //Libraryを開く
}

-(void)trashRow:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"プレイリストを全削除しますか？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    // addActionした順に左から右にボタンが配置されます
    [alertController addAction:[UIAlertAction actionWithTitle:@"いいえ" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // cancelボタンが押された時の処理
        [self cancelButtonPushed];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"はい" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // doボタンが押された時の処理
        [self doButtonPushed];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    [self lastplaydisable];
    [self resetlastplayslider];
    [self lastplayreset];
}


- (void)cancelButtonPushed {
}

- (void)doButtonPushed {
    _addFlag=NO;
    [_nameData removeAllObjects];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    _mediaItemCollection2=[_mediaItemCollection2 initWithItems:array];
    [_songList reloadData];
    avPlayer=nil;
    _timelabel.text=[NSString stringWithFormat:@"00:00"];
    _maxtimelabel.text=[NSString stringWithFormat:@"-00:00"];
    _titlelabel.text=[NSString stringWithFormat:@"曲が選択されていません"];
    self.title = @"曲が選択されていません";
    [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
    _songCount=0;
    [self saveCount];
    [self savesongList];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addRow:)];
    self.navigationItem.leftBarButtonItem = anotherButton;
    [super setEditing:NO animated:NO];
    [_songList setEditing:NO animated:NO];
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_nameData removeObjectAtIndex:indexPath.row]; // 削除ボタンが押された行のデータを配列から削除します。
        NSArray* items = [_mediaItemCollection2 items];
        NSMutableArray* array = [NSMutableArray arrayWithCapacity:[items count]];
        [array addObjectsFromArray:items];
        [array removeObjectAtIndex:indexPath.row];
        _mediaItemCollection2 = [MPMediaItemCollection collectionWithItems:array];
        [_songList deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //if playing delete
        if (_mediaItemCollection2.count<1) {//1曲の時
            //選択初期化
            avPlayer=nil;
            _timelabel.text=[NSString stringWithFormat:@"00:00"];
            _maxtimelabel.text=[NSString stringWithFormat:@"-00:00"];
            _titlelabel.text=[NSString stringWithFormat:@"曲が選択されていません"];
            self.title = @"曲が選択されていません";
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            
            
        }else{//2曲以上の時
            if (indexPath.row==_songCount) {//選択中の曲を削除
                
                if (_songCount==_mediaItemCollection2.count) {//最後なら1つ前の曲へ
                    _songCount--;
                    [self nextandback];
                }else{//最後以外は次の曲へ=同じカウントでセットしなおし
                    [self nextandback];
                    [_songList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                }
                [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
                
            }else if(indexPath.row<_songCount){//選択中より上の曲を削除
                _songCount--;
                
            }
            NSIndexPath* indexPath2 = [NSIndexPath indexPathForRow:_songCount inSection:0];
            [_songList selectRowAtIndexPath:indexPath2 animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        
        [self savesongList];
        [self saveCount];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//editで曲順入れ替え
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if(fromIndexPath.section == toIndexPath.section) { // 移動元と移動先は同じセクションです。
        if(_nameData && toIndexPath.row < [_nameData count]) {
            id nameitem = [_nameData objectAtIndex:fromIndexPath.row]; // 移動対象を保持します。
            [_nameData removeObjectAtIndex:fromIndexPath.row]; // 配列から一度消します。
            [_nameData insertObject:nameitem atIndex:toIndexPath.row]; // 保持しておいた対象を挿入します。
            
            NSMutableArray *mutableitems = [[_mediaItemCollection2 items]mutableCopy];
            id nameitem1 = [mutableitems objectAtIndex:fromIndexPath.row]; // 移動対象を保持します。
            [mutableitems removeObjectAtIndex:fromIndexPath.row]; // 配列から一度消します。
            [mutableitems insertObject:nameitem1 atIndex:toIndexPath.row]; // 保持しておいた対象を挿入します。
            _mediaItemCollection2=[[MPMediaItemCollection alloc]initWithItems:mutableitems];
            
            NSLog(@"count:%ld from:%ld to:%ld",_songCount,(long)fromIndexPath.row,(long)toIndexPath.row);
            if (_songCount==fromIndexPath.row) {
                _songCount=toIndexPath.row;
            }else if(_songCount>fromIndexPath.row){//再生中より上を触った時
                if (_songCount>toIndexPath.row) {
                    //上からとって上に入れる。+-0
                    NSLog(@"上−>上");
                }
                if (_songCount<=toIndexPath.row) {
                    //上からとって下に入れる。-1
                    _songCount=_songCount-1;
                    NSLog(@"上−>下");
                }
            }else if(_songCount<fromIndexPath.row){//再生中より下を触った時
                if (_songCount>=toIndexPath.row) {
                    //下からとって上に入れる。+1
                    _songCount=_songCount+1;
                    NSLog(@"下−>上");
                }
                if (_songCount<toIndexPath.row) {
                    //下からとって下に入れる。+-0
                    NSLog(@"下−>下");
                }
            }
            [self savesongList];
            [self saveCount];
        }
    }
}

- (void)avPlayDidFinish:(NSNotification*)notification
{
    [self avPlayDidFinish];
}

-(void)avPlayDidFinish{
    if(_mediaItemCollection2.count != 0 && _nextikuFlag){               //１曲以上選ばれている　かつ　シーク触ってない
        NSLog(@"次の曲通知");
        if (_songCount==_mediaItemCollection2.count-1) {//最後なら1曲目へ
            _songCount=0;
            
            [self saveCount];
            
            [self nextandback];
            if ((_repeatCount==2)||(_repeatCount==1)) {//リピートなら戻って再生続ける
                _seekPlaying=YES;
                [self playwithRate];
            }else{//リピートじゃないなら再生アイコンに
                [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
                _seekPlaying=NO;
            }
        }
        else{           //最後じゃないなら次の曲へ
            if (_repeatCount==1) {//同じ曲リピートだからsongCountを+しない
                
            }else{//次の曲
                _songCount++;
            }
            [self saveCount];
            [self nextandbackplay];
        }
    }else{
        [self nextandback];
    }
}

- (void)didChangeAudioSessionRoute:(NSNotification *)notification
{
    
    
    
    
    // ヘッドホンが刺さっていたか取得
    BOOL (^isJointHeadphone)(NSArray *) = ^(NSArray *outputs){
        for (_desc in outputs) {
            if ([_desc.portType isEqual:AVAudioSessionPortHeadphones]) {
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
            [self ipodLabelDefault];
        }
    } else {
        if(isJointHeadphone(prevDesc.outputs)) {
            NSLog(@"ヘッドフォンが抜かれた");
            [self ipodLabelRed];
            
            [avPlayer pause];
            _seekPlaying=NO;
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            
            [_mypod1 auClose];
            [_mypod2 auClose];
            [_mypod3 auClose];
            
            _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
            _fbVolLabel.textColor=[UIColor lightGrayColor];
            _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
            _delaytimeLabel.textColor=[UIColor lightGrayColor];
            
            [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
            _miccount=NO;
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
            [avPlayer pause];
            _seekPlaying=NO;
            [_mypod1 auClose];
            [_mypod2 auClose];
            [_mypod3 auClose];
            _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
            _fbVolLabel.textColor=[UIColor lightGrayColor];
            _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
            _delaytimeLabel.textColor=[UIColor lightGrayColor];
            [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
            _miccount=NO;
            
            break;
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"割り込みの終了！");
            break;
            
        default:
            break;
    }
}

- (IBAction)pick:(id)sender {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc]init];
    
    picker.delegate = self;
    
    picker.allowsPickingMultipleItems = YES;        // 複数選択可
    // picker.prompt = @"Add songs to play";//上に文字出せる
    [self presentViewController:picker animated:YES completion:nil];    //Libraryを開く
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];     //キャンセルで曲選択を終わる
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection       //曲選択後
{
    if (_addFlag) {
        NSMutableArray *mutableitems = [[_mediaItemCollection2 items]mutableCopy];
        [mutableitems addObjectsFromArray:[mediaItemCollection items]];
        _mediaItemCollection2=[[MPMediaItemCollection alloc]initWithItems:mutableitems];
        _nameData=[[NSMutableArray alloc]init];
        for (int i = 0;i < _mediaItemCollection2.count; i++) {
            MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
            _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
            [_nameData addObject:_name1];
        }
        
        if (avPlayer==nil) {
            [self songtext];
            MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:0];
            _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            _playerItem = [[AVPlayerItem alloc] initWithURL:_url];    //変換
            avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
            
            avPlayer.volume=_ipodVol;
        }
        
    }else{
        [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
        _songCount=0;
        [self saveCount];
        //曲名取得
        _mediaItemCollection2=mediaItemCollection;
        
        [self songtext];
        MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:0];
        _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        _playerItem = [[AVPlayerItem alloc] initWithURL:_url];    //変換
        avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
        
        avPlayer.volume=_ipodVol;
        
        _nameData=[[NSMutableArray alloc]init];
        for (int i = 0;i < _mediaItemCollection2.count; i++) {
            MPMediaItem *nameitem1=[_mediaItemCollection2.items objectAtIndex:i];
            
            _name1=[nameitem1 valueForProperty:MPMediaItemPropertyTitle];
            
            //_name2=[[nameitem1 valueForProperty:MPMediaItemPropertyAlbumTrackNumber]stringValue];
            //NSString* str1 = [NSString stringWithFormat: @"%4@", _name2];
            //NSLog(@"%@",str1);
            
            [_nameData addObject:_name1];
            
            //NSLog(@"%@",[_nameData objectAtIndex:i]);
            NSLog(@"%d曲目　%@",i,[_nameData objectAtIndex:i]);
        }
    }
    [self savesongList];
    [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    [_songList reloadData];
    [self AutoScroll];
    [self startTimer];
    _addFlag=NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _nameData.count;
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
    _seekPlaying=YES;
    //[ttableView reloadData];
}

- (IBAction)backSong:(id)sender {
    [self backsong];
}

-(void)backsong{

    [self resetlastplayslider];
    if(_nameData != 0){                     //１曲以上選ばれているか
        if (CMTimeGetSeconds(avPlayer.currentTime)<2.9) {//2.9秒以前なら前の曲
            if (_songCount==0) {    //最初なら最後の曲へ
                _songCount=_nameData.count-1;
                [self saveCount];
            }else {
                _songCount--;    //前の曲へ
                [self saveCount];
            }
            
            if ([avPlayer rate]==0 || _lastplaying) {  //曲が停止中なら停止
                [self nextandback];
            }else{  //曲が再生中なら再生
                [self nextandbackplay];
                [self setlastplaytopslider];
            }
        }else{//2.9秒以降なら0秒
            [avPlayer seekToTime:CMTimeMake(0, 600)];

            if (!([avPlayer rate]==0 || _lastplaying)) {
                _lastplayfloat=0;
                [self setlastplaytopslider];
            }
            
        }
        
        if (_lastplaying) {
            [avPlayer pause];
            _seekPlaying=NO;

        }
        [self lastplayreset];
        [self lastplaydisable];
    }

}

- (IBAction)nextSong:(id)sender {
    [self nextsong];
}

-(void)nextsong{

    //NSLog(@"%lu",(unsigned long)_mediaItemCollection2.count);
    if(_nameData.count != 0){               //１曲以上選ばれているか
        if (_songCount==_nameData.count-1) {//最後なら1曲目へ
            _songCount=0;
            [self saveCount];
        }
        else{           //次の曲へ
            if (_repeatCount!=1) {
                _songCount++;
            }
            
            [self saveCount];
        }
        if ([avPlayer rate]==0 || _lastplaying) {  //曲が停止中なら停止
            [self nextandback];
            [self lastplayreset];
            [self lastplaydisable];
            [self resetlastplayslider];
            
        }else{  //曲が再生中なら停止
            [self nextandbackplay];
            [self lastplayreset];
            [self lastplaydisable];
            
            [self resetlastplayslider];
            _lastplayfloat=0;
            [self setlastplaytopslider];
            
        }
    }

}

-(void)nextandback{
    [self lastplayreset];
    [self lastplaydisable];
    [self resetlastplayslider];
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    avPlayer.volume=_ipodVol;
    _seekPlaying=NO;
}

-(void)nextandbackplay{
    [self lastplayreset];
    [self lastplaydisable];
    [self resetlastplayslider];
    [self setlastplaytopslider];
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    [self songtext];
    [self AutoScroll];
    _url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    _playerItem = [[AVPlayerItem alloc] initWithURL:_url];
    avPlayer = [[AVQueuePlayer alloc] initWithPlayerItem:_playerItem];
    
    avPlayer.volume=_ipodVol;
    
    [self playwithRate];
    [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
}

- (IBAction)pushPlay:(id)sender {
    [self pushPlay];
}

-(void)pushPlay{
    if (_nameData.count != 0){
        if (_lastplaying) {
            _lastplaying=NO;
            [avPlayer seekToTime:_laststoptime];
            [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
            [self playwithRate];
            NSLog(@"プレイ");
            _seekPlaying=YES;
            _lastplayfloat=_laststopfloat;
            _lastplaytime= _laststoptime;

            [self lastplaydisable];
            [self.view sendSubviewToBack:_lastplaytopslider];
            [self setlastplaytopslider];
        }else{
        if ([avPlayer rate]!=0) {  //曲が再生中なら停止
            [_playImage setImage : [ UIImage imageNamed : @"playClear.png" ] forState : UIControlStateNormal];
            [avPlayer pause];
            NSLog(@"ポーズ");
            _seekPlaying=NO;
            _laststopfloat=CMTimeGetSeconds(avPlayer.currentTime);
            _laststoptime= CMTimeMakeWithSeconds(_laststopfloat, NSEC_PER_SEC);
            if (_laststopfloat-_lastplayfloat>0) {
                [self lastplayenable];
            }else{
                [self resetlastplayslider];
            }
            
        }else{  //曲が停止中なら再生
            [_playImage setImage : [ UIImage imageNamed : @"pauseClear.png" ] forState : UIControlStateNormal];
            [self playwithRate];
            NSLog(@"プレイ");
            _seekPlaying=YES;
            _lastplayfloat=CMTimeGetSeconds(avPlayer.currentTime);
            _lastplaytime= CMTimeMakeWithSeconds(_lastplayfloat, NSEC_PER_SEC);
            [self lastplaydisable];
            [self resetlastplaystopslider];
            [self setlastplaytopslider];
        }
        }
    }
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

- (IBAction)ipodSliderChanged:(UISlider*)sender {   //曲のボリューム変更スライダー
    _ipodVol = sender.value;
    avPlayer.volume=_ipodVol;
    NSLog(@"%f",sender.value);
    if (_headphoneConnect) {
        _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL];
        
        NSUserDefaults *ud1=[NSUserDefaults standardUserDefaults];
        [ud1 setFloat:_ipodVol forKey:@"ipodvol"];
    }else{
        _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL/10];
        
        NSUserDefaults *ud6=[NSUserDefaults standardUserDefaults];
        [ud6 setFloat:_ipodVol forKey:@"speakervol"];
    }
    _ipodVolLabel.text=_ipodVoltext;
}

- (IBAction)feedSliderChanged:(UISlider*)sender {   //フィードバック音のボリューム変更スライダー
    float rv = 1/sender.value;
    float log=-10*log2(rv);
    float db =pow(10, log/20);
    NSLog(@"%f",db);
    _mypod1.feedVol=db;
    _mypod2.feedVol=db;
    _mypod3.feedVol=db;
    
    if (_miccount) {
        [_mypod1 mixUnitvol];
        [_mypod2 mixUnitvol];
        [_mypod3 mixUnitvol];

    }
    NSString *fbVoltext = [NSString stringWithFormat:@"%.0f", sender.value*100];
    _fbVolLabel.text=fbVoltext;
    
    NSUserDefaults *ud2=[NSUserDefaults standardUserDefaults];
    [ud2 setFloat:_mypod1.feedVol forKey:@"feedvol"];
    [ud2 setFloat:_mypod2.feedVol forKey:@"feedvol"];
    [ud2 setFloat:_mypod3.feedVol forKey:@"feedvol"];

}

- (IBAction)delaySliderChanged:(UISlider*)sender {//フィードバック音の遅延変更スライダー
    NSLog(@"delay");
    _mypod1.delayTime=sender.value;
    _mypod2.delayTime=sender.value;
    _mypod3.delayTime=sender.value;
    if (_miccount) {
        [_mypod1 delayUnittime];
        [_mypod2 delayUnittime];
        [_mypod3 delayUnittime];

        [_mypod1 delayUnittime2];
        [_mypod2 delayUnittime2];
        [_mypod3 delayUnittime2];

        [_mypod1 delayUnittime3];
        [_mypod2 delayUnittime3];
        [_mypod3 delayUnittime3];
        
        [_mypod1 delayUnittime4];
        [_mypod2 delayUnittime4];
        [_mypod3 delayUnittime4];
        
        [_mypod1 delayUnittime5];
        [_mypod2 delayUnittime5];
        [_mypod3 delayUnittime5];
    }
    
    NSString *delaytimetext;
    if (_mypod1.delayTime*5 < 9.95) {
        delaytimetext = [NSString stringWithFormat:@"%.1f", _mypod1.delayTime*5];
        _delaytimeLabel.text=delaytimetext;
    }else{
        _delaytimeLabel.text=@"10.";
    }
    
    
    NSUserDefaults *ud7=[NSUserDefaults standardUserDefaults];
    [ud7 setFloat:_mypod1.delayTime forKey:@"delayTime"];
    [ud7 setFloat:_mypod2.delayTime forKey:@"delayTime"];
    [ud7 setFloat:_mypod3.delayTime forKey:@"delayTime"];
}

-(void)saveCount{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        NSUserDefaults *ud5=[NSUserDefaults standardUserDefaults];
        [ud5 setFloat:_songCount forKey:@"songCount"];
        NSUserDefaults *ud6=[NSUserDefaults standardUserDefaults];
        [ud6 setFloat:_repeatCount forKey:@"repeatCount"];
    }
}

-(void)savesongList{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        _mediaitemData = [NSKeyedArchiver archivedDataWithRootObject:_mediaItemCollection2];
        NSUserDefaults *ud4=[NSUserDefaults standardUserDefaults];
        [ud4 setObject:_mediaitemData forKey:@"_mediaitemData"];
    }
}

-(void)songtext{
    MPMediaItem *item = [_mediaItemCollection2.items objectAtIndex:_songCount];
    _titlelabel.text =[item valueForProperty:MPMediaItemPropertyTitle];
    self.title = [item valueForProperty:MPMediaItemPropertyTitle];
    _albumlabel.text =[item valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    NSString *playbackstr=[item valueForProperty:MPMediaItemPropertyPlaybackDuration];
    _playback=playbackstr.intValue;
    _autoseek.maximumValue=_playback;
    _lastplaystopslider.maximumValue=_playback;
    _lastplaytopslider.maximumValue=_playback;
    
    _songinfo=@{MPMediaItemPropertyTitle:[item valueForProperty:MPMediaItemPropertyTitle],
                MPMediaItemPropertyPlaybackDuration:[item valueForProperty:MPMediaItemPropertyPlaybackDuration]
                };
    //[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:_songinfo];
}

-(void)startTimer{
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timertext) userInfo:nil repeats:YES];
}

-(void)timertext{
    _getSecond=CMTimeGetSeconds(avPlayer.currentTime);
    _second=fmodf(_getSecond,60);
    _minute=_getSecond/60;
    _timestr=[NSString stringWithFormat:@"%02d:%02d",_minute,_second];
    _timelabel.text=_timestr;
    
    _maxback=_playback-CMTimeGetSeconds(avPlayer.currentTime);
    _maxsecond=_maxback%60;
    _maxminute=_maxback/60;
    _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",_maxminute,_maxsecond];
    _maxtimelabel.text=_maxtimelabelstr;
    [_autoseek setValue:_getSecond animated:YES];
    
    if (_lastplaying) {
        _getSecond=CMTimeGetSeconds(avPlayer.currentTime);
        if (_laststopfloat<=_getSecond) {
            NSLog(@"%f",_laststopfloat);
            NSLog(@"%f",_getSecond);
            [self lastplaystop];
            [self.view sendSubviewToBack:_lastplaytopslider];
            [_lastplay setImage : [ UIImage imageNamed : @"lastplayplay.png" ] forState : UIControlStateNormal];
            _lastplay.alpha=1;
        }
    }
}

- (IBAction)seekslider:(UISlider *)sender {
    _newValue=sender.value;
    [_timer invalidate];
    if (fabsf(_newValue-_oldValue)>(_playback/1000)) {
        
        
        [_autoseek setValue:sender.value animated:YES];
        _tm= CMTimeMakeWithSeconds((int)sender.value, NSEC_PER_SEC);
        
        if (_seekPlaying && _playback-sender.value>0.1) {
            
            [avPlayer pause];
            [avPlayer seekToTime:_tm];
            
            [NSThread sleepForTimeInterval:0.05];
            [self playwithRate];
            NSLog(@"うああああああ%f",_playback-sender.value);

        }
        
        if (_playback-sender.value<0.2) {
            [avPlayer pause];
        }
        
        _senderval=sender.value;
        _second=_senderval%60;
        _minute=sender.value/60;
        _timestr=[NSString stringWithFormat:@"%02d:%02d",_minute,_second];
        _timelabel.text=_timestr;
        _maxback=_playback-sender.value;
        _maxsecond=_maxback%60;
        _maxminute=_maxback/60;
        _maxtimelabelstr=[NSString stringWithFormat:@"-%02d:%02d",_maxminute,_maxsecond];
        _maxtimelabel.text=_maxtimelabelstr;
        
    }else{
        
    }
    
    _oldValue=_newValue;
}

- (IBAction)feedUp:(UISlider *)sender {
    _nextikuFlag=YES;
    if (_seekPlaying&&_lastplaying==NO) {
        [self playwithRate];
    }else{
        [avPlayer seekToTime:_tm];
    }
    
    
    if (_playback-sender.value<0.2) {
        NSLog(@"離したaaaaaaaa");
        if (_seekPlaying) {
            [self avPlayDidFinish];
        }
    }
    //[_autoseek setValue:sender.value animated:YES];
  
    
    [self startTimer];
    NSLog(@"離した%f",CMTimeGetSeconds(avPlayer.currentTime));
    
    if (sender.value<=_lastplayfloat && _seekPlaying) {
        [self resetlastplayslider];
        _lastplayfloat=CMTimeGetSeconds(avPlayer.currentTime);
        _lastplaytime= CMTimeMakeWithSeconds(_lastplayfloat, NSEC_PER_SEC);
        [self lastplaydisable];
        [self resetlastplaystopslider];
        [self setlastplaytopslider];
    }
}

- (IBAction)feedDown:(UISlider *)sender {//シークバー操作中
    _oldValue=sender.value;
    _nextikuFlag=NO;
    
    if ([avPlayer rate]==0) {
        _seekPlaying=NO;
        NSLog(@"NO");
    }else{
        _seekPlaying=YES;
        NSLog(@"YES");
    }
    
    if (_lastplaying) {
        [self.view sendSubviewToBack:_lastplaytopslider];
        [self lastplaystop];
        [self lastplayreset];
        [self lastplaydisable];
        [self resetlastplayslider];

    }
}

- (IBAction)repeatBtn:(UIButton *)sender {//0=リピート無し,1=1曲リピート,2=Allリピート
    NSLog(@"repeat押した");
    if (_repeatCount==2) {//1
        _repeatCount=1;
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat11.png" ] forState : UIControlStateNormal];
    }else if (_repeatCount==1){//all
        _repeatCount=0;
        [_repeatImage setImage : [ UIImage imageNamed : @"repeat0.png" ] forState : UIControlStateNormal];
    }else{//non
        _repeatCount=2;
        [_repeatImage setImage : [ UIImage imageNamed : @"repeata.png" ] forState : UIControlStateNormal];
    }
    [self saveCount];
}

-(void)AutoScroll{
    if (_songCount<_nameData.count) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_songCount inSection:0];
        [_songList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

- (IBAction)miconoff:(UIButton *)sender {
    [self miconoff];
}

-(void)miconoff{
    if (!_miccount) {
        [self micon];
    }else{
        [self micoff];
    }
    _mictuketetaFlag=_miccount;
}

-(void)micon{
    [_mypod1 feed];
    [_mypod1 bufferSet];
    [_mypod1 mixUnitvol];
    [_mypod1 delayUnittime];
    [_mypod1 delayUnittime2];
    [_mypod1 delayUnittime3];
    [_mypod1 delayUnittime4];
    [_mypod1 delayUnittime5];
    [_mypod2 feed];
    [_mypod2 bufferSet];
    [_mypod2 mixUnitvol];
    [_mypod2 delayUnittime];
    [_mypod2 delayUnittime2];
    [_mypod2 delayUnittime3];
    [_mypod2 delayUnittime4];
    [_mypod2 delayUnittime5];
    [_mypod3 feed];
    [_mypod3 bufferSet];
    [_mypod3 mixUnitvol];
    [_mypod3 delayUnittime];
    [_mypod3 delayUnittime2];
    [_mypod3 delayUnittime3];
    [_mypod3 delayUnittime4];
    [_mypod3 delayUnittime5];
    
    _feedvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _fbVolLabel.textColor=[UIColor blackColor];
    _delaytime.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _delaytimeLabel.textColor=[UIColor blackColor];
    
    [_micimage setImage : [ UIImage imageNamed : @"miconbutton.png" ] forState : UIControlStateNormal];
    _miccount=YES;
}
-(void)micoff{
    [_mypod1 auClose];
    [_mypod2 auClose];
    [_mypod3 auClose];
    
    _feedvol.minimumTrackTintColor=[UIColor lightGrayColor];
    _fbVolLabel.textColor=[UIColor lightGrayColor];
    _delaytime.minimumTrackTintColor=[UIColor lightGrayColor];
    _delaytimeLabel.textColor=[UIColor lightGrayColor];
    
    [_micimage setImage : [ UIImage imageNamed : @"micoffbutton.png" ] forState : UIControlStateNormal];
    _miccount=NO;
}

-(void)ipodLabelDefault{//イヤホン挿さってる時
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    _ipodVol = [ud floatForKey:@"ipodvol"];
    
    _musicIcon.textColor=_ipodVolLabel.textColor=[UIColor blackColor];
    _ipodvol.minimumTrackTintColor=[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _ipodvol.maximumValue=0.1;
    _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL];
    
    _ipodvol.value=_ipodVol;
    _ipodVolLabel.text=_ipodVoltext;
    avPlayer.volume=_ipodVol;
    
    _headphoneConnect=YES;
}

-(void)ipodLabelRed{//イヤホン刺さってない時
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    _ipodVol = [ud floatForKey:@"speakervol"];
    
    _musicIcon.textColor=_ipodVolLabel.textColor=[UIColor redColor];
    _ipodvol.minimumTrackTintColor=[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0];
    _ipodvol.maximumValue=1;
    _ipodVoltext = [NSString stringWithFormat:@"%.0f", _ipodVol*IPOD_VOL/10];
    
    _ipodvol.value=_ipodVol;
    _ipodVolLabel.text=_ipodVoltext;
    avPlayer.volume=_ipodVol;
    
    _headphoneConnect=NO;
}

- (IBAction)playerrateButton:(UIButton *)sender {
    if (_rateCount==0) {
        _rateValue=1.1;
        if (_seekPlaying) {
            avPlayer.rate=_rateValue;
        }
        _rateCount++;
        [_rateButton setTitle:@"×110%" forState:UIControlStateNormal];
    }else if (_rateCount==1){
        _rateValue=1.2;
        if (_seekPlaying) {
            avPlayer.rate=_rateValue;
        }
        _rateCount++;
        [_rateButton setTitle:@"×120%" forState:UIControlStateNormal];
    }else if (_rateCount==2){
        _rateValue=0.8;
        if (_seekPlaying) {
            avPlayer.rate=_rateValue;
        }
        _rateCount++;
        [_rateButton setTitle:@"×80%" forState:UIControlStateNormal];
    }else if (_rateCount==3){
        _rateValue=0.9;
        if (_seekPlaying) {
            avPlayer.rate=_rateValue;
        }
        _rateCount++;
        [_rateButton setTitle:@"×90%" forState:UIControlStateNormal];
    }else if (_rateCount==4){
        _rateValue=1;
        if (_seekPlaying) {
            avPlayer.rate=_rateValue;
        }
        _rateCount=0;
        [_rateButton setTitle:@"×100%" forState:UIControlStateNormal];
    }
}

-(void)playwithRate{
    [avPlayer play];
    avPlayer.rate=_rateValue;

}

- (IBAction)lastplayButton:(UIButton *)sender {
    [_timer invalidate];
    [_lastplay setImage : [ UIImage imageNamed : @"lastplaytop.png" ] forState : UIControlStateNormal];
    [avPlayer seekToTime:_lastplaytime];
    [self.view bringSubviewToFront:_lastplaytopslider];
    [self playwithRate];
    _seekPlaying=YES;
    _lastplaying=YES;
    
    //[self performSelector:@selector(lastplaystop) withObject:nil afterDelay:(_laststopfloat-_lastplayfloat)/_rateValue];
    
    [self startTimer];
}

-(void)lastplaystop{
    if (_lastplaying) {
        [avPlayer pause];
        _seekPlaying=NO;
        _lastplaying=NO;
        [_lastplay setImage : [ UIImage imageNamed : @"lastplayplay.png" ] forState : UIControlStateNormal];
        _lastplay.alpha=1;
    }
}

-(void)lastplaydisable{
    _lastplay.userInteractionEnabled=NO;
    _lastplay.alpha=0.2;
    [_lastplay setImage : [ UIImage imageNamed : @"lastplayplay.png" ] forState : UIControlStateNormal];
    //[self resetlastplayslider];
}
-(void)lastplayenable{
    _lastplay.userInteractionEnabled=YES;
    _lastplay.alpha=1;
    [_lastplay setImage : [ UIImage imageNamed : @"lastplayplay.png" ] forState : UIControlStateNormal];
    [self setlastplayslider];
}
-(void)lastplayreset{
    [_lastplay setImage : [ UIImage imageNamed : @"lastplayplay.png" ] forState : UIControlStateNormal];
    _lastplaying=NO;
    _laststopfloat=0;
    _laststoptime= CMTimeMakeWithSeconds(0, NSEC_PER_SEC);
    _lastplayfloat=0;
    _lastplaytime= CMTimeMakeWithSeconds(0, NSEC_PER_SEC);
}
-(void)setlastplayslider{
    [self setlastplaytopslider];
    [self setlastplaystopslider];
}
-(void)setlastplaytopslider{
    _imageForThumb = [UIImage imageNamed:@"slider_blue.png"];
    [_lastplaytopslider setThumbImage:_imageForThumb forState:UIControlStateNormal];
    _lastplaytopslider.value=_lastplayfloat;
}
-(void)setlastplaystopslider{
    _imageForThumb = [UIImage imageNamed:@"slider_blue.png"];
    [_lastplaystopslider setThumbImage:_imageForThumb forState:UIControlStateNormal];
    _lastplaystopslider.value=_laststopfloat+0.05;
}
-(void)resetlastplayslider{
    [self resetlastplaytopslider];
    [self resetlastplaystopslider];
}
-(void)resetlastplaytopslider{
    _imageForThumb = [UIImage imageNamed:@"slider_white.png"];
    [_lastplaytopslider setThumbImage:_imageForThumb forState:UIControlStateNormal];
    _lastplaytopslider.value=_lastplayfloat;
    [self.view sendSubviewToBack:_lastplaytopslider];
}
-(void)resetlastplaystopslider{
    _imageForThumb = [UIImage imageNamed:@"slider_white.png"];
    [_lastplaystopslider setThumbImage:_imageForThumb forState:UIControlStateNormal];
    _lastplaystopslider.value=_laststopfloat+0.05;
    [self.view sendSubviewToBack:_lastplaystopslider];
}

@end
