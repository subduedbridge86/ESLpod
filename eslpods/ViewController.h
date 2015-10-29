#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ESLpod.h"


@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *ttableView;
    
    __weak IBOutlet UILabel *titlelabel;
    __weak IBOutlet UILabel *albumlabel;
    __weak IBOutlet UILabel *timelabel;
    __weak IBOutlet UILabel *maxtimelabel;
    

    __weak IBOutlet UISwitch *feedonoffstate;
    
    __weak IBOutlet UILabel *ipodVolLabel;
    __weak IBOutlet UILabel *fbVolLabel;
    
    __weak IBOutlet UISlider *autoseek;
    
    ESLpod *mypod;
}

@property (nonatomic) IBOutlet UIButton *playImage;

@property (weak, nonatomic) IBOutlet UIButton *repeatbtn;

@property MPMusicPlayerController *player;

@property AVQueuePlayer *avPlayer;
@property NSURL *url;
@property AVPlayerItem *playerItem;
@property MPMediaItemCollection *mediaItemCollection2;
@property NSNotificationCenter *notification;
@property NSArray *nameData;
@property NSData *mediaitemData;
@property NSTimer *timer;
@property NSString *maxtimelabelstr;
@property NSString *timestr;
@property NSString *name1,*name2;


@property (weak, nonatomic) IBOutlet UISlider *ipodvol;
@property (weak, nonatomic) IBOutlet UISlider *feedvol;

- (IBAction)ipodSliderChanged:(UISlider*)sender;
- (IBAction)feedSliderChanged:(UISlider*)sender;

- (IBAction)feedonoff:(UISwitch *)sender;

@end