//
//  StreamingPlayer.m
//  AudioStreamer
//
//  Created by 椛島優 on 2015/10/23.
//  Copyright © 2015年 椛島優. All rights reserved.
//

#import "StreamingPlayer.h"
static int delaycount;
@interface StreamingPlayer()
@end
@implementation StreamingPlayer
-(void)start{
  
    
    OSStatus err = AudioFileStreamOpen(&streamInfo,
                                       propertyListenerProc,//プロパティを取得した時に呼ばれるコールバック関数
                                       //パケットデータを解析した時に呼ばれるコールバック関数
                                       packetsProc,
                                       kAudioFormatMPEG4AAC,   //AAC
                                       &streamInfo.audioFileStream);
    checkError(err, "AudioFileStreamOpen");
    streamInfo.started=NO;
    
    
   }
void propertyListenerProc(
                          void *							inClientData,
                          AudioFileStreamID				inAudioFileStream,
                          AudioFileStreamPropertyID		inPropertyID,
                          UInt32 *						ioFlags
                          ){
    delaycount=0;
    StreamInfo* streamInfo = (StreamInfo*)inClientData;
    OSStatus err;
    
    //オーディオデータパケットを解析する準備が完了
    NSLog(@"property%u",(unsigned int)inPropertyID);
    if(inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets){
        
        //ASBDを取得する
        AudioStreamBasicDescription audioFormat;
        UInt32 size = sizeof(AudioStreamBasicDescription);
        err = AudioFileStreamGetProperty(inAudioFileStream,
                                         kAudioFileStreamProperty_DataFormat,
                                         &size,
                                         &audioFormat);
        checkError(err, "kAudioFileStreamProperty_DataFormat");
        
        //AudioQueueオブジェクトの作成
        err = AudioQueueNewOutput(&audioFormat,
                                  outputCallback,
                                  streamInfo,
                                  NULL, NULL, 0,
                                  &streamInfo->audioQueueObject);
        checkError(err, "AudioQueueNewOutput");
        
        //キューバッファを用意する
        for (int i = 0; i < kNumberOfBuffers; ++i) {
            err = AudioQueueAllocateBuffer( streamInfo->audioQueueObject,
                                           kBufferSize,
                                           &streamInfo->audioQueueBuffer[i]);
            checkError(err, "AudioQueueAllocateBuffer");
        }
    }
}

void packetsProc( void *inClientData,
                 UInt32                        inNumberBytes,
                 UInt32                        inNumberPackets,
                 const void                    *inInputData,
                 AudioStreamPacketDescription  *inPacketDescriptions ){
    delaycount++;
    StreamInfo* streamInfo = (StreamInfo*)inClientData;
    
    OSStatus err;
    if(!streamInfo->started && delaycount>15){
        streamInfo->started = YES;
        printf("AudioQueueStart%d\n",delaycount);
        err = AudioQueueStart(streamInfo->audioQueueObject, NULL);
        checkError(err, "AudioQueueStart");
    }
    
    //キューバッファを作成し、エンキューする
    AudioQueueBufferRef queueBuffer;
    err = AudioQueueAllocateBuffer(streamInfo->audioQueueObject,
                                   inNumberBytes,
                                   &queueBuffer);
    if(err)NSLog(@"AudioQueueAllocateBuffer err = %d",(int)err);
    memcpy(queueBuffer->mAudioData, inInputData, inNumberBytes);
    
    queueBuffer->mAudioDataByteSize = inNumberBytes;
    queueBuffer->mPacketDescriptionCount = inNumberPackets;
    
    //ここでロック
    err = AudioQueueEnqueueBuffer(streamInfo->audioQueueObject,
                                  queueBuffer,
                                  inNumberPackets,
                                  inPacketDescriptions);

    if(err)NSLog(@"AudioQueueEnqueueBuffer err = %d",(int)err);


}
static void checkError(OSStatus err,const char *message){
    if(err){
        char property[5];
        *(UInt32 *)property = CFSwapInt32HostToBig(err);
        property[4] = '\0';
        NSLog(@"%s = %-4.4s,%d",message, property,(int)err);
        exit(1);
    }
}
static void enqueueBuffer(StreamInfo* streamInfo){//消すとストリームできない？
       OSStatus err = noErr;
    
    //バッファに充填済みフラグを立てる
    streamInfo->inuse[streamInfo->fillBufferIndex] = YES;
    
    AudioQueueBufferRef fillBuf
    = streamInfo->audioQueueBuffer[streamInfo->fillBufferIndex];
    fillBuf->mAudioDataByteSize = streamInfo->bytesFilled;
    
    err = AudioQueueEnqueueBuffer(streamInfo->audioQueueObject,
                                  fillBuf,
                                  streamInfo->packetsFilled,
                                  streamInfo->packetDescs);
    checkError(err, "AudioQueueEnqueueBuffer");
    
    if (!streamInfo->started){
        err = AudioQueueStart(streamInfo->audioQueueObject, NULL);
        checkError(err, "AudioQueueStart");
        streamInfo->started = YES;
    }
    
    //インデックスを次に進める 0 -> 1, 1 -> 2, 2 -> 0
    if (++streamInfo->fillBufferIndex >= kNumberOfBuffers){
        streamInfo->fillBufferIndex = 0;
    }
    
    streamInfo->bytesFilled = 0;
    streamInfo->packetsFilled = 0;
    
   
}
void outputCallback( void                 *inClientData,
                    AudioQueueRef        inAQ,
                    AudioQueueBufferRef  inBuffer ){
    StreamInfo* streamInfo = (StreamInfo*)inClientData;
    //㈰inBufferがstreamInfo->audioQueueBuffer[ ]のどれかを探す
    UInt32 bufIndex = 0;
    for (int i = 0; i < kNumberOfBuffers; ++i){
        if (inBuffer == streamInfo->audioQueueBuffer[i]){
            bufIndex = i;
            break;
        }
    }
}
-(void)recvAudio:(NSData *)data{
           AudioFileStreamParseBytes(streamInfo.audioFileStream,
                                  (int)data.length,
                                  data.bytes,
                                  0);
    
}

@end
