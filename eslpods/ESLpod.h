//
//  ESLpod.h
//  英語学習
//
//  Created by 金子誠也 on 2015/03/13.
//  Copyright (c) 2015年 金子誠也. All rights reserved.
//今度からはこいつを変更してね
//け

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ESLpod : NSObject

@property AUNode remoteIONode,mixNode;
@property AudioUnit remoteIOUnit,mixUnit;
@property AUGraph auGraph;
@property float feedVol;


-(void)audioSession;
-(void)feed;
-(void)bufferSet;
-(void)mixUnitvol;
-(void)auClose;


@end
