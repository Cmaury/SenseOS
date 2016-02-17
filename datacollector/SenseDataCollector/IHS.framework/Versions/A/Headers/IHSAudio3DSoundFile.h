///
///  @file IHSAudio3DSoundFile.h
///  IHS API
///
///  Created by Martin Lobger on 08/11/2015.
///  Copyright (c) 2015 GN Store Nord A/S. All rights reserved.
///

#import "IHSAudio3DSound.h"

/**
 @brief                 Class representing one sound to playback from a file souce
 */
@interface IHSAudio3DSoundFile : IHSAudio3DSound

/**
 @brief                 URL of the sound to load and playback
 @details               Only local files of uncompressed .wav with 16 bit/ 44.1 kHz or lower resolution and bitrate are supported
 */
@property (nonatomic, strong) NSURL* url;


/**
 @brief                 The url of the sound file to load
 @details               For now only local file URLs are supported.
                        Also the sound file must be in wave format with max 16 bit pr sample
 @param url             The url to a local file, either as a resource in your app bundle or as a file in e.g. the documents folder.
 @return                The successfully initialized instance or nil.
 */
- (id)initWithURL:(NSURL*)url NS_DESIGNATED_INITIALIZER;

@end
