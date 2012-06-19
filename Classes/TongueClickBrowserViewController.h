//
//  TongueClickBrowserViewController.h
//  tongueClickBrowser
//
//  Created by Sam Brodkin on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//audio (used example from http://mobileorchard.com/tutorial-detecting-when-a-user-blows-into-the-mic/ )
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface TongueClickBrowserViewController : UIViewController {

	UIImageView *imageView;
	UILabel *label;
	
	AVAudioRecorder *recorder;
	NSTimer *levelTimer;
	NSTimer *registerSingleClickTimer;
	double lowPassResults;
	NSDate *lastTongueClickTime;
	NSArray *urlArray;
	int currentImageNumber;
	NSError * error;
	
	UIImagePickerController		* picker;	



}

- (void)levelTimerCallback:(NSTimer *)timer;
- (void)registerSingleClickTimerCallback:(NSTimer *)timer;

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) NSDate *lastTongueClickTime;
@property (retain) NSArray *urlArray;
@property (nonatomic, retain)	UIImagePickerController * picker;
@property (nonatomic, retain)	IBOutlet UIImageView		* snapshotImage;


@end

