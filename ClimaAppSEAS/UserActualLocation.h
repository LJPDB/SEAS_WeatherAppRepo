//
//  UserActualLocation.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 9/8/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class UserActualLocation;

@protocol locationDidChangeDelegate <NSObject>

-(void) locationDidChange:(CLLocation *)location;

@end

@interface UserActualLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, weak) id<locationDidChangeDelegate> locationChangedDelegate;

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;
//- (CLLocation *)ubicacionActual;
-(void)ubicacionActual;
-(BOOL)requestForLocatePermission;


@end
