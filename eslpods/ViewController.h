#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AudioUnit/AudioUnit.h>
#import "ESLpod.h"
#import "WSCoachMarksView.h"
#import "CBAutoScrollLabel.h"

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
@public AVQueuePlayer *avPlayer;

}
@end
