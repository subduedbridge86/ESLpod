//
//  StreamingPlayer.h
//  AudioStreamer
//
//  Created by 椛島優 on 2015/10/23.
//  Copyright © 2015年 椛島優. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define kNumberOfBuffers 3     //バッファの数
#define kBufferSize 32768      //バッファサイズ
#define kMaxPacketDescs 512    //最大ASPD数

typedef struct StreamInfo{
    AudioFileStreamID audioFileStream;
    AudioQueueRef     audioQueueObject;
    BOOL              started;
    
    AudioQueueBufferRef  audioQueueBuffer[kNumberOfBuffers];
    AudioStreamPacketDescription  packetDescs[kMaxPacketDescs];
    
    BOOL  inuse[kNumberOfBuffers];  //バッファが使用されているか
    UInt32 fillBufferIndex;         //バッファの埋めるべき位置
    UInt32 bytesFilled;             //何Byteバッファを埋めたか
    UInt32 packetsFilled;           //パケットを埋めた数
    
}StreamInfo;
@interface StreamingPlayer : NSObject{
     StreamInfo streamInfo;
}
-(void)start;
-(void)recvAudio:(NSData *)data;
@end
