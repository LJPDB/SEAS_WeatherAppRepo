//
//  UserActualLocation.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 9/8/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "UserActualLocation.h"
@interface UserActualLocation()
    
@property (nonatomic, strong, retain) CLLocationManager *gestionadorUbicacion;

@end

@implementation UserActualLocation


-(BOOL)requestForLocatePermission{
    if([CLLocationManager locationServicesEnabled]){
        self.gestionadorUbicacion = [[CLLocationManager alloc] init];
        
        self.gestionadorUbicacion.delegate = self;
        
        // este valor nos dice que tan exacto queremos que sea la ubicacion
        self.gestionadorUbicacion.desiredAccuracy = 1500;
        
        // este valor, cada cuantos metros debe indicarnos posicion (metros referidos a nuestro movimiento), por razones de visualizar los cambios pondremos una configuracion que nos dara constantes actualizaciones con kCLDistanceFilterNone...
        //self.locationManager.distanceFilter = 200;
        self.gestionadorUbicacion.distanceFilter = 1500;
        //self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.gestionadorUbicacion.allowsBackgroundLocationUpdates = YES;
        
        // comienza el servicio...
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.gestionadorUbicacion respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.gestionadorUbicacion requestWhenInUseAuthorization];
                [self.gestionadorUbicacion requestAlwaysAuthorization];
                if ( ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusNotDetermined) && ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusRestricted) && ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusDenied) ) {
                    [self.gestionadorUbicacion startMonitoringSignificantLocationChanges];
                    [self ubicacionActual];
                }
            }
            if ([self.gestionadorUbicacion respondsToSelector:@selector(requestForLocatePermission)]) {
                [self.gestionadorUbicacion requestLocation];
                if ( ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusNotDetermined) && ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusRestricted) && ([CLLocationManager authorizationStatus]!=kCLAuthorizationStatusDenied) ) {
                    [self.gestionadorUbicacion startMonitoringSignificantLocationChanges];
                    [self ubicacionActual];
                }
            }
        });
        
        
        return TRUE;
    }else{
        return FALSE;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    //[self.locationChangedDelegate locationDidChange:location];
    if (fabs(howRecent) > -10.0) {
        // If the event is recent, do something with it.
        [self.locationChangedDelegate locationDidChange:location];
        //NSLog(@"UserActualLocation (locationManager didUpdateLocation): latitude %+.6f, longitude %+.6f\n\n\n",
        //      location.coordinate.latitude,
        //      location.coordinate.longitude);
    }
}

- (void)ubicacionActual {
    [self.locationChangedDelegate locationDidChange:self.gestionadorUbicacion.location];
    //return self.gestionadorUbicacion.location;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            [self.gestionadorUbicacion stopMonitoringSignificantLocationChanges];
            
        } break;
        case kCLAuthorizationStatusDenied: {
            [self.gestionadorUbicacion stopMonitoringSignificantLocationChanges];
            
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [self.gestionadorUbicacion stopMonitoringSignificantLocationChanges];
        } break;
        default:
            break;
    }
}

-(void)detenerMonitorLocalizacion{
    [self.gestionadorUbicacion stopMonitoringSignificantLocationChanges];
}

-(void)revisarPermisosLocalizacion{
    if([CLLocationManager locationServicesEnabled]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.gestionadorUbicacion respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.gestionadorUbicacion requestWhenInUseAuthorization];
            }
            if ([self.gestionadorUbicacion respondsToSelector:@selector(requestForLocatePermission)]) {
                [self.gestionadorUbicacion requestAlwaysAuthorization];
            }
        });
    }

}

+(void)stopLocationManagerMonitor{
    UserActualLocation *aux;
    [aux detenerMonitorLocalizacion];
}

@end
