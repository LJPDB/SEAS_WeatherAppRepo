//
//  SettingsViewControllerPhone.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/29/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InternetWeatherSource.h"
#import "FavoriteTableViewController.h"
@class SettingsViewController;

@protocol changeInPreferencesDelegate <NSObject>
@required
-(void) tempUnitChanged:(BOOL)itChanged;
-(void) favoriteLocationsListChanged:(BOOL)listChanged;

@end
@interface SettingsViewController : UIViewController <FavoriteListChangedDelegate>

@property (nonatomic, weak) id<changeInPreferencesDelegate> settingsChangedDelegate;

@end
