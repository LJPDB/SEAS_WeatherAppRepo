//
//  AppDelegate.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/11/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserActualLocation.h"
#import "Reachability.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) Reachability *testConnectionObject;

@end

