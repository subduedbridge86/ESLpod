#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioUnit/AudioUnit.h>
#import "ESLpod.h"


@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
@public AVQueuePlayer *avPlayer;

}
@end
