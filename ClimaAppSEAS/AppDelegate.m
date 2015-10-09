//
//  AppDelegate.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/11/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "AppDelegate.h"
#import "InternetWeatherSource.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Customizar la barra de navegacion de la app
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],UITextAttributeTextColor,
                                               [UIColor blackColor], UITextAttributeTextShadowColor,
                                               [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes]; 
    //[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    _testConnectionObject = [Reachability reachabilityForInternetConnection];
    
    //Customizar el control de paginacion de las pantallas de clima.
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor  colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    [pageControl setOpaque:NO];   
    //*****************************************//
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self guardarDatosICloud];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self guardarDatosICloud];
}

-(void)guardarDatosICloud{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[InternetWeatherSource obtenerPreferencesPlistPath]]) {
        NSMutableDictionary *preferenciasAUX = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[InternetWeatherSource obtenerPreferencesPlistPath]]];
        [[NSUbiquitousKeyValueStore defaultStore] setObject:preferenciasAUX forKey:@"preferencias"];
        [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    }
    
}

@end
