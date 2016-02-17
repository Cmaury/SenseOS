///
///  @file IHSDevice.h
///  IHS API
///
///  Copyright (c) 2015 GN Store Nord A/S. All rights reserved.
///
#import <AudioToolbox/AudioToolbox.h>
#import <CoreLocation/CoreLocation.h>
#import <IHS/IHSAudio3D.h>
#import <IHS/IHSAudio3DSound.h>
#import <IHS/IHSAudio3DSound.h>
@import UIKit;

@protocol IHSDeviceDelegate;
@protocol IHSSensorsDelegate;
@protocol IHSButtonDelegate;
@protocol IHS3DAudioDelegate;
@protocol IHSSoftwareUpdateDelegate;


/**
 @brief                 IHS device connection states
 */
typedef NS_ENUM(NSInteger, IHSDeviceConnectionState)
{
    IHSDeviceConnectionStateNone,
    IHSDeviceConnectionStateBluetoothOff,                   ///< Bluetooth is turned off. It should be turned on in order to connect.
    IHSDeviceConnectionStateDiscovering,                    ///< The SDK are looking for available headsets in the near proximity.
    IHSDeviceConnectionStateDisconnected,                   ///< The headset disconnected. Could be because it was turned off or got out of range.
    IHSDeviceConnectionStateLingering,                      ///< If we have not received data from the headset for a while even though we are still conncted.\n If this state occurs, it is typically a preliminary state to disconnecting.
    IHSDeviceConnectionStateConnecting,                     ///< The from when a connection to a headset has been initiated until it is fully connected.
    IHSDeviceConnectionStateConnected,                      ///< The state when the heaset is connected and ready to use.
    IHSDeviceConnectionStateConnectionFailed    = -1,       ///< The connection to the headset failed. This is different from disconnected.
};


/**
 @brief                 IHS buttons
 */
typedef NS_ENUM(NSInteger, IHSButton)
{
    IHSButtonRight,                                         ///< Identifying the right button
    IHSButtonLeft,                                          ///< Identifying the left button
    IHSButtonNoButton                           = -1,
};


/**
 @brief                 IHS button events
 @note                  IHSButtonEventTap, IHSButtonEventPress and IHSButtonEventDoubleTap are available on IHSButtonRight@n
                        IHSButtonEventTap is available on IHSButtonLeft
 @return
 */
typedef NS_ENUM(NSInteger, IHSButtonEvent)
{
    IHSButtonEventTap,                                      ///< A button was tapped
    IHSButtonEventPress,                                    ///< A button was pressed
    IHSButtonEventDoubleTap,                                ///< A button was double tabbed
    IHSButtonEventNoEvent                       = -1,
};


/**
 @brief                 IHS Button Source
 */
typedef NS_ENUM(NSInteger, IHSButtonSource)
{
    IHSButtonSourceHeadset,                                 ///< Identifying wireless button
    IHSButtonSourceGeneric,                                 ///< Identifying generic button - e.g. button on a wire
    IHSButtonSourceUnknown                      = -1,       ///< Identifying unknown source
};


/**
 @brief                 Structure used when handling 3 axis data (x, y, z)
 */
typedef struct IHSAHRS3AxisStruct
{
    double x;           ///< The x value of the 3 axis (X, y, z)
    double y;           ///< The y value of the 3 axis (x, Y, z)
    double z;           ///< The z value of the 3 axis (x, y, Z)
} IHSAHRS3AxisStruct;


/**
 @brief                 The schedule which the software update site is checked for new headset firmware.
 */
typedef NS_ENUM(NSInteger, IHSSoftwareUpdateCheckLatestVersionSchedule)
{
    IHSSoftwareUpdateCheckLatestVersionScheduleManual,      ///< Application controls schedule by callin checkForSoftwareUpdate.
    IHSSoftwareUpdateCheckLatestVersionScheduleAlways,      ///< Always check if a new sw update is available.
    IHSSoftwareUpdateCheckLatestVersionScheduleDaily,       ///< Only check sw update site once a day.
};


/**
 @brief                 IHS audio error codes
 @details               AudioFile error codes from <AudioToolbox/AudioToolbox.h>.
                        These are the error codes returned from the AudioFile API.
 @param IHSAudioErrorIHSNotConnected
                        No IHS device connected when trying to play back 3D audio
 @param IHSAudioErrorUnspecifiedError
                        An unspecified error has occurred.
 @param IHSAudioErrorUnsupportedFileTypeError
                        The file type is not supported.
 @param IHSAudioErrorUnsupportedDataFormatError
                        The data format is not supported by this file type.
 @param IHSAudioErrorUnsupportedPropertyError
                        The property is not supported.
 @param IHSAudioErrorBadPropertySizeError
                        The size of the property data was not correct.
 @param IHSAudioErrorPermissionsError
                        The operation violated the file permissions. For example, trying to write to a file opened with kAudioFileReadPermission.
 @param IHSAudioErrorNotOptimizedError
                        There are chunks following the audio data chunk that prevent extending the audio data chunk.
                        The file must be optimized in order to write more audio data.
 @param IHSAudioErrorInvalidChunkError
                        The chunk does not exist in the file or is not supported by the file.
 @param IHSAudioErrorDoesNotAllow64BitDataSizeError
                        The a file offset was too large for the file type. AIFF and WAVE have a 32 bit file size limit.
 @param IHSAudioErrorInvalidPacketOffsetError
                        A packet offset was past the end of the file, or not at the end of the file when writing a VBR format,
                        or a corrupt packet size was read when building the packet table.
 @param IHSAudioErrorInvalidFileError
                        The file is malformed, or otherwise not a valid instance of an audio file of its type.
 @param IHSAudioErrorOperationNotSupportedError
                        The operation cannot be performed. For example, setting kAudioFilePropertyAudioDataByteCount to increase
                        the size of the audio data in a file is not a supported operation. Write the data instead.
 @param IHSAudioErrorNotOpenError
                        The file is closed.
 @param IHSAudioErrorEndOfFileError
                        End of file.
 @param IHSAudioErrorPositionError
                        Invalid file position.
 @param IHSAudioErrorFileNotFoundError
                        File not found.
 @return
 */
typedef NS_ENUM(NSInteger, IHSAudioErrorCodes)
{
    IHSAudioErrorIHSNotConnected                    = 'noih',                                   //< 'noih', 0x6E6F6968, 1852795240
    IHSAudioErrorUnspecifiedError                   = kAudioFileUnspecifiedError,               //< 'typ?', 0x7768743F, 2003334207
    IHSAudioErrorUnsupportedFileTypeError           = kAudioFileUnsupportedFileTypeError,       //< 'typ?', 0x7479703F, 1954115647
    IHSAudioErrorUnsupportedDataFormatError         = kAudioFileUnsupportedDataFormatError,     //< 'fmt?', 0x666D743F, 1718449215
    IHSAudioErrorUnsupportedPropertyError           = kAudioFileUnsupportedPropertyError,       //< 'pty?', 0x7074793F, 1886681407
    IHSAudioErrorBadPropertySizeError               = kAudioFileBadPropertySizeError,           //< '!siz', 0x2173697A,  561211770
    IHSAudioErrorPermissionsError                   = kAudioFilePermissionsError,               //< 'prm?', 0x70726D3F, 1886547263
    IHSAudioErrorNotOptimizedError                  = kAudioFileNotOptimizedError,              //< 'optm', 0x6F70746D, 1869640813
    // file format specific error codes
    IHSAudioErrorInvalidChunkError                  = kAudioFileInvalidChunkError,              //< 'chk?', 0x63686B3F, 1667787583
    IHSAudioErrorDoesNotAllow64BitDataSizeError     = kAudioFileDoesNotAllow64BitDataSizeError, //< 'off?', 0x6F66663F, 1868981823
    IHSAudioErrorInvalidPacketOffsetError           = kAudioFileInvalidPacketOffsetError,       //< 'pck?', 0x70636B3F, 1885563711
    IHSAudioErrorInvalidFileError                   = kAudioFileInvalidFileError,               //< 'dta?', 0x6474613F, 1685348671
    IHSAudioErrorOperationNotSupportedError         = kAudioFileOperationNotSupportedError,     //< 'op??', 0x6F703F3F, 1869627199 integer used because of trigraph
    // general file error codes
    IHSAudioErrorNotOpenError                       = kAudioFileNotOpenError,                   //< -38
    IHSAudioErrorEndOfFileError                     = kAudioFileEndOfFileError,                 //< -39
    IHSAudioErrorPositionError                      = kAudioFilePositionError,                  //< -40
    IHSAudioErrorFileNotFoundError                  = kAudioFileFileNotFoundError,              //< -43
};



#pragma mark - IHSDevice interface

/**
 @brief                 The main interface for interacting with an IntelligentHeadset™
 */
@interface IHSDevice : NSObject

#pragma mark Delegates

/**
 @brief                 The object to receive device notifications on.
 */
@property (weak, nonatomic) id<IHSDeviceDelegate> deviceDelegate;

/**
 @brief                 The object to receive sensor data notifications on.
 */
@property (weak, nonatomic) id<IHSSensorsDelegate> sensorsDelegate;

/**
 @brief                 The object to receive 3D audio notifications on.
 */
@property (nonatomic, weak) id<IHS3DAudioDelegate> audioDelegate;

/**
 @brief                 The object to receive button notifications on.
 */
@property (weak, nonatomic) id<IHSButtonDelegate> buttonDelegate;

/**
 @brief                 The object to receive software update notifications on.
 */
@property (weak, nonatomic) id<IHSSoftwareUpdateDelegate> softwareUpdateDelegate;

/**
 @brief                 IHS API version.
 */
@property (readonly, nonatomic) NSString* apiVersion;

/**
 @brief                 Last known latitude.
 */
@property (readonly, nonatomic) double latitude;

/**
 @brief                 Last known longitude.
 */
@property (readonly, nonatomic) double longitude;

/**
 @brief                 Last known GPS location.
 */
@property (readonly, nonatomic) CLLocation* location;

/**
 @brief                 Last known GPS signal indicator.
 @details               0.00:   No signal
                        0.25:   2D fix
                        0.50:   2D fix and SBAS fix
                        0.75:   3D fix
                        1.00:   3D fix and SBAS fix
 */
@property (readonly, nonatomic) float GPSSignalIndicator;

/**
 @brief                 Last known horizontal accuracy.
 @details               A value of '-1' indicates that the GPS position is not valid.
 */
@property (readonly, nonatomic) double horizontalAccuracy;

/**
 @brief                 Last known fused heading (gyro and magnetometer).
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float fusedHeading;

/**
 @brief                 Last known compass heading (magnetometer).
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float compassHeading;

/**
 @brief                 Last known yaw (gyro heading).
 @details               The range goes from 0 -> 359.9
 */
@property (readonly, nonatomic) float yaw;

/**
 @brief                 Last known roll (gyro).
 @details               The range goes from -180.0 -> +180.0
 */
@property (readonly, nonatomic) float roll;

/**
 @brief                 Last known pitch (gyro).
 @details               The range goes from -90.0 -> +90.0
 */
@property (readonly, nonatomic) float pitch;

/**
 @brief                 Last known accelerometer data (accelerometer).
 @details               The range goes from -2g -> 2g for each axis.
 */
@property (readonly, nonatomic) IHSAHRS3AxisStruct accelerometerData;

/**
 @brief                 Set to YES if sensors detect magnetic disturbance, else NO.
 */
@property (readonly, assign) BOOL magneticDisturbance;

/**
 @brief                 The last known magnetic field strength for the IHS device
 @details               Field strength is reported in milligauss.
 */
@property (readonly, assign) NSInteger magneticFieldStrength;

/**
 @brief                 Set to YES if no movement detected for at least 10s after startup,
                        i.e., the gyro can be assumed autocalibrated.
                        Otherwise NO.
 */
@property (readonly, assign) BOOL gyroCalibrated;

/**
 @brief                 Name of the connected IHS device.
 */
@property (readonly, nonatomic) NSString* name;

/**
 @brief                 Firmware revision of the connected IHS device.
 */
@property (readonly, nonatomic) NSString* firmwareRevision;

/**
 @brief                 Hardware revision of the connected IHS device.
 */
@property (readonly, nonatomic) NSString* hardwareRevision;

/**
 @brief                 Software revision of the connected IHS device.
 */
@property (readonly, nonatomic) NSString* softwareRevision;

/**
 @brief                 Connection state of the IHSDevice.
 */
@property (readonly, nonatomic) IHSDeviceConnectionState connectionState;

/**
 @brief                 The sounds currently in the playback pool.
 @details               A sound being present here does not mean that it is nessesary being played back.
                        It can be paused, or have an offset in the future or have finished already.
 */
@property (nonatomic, readonly) NSArray* sounds;

/**
 @brief                 Flag controlling the order of how sounds are played back.
 @details               If YES, all sounds are played back in sequence and new sounds added are played last.
                        If NO, all sounds are played simultaniously taking sound offset etc. into account.
 */
@property (nonatomic, assign) BOOL sequentialSounds;

/**
 @brief                 The total duration of the loaded sound resources including offsets.
 */
@property (nonatomic, readonly) NSTimeInterval playerDuration;

/**
 @brief                 The current time of the sound resource.
 */
@property (nonatomic) NSTimeInterval playerCurrentTime;

/**
 @brief                 Update the 3D audio player with the direction the user is looking.
 @details               The 3D audio player will rotate all the loaded sounds based on the heading set here
                        without manipulating the individual sound's heading.
 */
@property (nonatomic, assign) float playerHeading;

/**
 @brief                 Update the 3D audio player with the altitude of the user (in millimeters).
 @details               The 3D audio player will adjust all the loaded sounds based on the altitude set here
                        without manipulating the individual sound's altitude.
 */
@property (nonatomic, assign) SInt32 playerAltitude;

/**
 @brief                 The reverb level in millibels (1/100 dB).
 @details               The reverb level goes from -infinit to 0 where 0 is full reverb.
                        A value of INT_MIN will disable reverb.
 */
@property (nonatomic, assign) SInt32 playerReverbLevel;

/**
 @brief                 The reverb preset. @see IHSAudio3DReverbPreset.
 @details               Each reverb preset also has a default reverberation time when selected. When selecting a 
                        new preset, the reverb time parameter is changed to the default value for that preset.
 */
@property (nonatomic, assign) IHSAudio3DReverbPreset playerReverbPreset;

/**
 @brief                 The reverb time
 @details               The reverberation time is the time it takes for the reverberant sound to attenuate by 60 dB
                        from its initial level. Typical values are in the range from 100 to 10000 milliseconds.
                        Note that each reverb preset has a default reverberation time when selected. After selecting
                        a reverb preset, this property can be used to further tweak the sound of the reverberation.
 */
@property (nonatomic, assign) SInt32 playerReverbTime;

/**
 @brief                 Is the 3D audio player playing?
 */
@property (nonatomic, readonly) BOOL isPlaying;

/**
 @brief                 Is the 3D audio player paused?
 */
@property (nonatomic, readonly) BOOL isPaused;

/**
 @brief                 Check if the 3D audio player is able to play sound.
 */
@property (nonatomic, readonly) BOOL canPlay;


/**
 @brief                 Set the deviceDelegate upon initializing the IHSDevice.
 @param deviceDelegate  The deviceDelegate to use.
 @return                The successfully initialized instance or nil.
 */
- (instancetype)initWithDeviceDelegate:(id<IHSDeviceDelegate>)deviceDelegate;

/**
 @brief                 Establish connection to the physical IHS devices.
 @details               If no preferred device has previously been set, a callback will be made to ihsDeviceFoundAmbiguousDevices:
                        on the IHSDeviceDelegate.
                        Calling connect while the IHSDevice is in IHSDeviceConnectionStateConnected state will result
                        in a disconnect followed by a (re)connect.
 @see                   showDeviceSelection:
 */
- (void)connect;


/**
 @brief                 Close the connection to the physical IHS and pause all 3D audio playback.
 */
- (void)disconnect;


/**
 @brief                 Show a list of discovered physical IHS devices it is possible to connect to.
 @details               This method should only be called after receiving the.
                        ihsDeviceFoundAmbiguousDevices: message on the IHSDeviceDelegate.
 @param parentViewController
                        The view controller that the device selection should be placed "on top of".
 */
- (void)showDeviceSelection:(UIViewController*)parentViewController;


#pragma mark 3D audio handling

/**
 @brief                 Adds a sound to playback along with other sounds.
 @details               Currently only files on the local file system is supported.
 @param sound           The sound resource to load and playback.
 */
- (void)addSound:(IHSAudio3DSound*)sound;

/**
 @brief                 Removes a sound from the playback pool.
 @param sound           The sound to remove. This sound will stop playing and then be removed.
 */
- (void)removeSound:(IHSAudio3DSound*)sound;

/**
 @brief                 Removes all sounds from the player.
 */
- (void)clearSounds;

/**
 @brief                 Start the playback of the sound resource.
 @details               The sound resource to playback must have been set with loadURL: before calling this method.
 @note                  Playback can only be started when the IHS device is connected. If the play method is called
                        while the IHS device is not connected, error status 'IHSAudioErrorIHSNotConnected' will be 
                        returned through the delegate via ihsDevice:playerRenderError:
 */
- (void)play;

/**
 @brief                 Pauses playback.
 @details               Playback can be resumed with a call to the play method and will resume at the point where it was paused.
 */
- (void)pause;

/**
 @brief                 Stops playback.
 @details               Playback can be resumed with a call to the play method and will resume from the beginning of the sound resource.
 */
- (void)stop;


#pragma mark Software update related properties and methods

/**
 @brief                 The current schedule that checks for new software availability runs with.
 */
@property (nonatomic) IHSSoftwareUpdateCheckLatestVersionSchedule   softwareUpdateSchedule;

/**
 @brief                 Controls whether connected devices are automatically updated.
 */
@property (nonatomic) BOOL softwareUpdateConnectedDevicesAutomatically;

/**
 @brief                 Determine if a software update is in progress.
 */
@property (nonatomic, readonly) BOOL softwareUpdateInProgress;

/**
 @brief                 Progress of a running software update.  Only valid/useful when softwareUpdateInProgress == YES.
 */
@property (nonatomic, readonly) float softwareUpdateProgressPercentage;

/**
 @brief                 Start time of a running software update. nil when no update is in progress.
 */
@property (nonatomic, readonly, strong) NSDate* softwareUpdateStartTime;

/**
 @brief                 End time of a successfully finished software update. Nil until then.
 */
@property (nonatomic, readonly, strong) NSDate* softwareUpdateEndTime;

/**
 @brief                 Expected end time of a running software update.  Nil when no update is in progress.
 */
@property (nonatomic, readonly, strong) NSDate* softwareUpdateExpectedEndTime;

/**
 @brief                 Determine if a software update is available for the currently connected headset.
 */
@property (nonatomic, readonly) BOOL softwareUpdateAvailable;

/**
 @brief                 The currently active build number of the software in the headset.
 */
@property (nonatomic, readonly) NSNumber* currentBuildNumber;

/**
 @brief                 The currently active build number of the software in the headset.
 */
@property (nonatomic, readonly) NSNumber* latestBuildNumber;

/**
 @brief                 Manually trigger a check for new software.
 */
- (void)checkForSoftwareUpdate;

/**
 @brief                 Manually trigger a software update.
 @return                YES if a software update was started.
 */
- (BOOL)beginSoftwareUpdate;

/**
 @brief                 Abort any running software update.
 */
- (void)abortSoftwareUpdate;

@end


#pragma mark - Deprecated Methods and properties

/**
 @brief                 Category for deprecated functionality.
 */
@interface IHSDevice (Deprecated)


/**
 @brief                 Provide the API key unique to your app to unlock the functionality of the IHS API.
 @details               Register your app at https://developer.intelligentheadset.com to get an API key for your app
                        The validity of the provided API key can be retreived via the validAPIKeyProvided property.
 @param apiKey          The API key unique to your app.
 @deprecated            We no longer require an API key. Calls will be ignored
 */
- (void)provideAPIKey:(NSString*)apiKey DEPRECATED_MSG_ATTRIBUTE("We no longer require an API key. Calls will be ignored");

/**
 @brief                 YES when a valid API key has been provided through provideAPIKey:, NO otherwise.
 @deprecated            We no longer require an API keyand any use will be ignored
 */
@property (readonly, nonatomic) BOOL validAPIKeyProvided DEPRECATED_MSG_ATTRIBUTE("We no longer require an API keyand any use will be ignored");

/**
 @brief                 Name of the preferred physical IHS device.
 @deprecated            This property is no longer used. It returns nil and ignores writes.
 */
@property (copy, nonatomic) NSString* preferredDevice DEPRECATED_MSG_ATTRIBUTE("This property is no longer used. It returns nil and ignores writes.");


/**
 @brief                 Set to NO if no movement detected for at least 10s after startup,
                        i.e., the gyro can be assumed autocalibrated.
                        Otherwise YES.
 @deprecated            Please use gyroCalibrated property instead
 */
@property (nonatomic, readonly) BOOL gyroUncalibrated DEPRECATED_MSG_ATTRIBUTE("Please use gyroCalibrated property instead");

/**
 @brief                 Set the preferred device upon initializing the IHSDevice.
 @details               The API will attempt to connect to the preferred set here, when connect is called.
 @param preferredDevice Name of the preferred device to connect to.
 @return                The successfully initialized instance or nil.
 @deprecated            This method is obsolete. We no longer use preferredDevice.@nPlease use initWithDeviceDelegate: instead
 */
- (IHSDevice*)initWithPreferredDevice:(NSString*)preferredDevice DEPRECATED_MSG_ATTRIBUTE("This method is obsolete. We no longer use preferredDevice. Please use initWithDeviceDelegate: instead");

@end


#pragma mark - IHSDeviceDelegate

/**
 @brief                 Delegate protocol used for receiving status on your IntelligentHeadset™
 */
@protocol IHSDeviceDelegate <NSObject>

@optional

/**
 @brief                 Notify that the connection state has changed.
 @details               Called everytime the connection state of the IHS changes.
 @param ihs             The IHS device the connection state was changed on.
 @param connectionState The new connection state the IHS device changed to.
 */
- (void)ihsDevice:(IHSDevice*)ihs connectionStateChanged:(IHSDeviceConnectionState)connectionState;

@required
/**
 @brief                 Notify that no connection to any paired headset could be made.
 @details               Called when other devices besides any paired headset have been found.@n
                        The method IHSDevice#showDeviceSelection: should be called in order for the user to be able to select a device.
 @param ihs             The IHS device reporting ambiguous devices.
 */
- (void)ihsDeviceFoundAmbiguousDevices:(IHSDevice*)ihs;

@end


#pragma mark - IHSSensorsDelegate

/**
 @brief                 Delegate protocol used for receiving sensors data from the IntelligentHeadset™
 */
@protocol IHSSensorsDelegate <NSObject>

@optional

/**
 @brief                 Notify that the fused heading has changed.
 @details               Called everytime the fused heading reported by the IHS changes.
 @param ihs             The IHS device the fused heading was changed on.
 @param heading         Fused heading (gyro and magnetometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs fusedHeadingChanged:(float)heading;


/**
 @brief                 Notify that the compass heading has changed.
 @details               Called everytime the compass heading reported by the IHS changes.
 @param ihs             The IHS device the compass heading was changed on.
 @param heading         Heading (magnetometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs compassHeadingChanged:(float)heading;


/**
 @brief                 Notify that the yaw, pitch and roll on the gyro has changed.
 @details               Called everytime the gyro information reported by the IHS changes.
 @param ihs             The IHS device where the gyro has changed.
 @param yaw             Yaw (gyro)
 @param pitch           Pitch (gyro)
 @param roll            Roll (gyro)
 */
- (void)ihsDevice:(IHSDevice*)ihs didChangeYaw:(float)yaw pitch:(float)pitch andRoll:(float)roll;


/**
 @brief                 Notify that the horizontal accuracy has changed.
 @details               Called everytime the horizontal accuracy reported by the IHS changes.
 @param ihs             The IHS device the horizontal accuracy was changed on.
 @param horizontalAccuracy
                        The Horizontal accuracy for the GPS in meters.
 */
- (void)ihsDevice:(IHSDevice*)ihs horizontalAccuracyChanged:(double)horizontalAccuracy;


/**
 @brief                 Notify that the GPS position has changed.
 @details               Called everytime the GPS position reported by the IHS changes.
 @param ihs             The IHS device the GPS position was changed on.
 @param latitude        Latitude (GPS)
 @param longitude       Longitude (GPS)
 */
- (void)ihsDevice:(IHSDevice*)ihs locationChangedToLatitude:(double)latitude andLogitude:(double)longitude;


/**
 @brief                 Notify that the accelerometer data has changed.
 @details               Called everytime the accelerometer data reported by the IHS changes.
 @param ihs             The IHS device which the accelerometer data was changed on.
 @param data            3 axis accelerometer data (accelerometer)
 */
- (void)ihsDevice:(IHSDevice*)ihs accelerometer3AxisDataChanged:(IHSAHRS3AxisStruct)data;

/**
 @brief                 Notify that magnetic disturbance has been detected.
 @details               You should not rely on the compass heading during disturbance.
 @param ihs             The IHS device which experiences magnetic disturbance.
 @param magneticDisturbance
                        YES if magnetic disturbance is detected, else NO.
 */
- (void)ihsDevice:(IHSDevice*)ihs magneticDisturbanceChanged:(BOOL)magneticDisturbance;


/**
 @brief                 Notify that the magnetic field strength has changed.
 @details               Called every time the magnetic field strength changes.
 @param ihs             The IHS device which the magnetic field strength was changed on.
 @param magneticFieldStrength
                        The magnetic field strength in milligauss.
 */
- (void)ihsDevice:(IHSDevice*)ihs magneticFieldStrengthChanged:(NSInteger)magneticFieldStrength;


/**
 @brief                 Notify that the gyro has become calibrated.
 @details               If gyroCalibrated is NO, you should lay down the IntelligentHeadset™ on
                        a plane surface and leave it untouched for 10 seconds in order for it 
                        to calibrate.
 @param ihs             The IHS device in which the gyro has changed calibration state.
 @param gyroCalibrated  YES when the gyro becomes calibrated, else NO.
 @note                  Right now, an IntelligentHeadset™ will start uncalibrated after power up.
                        This message will not be sent in this case.
                        If the headset then becomes calibrated this message will be sent.
 */
- (void)ihsDevice:(IHSDevice*)ihs gyroCalibrated:(BOOL)gyroCalibrated;


@end


#pragma mark - IHSButtonDelegate

/**
 @brief                 Delegate protocol for receiving information about button presses on the IntelligentHeadset™
 */
@protocol IHSButtonDelegate <NSObject>

@required

/**
 @brief                 Notify that an IHS button was pressed.
 @details               Called everytime an IHS button is pressed.
 @param ihs             The IHS device which the IHS button was pressed on.
 @param button          The IHS button that was pressed.
 @param event           The IHS button event on the pressed button.
 @param source          The source of the button.
 @note                  This message replaces ihsDevice:didPressIHSButton:withEvent.@n
                        The old message will still be called, if the new one is not yet implemented.
 */
- (void)ihsDevice:(IHSDevice*)ihs didPressIHSButton:(IHSButton)button withEvent:(IHSButtonEvent)event fromSource:(IHSButtonSource)source;

@end


#pragma mark - IHS3DAudioDelegate

/**
 @brief                 Delegate protocol used for receiving information about Audio 3D playback
 */
@protocol IHS3DAudioDelegate <NSObject>

@optional

/**
 @brief                 Sent as a result of a call to the play method.
 @param ihs             The IHS device instance the playback is requested started on.
 @param success         YES if playback has started, else NO.
 */
- (void)ihsDevice:(IHSDevice*)ihs playerDidStartSuccessfully:(BOOL)success;


/**
 @brief                 Sent as a result of a call to the pause method.
 @param ihs             The IHS device instance the playback is requested paused on.
 @param success         YES if playback was paused, else NO.
 */
- (void)ihsDevice:(IHSDevice*)ihs playerDidPauseSuccessfully:(BOOL)success;


/**
 @brief                 Sent as a result of a call to the stop method.
 @param ihs             The IHS device instance the playback is requested stopped on.
 @param success         YES if playback was stopped, else NO.
 */
- (void)ihsDevice:(IHSDevice*)ihs playerDidStopSuccessfully:(BOOL)success;


/**
 @brief                 Sent during playback as progress moves forward.
 @details               This message is sent twice a second.
 @param ihs             The IHS device instance playing the audio.
 @param currentTime     The current time in seconds.
 @param duration        The duration of the sound resource.
 */
- (void)ihsDevice:(IHSDevice*)ihs playerCurrentTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;


/**
 @brief                 Sent if an error occurred during sound rendering.
 @details               A typical error that can occur is an unsupported file or data format.@n
                        E.g. 32bit samples are not supported.
 @param ihs             The IHS device instance.
 @param status          Error status 'IHSAudioErrorIHSNotConnected' indicates that 3D audio playback was attempted started
                        before the IHS device was connected.
 @see                   IHSAudioErrorCodes
 */
- (void)ihsDevice:(IHSDevice*)ihs playerRenderError:(OSStatus)status;

@end


#pragma mark - IHSSoftwareUpdateDelegate

/**
 @brief                 Delegate protocol used for receiving information about software update on the IntelligentHeadset™
 */
@protocol IHSSoftwareUpdateDelegate <NSObject>

@required

/**
 @brief                 Called by IHS to see if it is allowed to check for new software from the update server.
 @details               Can be used by the applciation to for example allow IHSDevice network access only when WiFi is present.
                        (It is up to the application to detect WiFi presence).@n
                        If the IHSDevice has no associated IHSSoftwareUpdateDelegate, the default value is to always allow
                        check for software update.@n
                        If the application needs to ask the user for permission, it should return NO from this method,
                        and once the user has allowed a check for new software to be performed call IHSDvice:checkForSoftwareUpdate.
 @param ihs             The IHS device instance requesting network access.
 @return YES            If the application allows the IHSDevice to access the software update server.
 @return NO             If network access is not permitted.
 */
- (BOOL)ihsDeviceShouldCheckForSoftwareUpdateNow:(IHSDevice*)ihs;

@optional

/**
 @brief                 Called when ihs build or latest build number is detected.
 @param ihs             The IHS device instance the buildnumber corresponds to.
 @param deviceBuildNumber
                        Build number of the currently connected device, may be nil of the build number is not yet available.
 @param latestBuildNumber
                        Build number of the latest sowftare available, may be nil of the build number is not yet available.
 */
- (void)ihsDevice:(IHSDevice*)ihs didFindDeviceWithBuildNumber:(NSNumber*)deviceBuildNumber latestBuildNumber:(NSNumber*)latestBuildNumber;

/**
 @brief                 Called by ihs to see if the application allows the currently connected headset to be updated now.@n
                        If the IHSDevice has no associated IHSSoftwareUpdateDelegate or the delegate does not implement
                        shouldBeginSoftwareUpdateWithInfo, the default value is to always allow a software update to be performed.@n
                        If the application needs to ask the user for permission, it should return NO from this method,
                        and once the user has allowed the software update to be performed call IHSDvice:beginSoftwareUpdate.
 @param ihs             The IHS device instance requesting permission to software update a connected headset.
 @param info            Dictionary with information about software update. For future use, currently always nil.
 @return YES            If the application allows the IHSDevice to update the software in the connected headset.
 @return NO             If software update is not permitted now.
 */
- (BOOL)ihsDevice:(IHSDevice*)ihs shouldBeginSoftwareUpdateWithInfo:(NSDictionary*)info;

/**
 @brief                 Called by ihs is about to start the software update of the connected headset.
 @param ihs             The IHS device about to software update the connected headset.
 @param info            Metadata about the update. (currently always nil or empty dictionary)
 */
- (void)ihsDevice:(IHSDevice*)ihs willBeginSoftwareUpdateWithInfo:(NSDictionary*)info;

/**
 @brief                 Called by ihs to inform about.
 @param ihs             The IHS device updating the connected headset.
 @param percent         The current progress of the update. 0..100.
 @param eta             The expected point in time the update will finish.
 */
- (void)ihsDevice:(IHSDevice*)ihs softwareUpdateProgressedTo:(float)percent ETA:(NSDate*)eta;

/**
 @brief                 Called by ihs when the software update has finished.
 @param ihs             The IHS device performing the software update of the connected headset.
 @param success         YES or NO.
 */
- (void)ihsDevice:(IHSDevice*)ihs didFinishSoftwareUpdateWithResult:(BOOL)success;

/**
 @brief                 Called by ihs if the software update fails.
 @param ihs             The IHS device performing the software update of the connected headset.
 @param error           The error that occurred.
 */
- (void)ihsDevice:(id)ihs didFailSoftwareUpdateWithError:(NSError*)error;


@end


