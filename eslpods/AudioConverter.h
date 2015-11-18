//
//  AudioConverter.h
//  ConvertLossless
//
//  Created by Norihisa Nagano
//

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioConverter.h>

@interface AudioConverter : NSObject {
}

-(void)convertFrom:(NSURL*)fromURL 
			 toURL:(NSURL*)toURL 
			format:(AudioStreamBasicDescription)outputFormat
		  fileType:(UInt32)fileType;
@end