//
//  LocationWeatherObjetc.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 9/6/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationWeatherObjetc : NSObject <NSCoding>

@property NSString *locationName;
@property NSString *locationParent;
@property NSString *locationID;
@property NSString *locationLatitude;
@property NSString *locationLongitude;
@property NSString *humidity;
@property NSString *preasure;
@property NSString *temperature;
@property NSString *weather;

/* - (id)initWithName:(NSString *)theName
        locationID:(NSString *)theID
          latitude:(NSString *)theLatitude
         longitude:(NSString *)theLongitude
          preasure:(NSString *)thePreasure
          humidity:(NSString *)theHumidity
       temperature:(NSString *)theTemp
    locationParent:(NSString *)theParent
           weather:(NSString *)theWeather; */

- (void) encodeWithCoder : (NSCoder *)encoder ;
- (id) initWithCoder : (NSCoder *)decoder;

+(void)saveCurrentLocationOnly: (LocationWeatherObjetc *)localPosition
                  enDirectorio: (NSString *) filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath;
+(void)saveLocationsList: (NSMutableArray *)locationsList
            enDirectorio: (NSString *) filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath;
+(void)saveNewLocation: (LocationWeatherObjetc *)newLocation
          enDirectorio: (NSString *) filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath;
+(void)deleteLocation: (NSString *)idLocation
         enDirectorio: (NSString *) filePath  tambienDirectorioPrefs:(NSString *) PlistPreferenciasPath;

+(void)deletePlisFileAtPath: (NSString *) filePath andAlsoPlistPreferences:(NSString *) PlistPreferences;
+(void)salvarAsyncPreferenciasICloud:(NSMutableDictionary *)preferences;

@end
