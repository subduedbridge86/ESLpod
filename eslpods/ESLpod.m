//
//  ESLpod.m
//  英語学習
//
//  Created by 金子誠也 on 2015/03/13.
//  Copyright (c) 2015年 金子誠也. All rights reserved.
//椛島


#import "ESLpod.h"

@implementation ESLpod

-(void)audioSession{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&setCategoryError]) {}
    if (![session setCategory:AVAudioSessionCategoryPlayAndRecord
                  withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                        error:&setCategoryError]) {}
//    if (![session setCategory:AVAudioSessionCategoryPlayback
//                        error:&setCategoryError]) {}

    
    [session setMode:AVAudioSessionModeVoiceChat error:nil];
    
    [session setActive:YES error:nil];
}

-(void)feed{
    //フィードバック部分
    NewAUGraph(&_auGraph);
    AUGraphOpen(_auGraph);
    
    AudioComponentDescription remoteDescription;
    remoteDescription.componentType = kAudioUnitType_Output;
    remoteDescription.componentSubType = kAudioUnitSubType_RemoteIO;//voipはエラー
    remoteDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    remoteDescription.componentFlags = remoteDescription.componentFlagsMask = 0;
    
    AUGraphAddNode(_auGraph, &remoteDescription, &_remoteIONode);
    AUGraphNodeInfo(_auGraph, _remoteIONode, NULL, &_remoteIOUnit);
    
    AudioComponentDescription mixerDescription;
    mixerDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixerDescription.componentType = kAudioUnitType_Mixer;
    mixerDescription.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    
    AUGraphAddNode(_auGraph, &mixerDescription, &_mixNode);
    AUGraphNodeInfo(_auGraph, _mixNode, NULL, &_mixUnit);
    
    
    UInt32 flag = 1;                    //マイク入力をオンにする
    AudioUnitSetProperty(_remoteIOUnit,
                         kAudioOutputUnitProperty_EnableIO,
                         kAudioUnitScope_Input, //RemoteIOのInput
                         1,
                         &flag,
                         sizeof(UInt32));
    
    AudioStreamBasicDescription asbd;
    asbd.mSampleRate = 44100;
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsNonInterleaved | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
    asbd.mBitsPerChannel = 32;  //8*4
    asbd.mBytesPerFrame = 4;    //4=sizeof(SInt32)
    asbd.mBytesPerPacket = 4;
    asbd.mFramesPerPacket = 1;
    asbd.mChannelsPerFrame = 1;
    
    AudioUnitSetProperty(_remoteIOUnit,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         1,
                         &asbd,
                         sizeof(asbd)
                         );
    
    AUGraphConnectNodeInput(_auGraph,
                            _remoteIONode, 1, //Remote Inputと
                            _mixNode, 0  //mixerを接続
                            );
    
    AUGraphConnectNodeInput(_auGraph,
                            _mixNode,0, //mixerと
                            _remoteIONode, 0  //Remote Outputを接続
                            );
    
    AUGraphInitialize(_auGraph);
    AUGraphStart(_auGraph);
    
}

-(void)auClose{
    AUGraphClose(_auGraph);
}

-(void)bufferSet{   //フィードバックの早さ変更
//    Float32 currentDuration;
    UInt32 size1=sizeof(Float32);
//    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &size1, &currentDuration);
//    NSLog(@"元の遅延時間=%f\n",currentDuration);
//    NSLog(@"元のフレーム=%f",44100*currentDuration);
    
    Float32 byte=64;
    Float32 duration=byte/44100;
    
    NSLog(@"遅延をこれに=%f\n",duration);
    size1=sizeof(Float32);
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setPreferredIOBufferDuration:duration error:nil];
    
//    Float32 new;
//    size1=sizeof(Float32);
//    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &size1, &new);
//    NSLog(@"今の遅延時間=%f\n",new);
//    NSLog(@"今のフレーム=%11f",44100*new);
}

-(void)mixUnitvol{
    AudioUnitSetParameter(_mixUnit,
                          kMultiChannelMixerParam_Volume,
                          kAudioUnitScope_Input,
                          0,
                          _feedVol,
                          0);
    
}



@end
