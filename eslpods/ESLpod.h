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

@interface ESLpod : NSObject{
@public AVAudioSession *session;
}

@property AUNode remoteIONode,mixNode,delayNode,delayNode2,delayNode3,delayNode4;
@property AudioUnit remoteIOUnit,mixUnit,delayUnit,delayUnit2,delayUnit3,delayUnit4;
@property AUGraph auGraph;
@property float feedVol;
@property float delayTime;
//@property AVAudioSession* session;


-(void)audioSession;
-(void)feed;
-(void)bufferSet;
-(void)mixUnitvol;
-(void)auClose;
-(void)delayUnittime;
-(void)delayUnittime2;
-(void)delayUnittime3;
-(void)delayUnittime4;
@end
