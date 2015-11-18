//
//  AudioConverter.m
//  ConvertLossless
//
//  Created by Norihisa Nagano
//

#import "AudioConverter.h"

@implementation AudioConverter


static void checkError(OSStatus err,const char *message){
    if(err){
        char property[5];
        *(UInt32 *)property = CFSwapInt32HostToBig(err);
        property[4] = '\0';
        NSLog(@"%s = %-4.4s",message, property);
        exit(1);
    }
}

typedef struct AudioFileIO{
    AudioFileID		audioFileID;
    SInt64			startingPacketCount;
    char *			srcBuffer;
    UInt32			srcBufferSize;
    UInt32			numPacketsToRead;
    AudioStreamBasicDescription srcFormat;
    AudioStreamPacketDescription* packetDescs;
}AudioFileIO;


OSStatus EncoderDataProc(
						 AudioConverterRef				inAudioConverter,  //コールバック関数を呼び出したAudio Converter
						 UInt32*                         ioNumberDataPackets,//最低限読み込むべきパケット数が渡される。処理した数を返す	
						 AudioBufferList*				ioData,             //このバッファに読み込む
						 AudioStreamPacketDescription**	outDataPacketDescription,//AudioFileReadPacketsで読み込んだASPDを渡す
						 void*							inUserData //任意のデータ(のポインタ)。ここではAudioFileIO
						 )
{
    AudioFileIO* audioFileIO = (AudioFileIO*)inUserData;
	
    //srcBuffer = 32768で読み込める最大パケット数numPacketsToRead
    //を超える場合、*ioNumberDataPacketsをその数に制限する
    UInt32 maxPackets = audioFileIO->numPacketsToRead;
    if (*ioNumberDataPackets > maxPackets) *ioNumberDataPackets = maxPackets;
	
    
    UInt32 outNumBytes;
    OSStatus err = AudioFileReadPackets(audioFileIO->audioFileID, 
                                        NO, 
                                        &outNumBytes, 
                                        audioFileIO->packetDescs,
                                        audioFileIO->startingPacketCount, 
                                        ioNumberDataPackets, 
                                        audioFileIO->srcBuffer);
	
    if (err) {
        checkError(err, "AudioFileReadPackets");
        return err;
    }
    //読み込み位置をインクリメントする
    audioFileIO->startingPacketCount += *ioNumberDataPackets;
    
    //ioDataに、読み込んだサイズを設定する
    ioData->mBuffers[0].mData = audioFileIO->srcBuffer;
    ioData->mBuffers[0].mDataByteSize = outNumBytes;
    ioData->mBuffers[0].mNumberChannels = audioFileIO->srcFormat.mChannelsPerFrame;
    
	//VBRの場合、outDataPacketDescriptionにpacketDescsを渡す必要がある
	///リニアPCMの場合は必要無い(NULLを渡す)
	if(outDataPacketDescription){
		*outDataPacketDescription = audioFileIO->packetDescs;
	}	
    return err;
}


static void	writeCompressionMagicCookie(AudioConverterRef audioConverter, 
                                        AudioFileID outfile){
    UInt32 cookieSize = 0;
    OSStatus err;
    err = AudioConverterGetPropertyInfo(audioConverter, 
                                        kAudioConverterCompressionMagicCookie, 
                                        &cookieSize, 
                                        NULL);
    if (!err && cookieSize) {
        char* cookie = malloc(sizeof(char) * cookieSize);
        AudioConverterGetProperty(audioConverter, 
                                  kAudioConverterCompressionMagicCookie, 
                                  &cookieSize, 
                                  cookie);
        AudioFileSetProperty(outfile, 
                             kAudioFilePropertyMagicCookieData, 
                             cookieSize,
                             cookie
                             );
        free(cookie);
    }
}

static void writeDecompressionMagicCookie(AudioConverterRef audioConverter, AudioFileID infile){
    UInt32 cookieSize;
    OSStatus err = AudioFileGetPropertyInfo(infile, 
                                            kAudioFilePropertyMagicCookieData, 
                                            &cookieSize, 
                                            NULL);
    
    if (err == noErr && cookieSize > 0){
        char *magicCookie = malloc(sizeof(UInt8) * cookieSize);
        UInt32	magicCookieSize = cookieSize;
        AudioFileGetProperty(infile,
                             kAudioFilePropertyMagicCookieData,
                             &magicCookieSize,
                             magicCookie);
        
        AudioConverterSetProperty(audioConverter,
                                  kAudioConverterDecompressionMagicCookie,
                                  magicCookieSize,
                                  magicCookie);
        free(magicCookie);
    }
}


-(void)convertFrom:(NSURL*)fromURL 
             toURL:(NSURL*)toURL 
            format:(AudioStreamBasicDescription)outputFormat
		  fileType:(UInt32)fileType{
    OSStatus err;//エラーチェックに使う    
				 //変換するサウンドファイルと書き出すサウンドファイルのAudioFileID
    AudioFileID infile, outfile;
    AudioStreamBasicDescription inputFormat;
    
    //変換対象のサウンドファイルを開く
    AudioFileOpenURL((__bridge CFURLRef)fromURL,
                     kAudioFileReadPermission, 
                     0, 
                     &infile);
    
    //変換するサウンドファイルのASBDを取得
    UInt32 size = sizeof(inputFormat);
    AudioFileGetProperty(infile, 
                         kAudioFilePropertyDataFormat, 
                         &size, &inputFormat);
	
	//ソースがモノラルの場合
	if (outputFormat.mFormatID  == kAudioFormatAppleLossless
		&& inputFormat.mChannelsPerFrame  == 1
		&& outputFormat.mChannelsPerFrame == 2) {
		//モノラルで書き出す
		outputFormat.mChannelsPerFrame = 1;
	}
    
    //書き出すサウンドファイルを作成
    err = AudioFileCreateWithURL((__bridge CFURLRef)toURL,
                                 fileType,
                                 &outputFormat, 
                                 kAudioFileFlags_EraseFile, 
                                 &outfile);
    //エラーチェック
    checkError(err, "AudioFileCreate");
    
    AudioConverterRef audioConverter;
    err = AudioConverterNew(&inputFormat, &outputFormat, &audioConverter);
    checkError(err, "AudioConverterNew");
    
    
	
    AudioFileIO audioFileIO;
    audioFileIO.audioFileID = infile;
    audioFileIO.srcBufferSize = 32768;
    audioFileIO.srcBuffer = malloc(sizeof(char) *audioFileIO.srcBufferSize);
    audioFileIO.startingPacketCount = 0;
    audioFileIO.srcFormat = inputFormat;
    
	/******* 入力に関する計算 ******/
	//最大パケットサイズから一度に読み込めるパケット数を計算する
	//(リニアPCMではmBytesPerPacketを使ってもよい)
	size = sizeof(UInt32);
	UInt32 maxPacketSize;
	err = AudioFileGetProperty(infile, 
							   kAudioFilePropertyPacketSizeUpperBound, 
							   &size, 
							   &maxPacketSize);
	checkError (err, "kAudioFilePropertyPacketSizeUpperBound");
	audioFileIO.numPacketsToRead = audioFileIO.srcBufferSize / maxPacketSize;
	audioFileIO.packetDescs = NULL;	
	BOOL isInputVBR = (inputFormat.mBytesPerPacket == 0 || inputFormat.mFramesPerPacket == 0);
	if(isInputVBR){
		audioFileIO.packetDescs = malloc(sizeof(AudioStreamPacketDescription) * audioFileIO.numPacketsToRead);
	}

	/******* 出力に関する計算 ******/
	//Audio Converterが変換後出力する最大のパケットのサイズを取得
	UInt32 maximumOutputPacketSize;
	size = sizeof(UInt32);
	err = AudioConverterGetProperty(
									audioConverter,
									kAudioConverterPropertyMaximumOutputPacketSize, 
									&size, 
									&maximumOutputPacketSize);
	checkError(err, "Get Max Packet Size");
	NSLog(@"maximumOutputPacketSize = %d",(unsigned int)maximumOutputPacketSize);
    
	//1度に取得できる（変換後の）最大パケット数
    UInt32 numOutputPackets = audioFileIO.srcBufferSize / maximumOutputPacketSize;
	
	AudioStreamPacketDescription* outputPacketDescs = NULL;
	BOOL isOutputVBR =  (outputFormat.mBytesPerPacket == 0 || outputFormat.mFramesPerPacket == 0);
	if(isOutputVBR){
		outputPacketDescs = malloc(sizeof(AudioStreamPacketDescription) * numOutputPackets);	
	}
	
	//マジッククッキーに対応
    writeDecompressionMagicCookie(audioConverter, infile);
    writeCompressionMagicCookie(audioConverter, outfile);
	
    char* outputBuffer = malloc(sizeof(char) * audioFileIO.srcBufferSize);
    
    //書き出すサウンドファイルの書き込み位置
    SInt64 outputPos = 0;
    while (1){
        //結果取得のためのバッファを用意する
        AudioBufferList fillBufList;
        fillBufList.mNumberBuffers = 1;
        fillBufList.mBuffers[0].mNumberChannels = inputFormat.mChannelsPerFrame;
        fillBufList.mBuffers[0].mDataByteSize = audioFileIO.srcBufferSize;
        fillBufList.mBuffers[0].mData = outputBuffer;
        
        //numOutputPackets == 一度に取得するパケット数
        UInt32 ioOutputDataPackets = numOutputPackets;

        err = AudioConverterFillComplexBuffer(audioConverter, 
                                              EncoderDataProc, 
                                              &audioFileIO, 
                                              &ioOutputDataPackets, 
                                              &fillBufList, 
                                              outputPacketDescs
											  );
        
        checkError (err, "AudioConverterFillComplexBuffer");
        //ioOutputDataPacketsが0 == 処理が終了なのでループを抜ける
        if (ioOutputDataPackets == 0)break;
        
		//kAudioFileBadPropertySizeError
        //取得したバッファをサウンドファイルに書き込む
        UInt32 inNumBytes = fillBufList.mBuffers[0].mDataByteSize;
        err = AudioFileWritePackets(outfile,
                                    NO, 
                                    inNumBytes, 
                                    outputPacketDescs,
                                    outputPos, 
                                    &ioOutputDataPackets, 
                                    outputBuffer);
        checkError (err, "AudioFileWritePackets");
        //書き出すサウンドファイルの書き込み位置をインクリメントする
        outputPos += ioOutputDataPackets;
    }
    
    //確保したバッファを破棄
	free(audioFileIO.srcBuffer);
	if(audioFileIO.packetDescs)free(audioFileIO.packetDescs);
    free(outputPacketDescs);
    free(outputBuffer);
	
	//マジッククッキーを再度書き込む
    writeCompressionMagicCookie(audioConverter, outfile);
    
    //Audio Conveterを破棄し、サウンドファイルをクローズする
    AudioConverterDispose(audioConverter);
    AudioFileClose(outfile);
    AudioFileClose(infile);
}

@end