//
//  MultiViewController.h
//  eslpods
//
//  Created by 椛島優 on 2015/11/20.
//  Copyright © 2015年 椛島優. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StreamingPlayer.h"
#import "ExtAudioConverter.h"
#import "AudioConverter.h"
#import "MultipeerHost.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface MultiViewController : UIViewController<MultipeerDataDelegate>

@end
