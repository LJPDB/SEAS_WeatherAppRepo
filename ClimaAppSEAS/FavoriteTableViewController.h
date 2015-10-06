//
//  FavoriteTableViewController.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 10/1/15.
//  Copyright © 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationWeatherObjetc.h"
@class FavoriteTableViewController;

@protocol FavoriteListChangedDelegate <NSObject>
@required
-(void) locationWasEliminated:(BOOL)locationEliminated;
@end

@interface FavoriteTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<FavoriteListChangedDelegate> favListDelegate;


@end
