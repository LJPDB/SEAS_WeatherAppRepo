//
//  MainViewController.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/20/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationWeatherObjetc.h"
#import "PageContentViewController.h"
#import "UserActualLocation.h"
#import "SettingsViewController.h"
#import "AddLocationViewController.h"
#import "PresentationViewController.h"
#import "InternetWeatherSource.h"
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController <UIPageViewControllerDataSource,addLocationViewControllerDelegate,locationDidChangeDelegate,JSONreceivedDelegate, changeInPreferencesDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addLocationButton;

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray *listaLocalidades;
@property (strong, nonatomic) NSMutableArray *pageTitles;

@property (nonatomic, retain, strong) UserActualLocation *objetoUbicacion;
@property (nonatomic, strong, retain) InternetWeatherSource *weatherWebsiteObject;

@end
