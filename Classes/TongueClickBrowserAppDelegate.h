//
//  TongueClickBrowserAppDelegate.h
//  tongueClickBrowser
//
//  Created by Sam Brodkin on 12/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TongueClickBrowserViewController;

@interface TongueClickBrowserAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TongueClickBrowserViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TongueClickBrowserViewController *viewController;

@end

