//
//  LocationWeatherObjetc.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 9/6/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "LocationWeatherObjetc.h"

@implementation LocationWeatherObjetc

/*- (id)initWithName:(NSString *)theName
        locationID:(NSString *)theID
          latitude:(NSString *)theLatitude
         longitude:(NSString *)theLongitude
          preasure:(NSString *)thePreasure
          humidity:(NSString *)theHumidity
       temperature:(NSString *)theTemp
    locationParent:(NSString *)theParent
           weather:(NSString *)theWeather{
    self = [super init];
    
    if (self) {
        _locationName = theName;
        _locationID = theID;
        _locationLatitude = theLatitude;
        _locationLongitude = theLongitude;
        _preasure = thePreasure;
        _humidity = theHumidity;
        _temperature = theTemp;
        _locationParent = theParent;
        _weather = theWeather;
    }
    
    return self;
} */

- (void)encodeWithCoder:(NSCoder *)encoder;
{
    [encoder encodeObject:_locationName forKey:@"locationName"];
    [encoder encodeObject:_locationID forKey:@"locationID"];
    [encoder encodeObject:_locationLatitude forKey:@"locationLatitude"];
    [encoder encodeObject:_locationLongitude forKey:@"locationLongitude"];
    [encoder encodeObject:_preasure forKey:@"preasure"];
    [encoder encodeObject:_humidity forKey:@"humidity"];
    [encoder encodeObject:_temperature forKey:@"temperature"];
    [encoder encodeObject:_locationParent forKey:@"locationParent"];
    [encoder encodeObject:_weather forKey:@"weather"];
}

- (id)initWithCoder:(NSCoder *)decoder;
{
    self = [super init];
    if (self != nil)
    {
        _locationName = [decoder decodeObjectForKey:@"locationName"];
        
        _locationID = [decoder decodeObjectForKey:@"locationID"];
        _locationLatitude = [decoder decodeObjectForKey:@"locationLatitude"];
        _locationLongitude = [decoder decodeObjectForKey:@"locationLongitude"];
        _preasure = [decoder decodeObjectForKey:@"preasure"];
        _humidity = [decoder decodeObjectForKey:@"humidity"];
        _temperature = [decoder decodeObjectForKey:@"temperature"];
        _locationParent = [decoder decodeObjectForKey:@"locationParent"];
        _weather = [decoder decodeObjectForKey:@"weather"];
    }
    return self;
}

+(void)saveCurrentLocationOnly: (LocationWeatherObjetc *)localPosition
                  enDirectorio: (NSString *) filePath tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSMutableArray *auxLocationsList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            [auxLocationsList replaceObjectAtIndex:0 withObject:localPosition];
            [NSKeyedArchiver archiveRootObject:auxLocationsList toFile:filePath];
            NSLog(@"LocationWeatherObject saveCurrentLocation: auxLocationList IF --->  %@ \n", [auxLocationsList[0] valueForKey:@"locationName"]);
            //[LocationWeatherObjetc saveLocationsList:auxLocationsList enDirectorio:filePath];
        }else{
            NSMutableArray *locationsList = [[NSMutableArray alloc] initWithObjects:localPosition, nil];
            [NSKeyedArchiver archiveRootObject:locationsList toFile:filePath];
            NSLog(@"LocationWeatherObject saveCurrentLocation: auxLocationList ELSE --->  %@ \n", [locationsList[0] valueForKey:@"locationName"]);
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:PlistPreferenciasPath]) {
            NSMutableDictionary *preferenciasAUX = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:PlistPreferenciasPath]];
            NSString *localidadesString = [preferenciasAUX valueForKey:@"localidades"];
            NSMutableArray *localidades = [[NSMutableArray alloc] initWithArray:[localidadesString componentsSeparatedByString:@","]];
            NSLog(@"objeto prueba: %@", preferenciasAUX);
            [localidades replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%@", [localPosition valueForKey:@"locationID"]]];
            localidadesString = [NSString stringWithFormat:@"%@", [localidades componentsJoinedByString:@","]];
            
            [preferenciasAUX setObject:localidadesString forKey:@"localidades"];
            [NSKeyedArchiver archiveRootObject:preferenciasAUX toFile:PlistPreferenciasPath];
            //[LocationWeatherObjetc saveLocationsList:auxLocationsList enDirectorio:filePath];
        }else{
            NSMutableArray *locationsList = [[NSMutableArray alloc] initWithObjects:localPosition, nil];
            [NSKeyedArchiver archiveRootObject:locationsList toFile:PlistPreferenciasPath];
        }
        
    });
}

+(void)saveNewLocation: (LocationWeatherObjetc *)newLocation
                  enDirectorio: (NSString *) filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *auxLocationsList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        int i = 0;
        BOOL exist = NO;
        int atIndex = 0;
        for (LocationWeatherObjetc *aux in auxLocationsList) {
            if ([aux locationID]==[newLocation  locationID]) {
                exist = YES;
                atIndex = i;
            }
            i++;
        }
        if(exist){
            [auxLocationsList replaceObjectAtIndex:atIndex withObject:newLocation];
        }else{
            [auxLocationsList addObject:newLocation];
        }
        [NSKeyedArchiver archiveRootObject:auxLocationsList toFile:filePath];
        
        NSDictionary *preferenciasAUX = [NSKeyedUnarchiver unarchiveObjectWithFile:PlistPreferenciasPath];
        NSString *listaLocalidadesString = [preferenciasAUX valueForKey:@"localidades"];
        NSMutableArray *listaLocalidadesArray = [[NSMutableArray alloc] initWithArray:[listaLocalidadesString componentsSeparatedByString:@","]];
        i=0;
        exist = NO;
        for (NSString *aux in listaLocalidadesArray) {
            if ([aux isEqualToString:[newLocation locationID]]) {
                exist = YES;
                atIndex = i;
            }
            i++;
        }
        if (!exist) {
            [listaLocalidadesArray addObject:[NSString stringWithFormat:@"%@", [newLocation locationID]]];
        }
        listaLocalidadesString = [listaLocalidadesArray componentsJoinedByString:@","];
        [preferenciasAUX setValue:listaLocalidadesString forKey:@"localidades"];
        [NSKeyedArchiver archiveRootObject:preferenciasAUX toFile:PlistPreferenciasPath];
        
    });
}

+(void)deleteLocation: (NSString *)idLocation
          enDirectorio: (NSString *) filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath{
    NSMutableArray *auxLocationsList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    int i = 0;
    for (LocationWeatherObjetc *aux in auxLocationsList) {
        if ([[NSString stringWithFormat:@"%@", [aux locationID]]isEqualToString:idLocation]) {
            [auxLocationsList removeObjectAtIndex:i];
        }
        i++;
    }
    [LocationWeatherObjetc saveLocationsList:auxLocationsList enDirectorio:filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath];
}

+(void)saveLocationsList: (NSMutableArray *)locationsList
            enDirectorio: (NSString *) filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSMutableArray *auxLocationsList = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            NSMutableArray *auxLocationsListCopy = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            int i = 0, j = 0;
            BOOL exist = NO;
            int atIndex = 0;
            for (LocationWeatherObjetc *aux in locationsList) {
                for (LocationWeatherObjetc *auxItemFile in auxLocationsListCopy) {
                    if ([aux locationID]==[auxItemFile  locationID]) {
                        exist = YES;
                        atIndex = j;
                    }
                    j++;
                }
                if(exist){
                    [auxLocationsList replaceObjectAtIndex:atIndex withObject:aux];
                }else{
                    [auxLocationsList addObject:aux];
                }
                exist = NO;
                i++;
                j=0;
            }
            [NSKeyedArchiver archiveRootObject:auxLocationsList toFile:filePath];
            NSMutableArray *auxLocationsListOnlyIDs = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
            NSMutableArray *onlyIDs = [[NSMutableArray alloc] init];
            for (LocationWeatherObjetc *aux2 in auxLocationsListOnlyIDs){
                [onlyIDs addObject:[NSString stringWithFormat:@"%@",[aux2 locationID]]];
            }
            NSMutableDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:PlistPreferenciasPath];
            [prefs setObject:[onlyIDs componentsJoinedByString:@","] forKey:@"localidades"];
            [NSKeyedArchiver archiveRootObject:prefs toFile:PlistPreferenciasPath];
        } else {
            // solo sobreescribir
            [NSKeyedArchiver archiveRootObject:locationsList toFile:filePath];
            NSMutableArray *onlyIDs;
            for (LocationWeatherObjetc *aux2 in locationsList){
                [onlyIDs addObject:[NSString stringWithFormat:@"%@",[aux2 locationID]]];
            }
            NSMutableDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:PlistPreferenciasPath];
            [prefs setObject:[onlyIDs componentsJoinedByString:@","] forKey:@"localidades"];
            [NSKeyedArchiver archiveRootObject:prefs toFile:PlistPreferenciasPath];
        }
    });
}


+(void)deletePlisFileAtPath: (NSString *) filePath andAlsoPlistPreferences:(NSString *)PlistPreferences{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:PlistPreferences error:nil];
}

+(NSMutableArray *)obtenerListaLocalidadesAlmacenadasEnPath: (NSString *)filePath{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}





@end
