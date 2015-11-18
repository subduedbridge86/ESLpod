#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ESLpod.h"
#import "StreamingPlayer.h"
#import "ExtAudioConverter.h"
#import "AudioConverter.h"
#import "MultipeerHost.h"

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,UITableViewDelegate,UITableViewDataSource,MultipeerDataDelegate>

@end