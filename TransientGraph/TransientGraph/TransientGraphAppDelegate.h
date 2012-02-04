//
//  TransientGraphAppDelegate.h
//  TransientGraph
//
//  Created by Ivan Malagon on 1/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TransientGraphViewController;

@interface TransientGraphAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TransientGraphViewController *viewController;

@end
