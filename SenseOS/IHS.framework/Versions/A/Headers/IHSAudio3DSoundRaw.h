///
///  @file IHSAudio3DSoundRaw.h
///  IHS API
///
///  Copyright (c) 2015 GN Store Nord A/S. All rights reserved.
///

#import "IHSAudio3DSound.h"
#import <CoreAudio/CoreAudioTypes.h>

/**
 @brief                 Class representing one sound to playback
 */
@interface IHSAudio3DSoundRaw : IHSAudio3DSound

/**
 @brief                 Describes the audio format in which data must be delivered.
 */
@property (readonly, nonatomic) AudioStreamBasicDescription audioFormat;

/**
 @brief                 The size in bytes of the buffer used for queing audio data
 */
@property (readonly, nonatomic) NSUInteger bufferSize;

/**
 @brief                 The amount of byte currently free of the audio buffer
 */
@property (readonly, nonatomic) NSUInteger bufferFree;


/**
 @brief                 Initializes this class with a standard sample rate of 44100 mono and a 256K buffer size
 @param title           The title of the sound
 @return                The successfully initialized instance or nil.
 */
- (instancetype)initWithTitle:(NSString*)title;

/**
 @brief                 Initializes this class giving the sample rate to use
 @param sampleRate      The samplerate for the audio. Must be 22050 or 44100. Default is 44100 if zero is parsed.
 @param numberOfChannels Number of channels per frame. Must be 1 (mono) or 2 (stereo).
                        Mono is preferred as a steroe stream will be downsampled to mono on the fly.
 @param bufferSize      The size of the memory buffer to allocate. The buffer is used to hold audio data until it is consumed by the 3D audio engine.
 @param title           The title of the sound
 @return                The successfully initialized instance or nil.
 */
- (instancetype)initWithSampleRate:(Float64)sampleRate numberOfChannels:(UInt32)numberOfChannels bufferSize:(UInt32)bufferSize andTitle:(NSString*)title NS_DESIGNATED_INITIALIZER;

/**
 @brief                 Writes audio data to the buffer.
 @details               The audio data must be in the format described by {@link audioFormat}
 @param numPackets      The number of audio data packets to write.
 @param startingPacket  The starting packet within buffer.
 @param buffer          The actual buffer holding audio data. It must be in the format described by {@link audioFormat}
 @param bufferSize      The size of the buffer in bytes
 @return                The number of packet actually written. The only reason for this to be less than numPackets
                        is if the internal memory buffer is full. Wait for the 3D audio engine to consume some data and write again.
 */
- (UInt32)writePackcets:(UInt32)numPackets startingPacket:(SInt64)startingPacket buffer:(const void *)buffer bufferSize:(UInt32)bufferSize;

/**
 @brief                 Clears the buffer of already written data.
 */
- (void)clear;

@end
