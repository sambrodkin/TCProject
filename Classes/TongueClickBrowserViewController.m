//
//  TongueClickBrowserViewController.m
//  tongueClickBrowser
//
//  Created by Sam Brodkin on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TongueClickBrowserViewController.h"

@implementation TongueClickBrowserViewController
@synthesize imageView, label, lastTongueClickTime, urlArray;
@synthesize picker;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	urlArray = [[NSArray arrayWithObjects: 
	 @"http://www.bennadel.com/resources/uploads/open_tits_close_tits.jpg",
	 @"http://files.shroomery.org/files/08-34/947949808-pure_dee_big_tits.jpg",
	 @"http://uvtblog.com/wp-content/uploads/2008/10/traci_bingham_trash1.jpg",
	 @"http://www.dreboy.com/bodyboarding/wp-content/uploads/2010/02/tits.jpg",
	 @"http://www.dreboy.com/bodyboarding/wp-content/uploads/2010/02/6a00e550039a838833011571898062970b-800wi.jpg",
	 nil]retain];
	
//	[self showImage:0];
//    [self startCamera];

	lastTongueClickTime = nil;
	[self measureAudioInput];
}

-(void) showImage:(int)imageNumber {
	if (imageNumber > ((sizeof urlArray))) {
		imageNumber = 0;
	}
	if (imageNumber < 0) {
		imageNumber = (sizeof urlArray);
	}
		
	NSLog(@"Showing image number: %d", imageNumber);
	NSLog(@"Showing image at url: %@", [urlArray objectAtIndex:imageNumber]); 
//	NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlArray objectAtIndex:imageNumber]]];
	NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[urlArray objectAtIndex:imageNumber]]];
	UIImage *myImage = [[UIImage alloc] initWithData:imageData]; 
	[imageView setImage:myImage];
	[imageData release];
	[myImage release];
	currentImageNumber = imageNumber;
}

- (void) measureAudioInput {

	NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
	
  	NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
							  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
							  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
							  [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
							  nil];
	
  	NSError *error;
	
  	recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	
  	if (recorder) {
  		[recorder prepareToRecord];
  		recorder.meteringEnabled = YES;
  		[recorder record];
		levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.9 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
  	} else
  		NSLog([error description]);
	
	
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
	NSLog(@"Average input: %f Peak input: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0]);
	
	const double ALPHA = 0.05;
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	
	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;	
	NSLog(@"peakPowerForChannel: %f Lowpass results: %f" , peakPowerForChannel, lowPassResults);
	
	//decide if it's click or double click
	if (peakPowerForChannel > 0.11) {
		NSDate *currentTongueClickTime = [[NSDate alloc] init];
		if (lastTongueClickTime != nil) {
			double timeIntervalBetweenClicks = [currentTongueClickTime timeIntervalSinceDate:lastTongueClickTime];
//			NSLog(@"time now = %@, time saved = %@, time diff = %@", currentTongueClickTime, lastTongueClickTime, [NSString stringWithFormat:@"%g",timeIntervalBetweenClicks]);
			if (timeIntervalBetweenClicks < 1.0) {
				NSLog(@"Tongue DOUBLE Click!!!");
				[label setText:@"Double Click"];
				[self showImage:(currentImageNumber -1)];
				lastTongueClickTime = NULL;
				[registerSingleClickTimer invalidate];
				return;
			}
		}
//		NSLog(@"Maybe Tongue Click!");
		lastTongueClickTime = currentTongueClickTime;
		registerSingleClickTimer = [NSTimer scheduledTimerWithTimeInterval: 0.9 target: self selector: @selector(registerSingleClickTimerCallback:) userInfo: nil repeats: NO];
		[self.picker takePicture];
		[label setText:@"Single Click"];
		NSLog(@"Single Tongue Click!");
	}
	

}

- (void)registerSingleClickTimerCallback:(NSTimer *)timer {
	[self showImage:(currentImageNumber +1)];
	[self.picker takePicture];
	[label setText:@"Single Click"];
	NSLog(@"Single Tongue Click!");
}


-(void)startCamera {
	// Call the image picker:
	self.picker = [[UIImagePickerController alloc] init];
	self.picker.delegate = self;
    //Hi
	// Set the image picker source to the camera:
	self.picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	self.picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	// Hide the camera controls:
	self.picker.showsCameraControls = NO;
	self.picker.navigationBarHidden = YES;
	[self presentModalViewController:self.picker animated:NO];

}


//after camera takes picture replace snapshotImage with picture from camera
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	imageView.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"]; //replace snaphotImage with camera image

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	UIAlertView *alert;
	
	// Unable to save the image  
	if (error)
		alert = [[UIAlertView alloc] initWithTitle:@"Error" 
										   message:@"Unable to save image to Photo Album." 
										  delegate:self cancelButtonTitle:@"Ok" 
								 otherButtonTitles:nil];
	else // All is well
		alert = [[UIAlertView alloc] initWithTitle:@"Success" 
										   message:@"Image saved to Photo Album." 
										  delegate:self cancelButtonTitle:@"Ok" 
								 otherButtonTitles:nil];
	[alert show];
	[alert release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[levelTimer release];
	[recorder release];
	[lastTongueClickTime release];
    [super dealloc];
}

@end
