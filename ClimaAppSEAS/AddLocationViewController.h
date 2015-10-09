//
//  AddLocationViewController.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/29/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddLocationViewController;

@protocol addLocationViewControllerDelegate <NSObject>

-(void) addedLocation:(NSString *)location;

@end

@interface AddLocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, weak) id<addLocationViewControllerDelegate> delegate;
@property (nonatomic) NSMutableArray *listadoCiudadesPaises;

@end
