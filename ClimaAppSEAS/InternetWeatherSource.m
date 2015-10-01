//
//  InternetWeatherSource.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 9/8/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "InternetWeatherSource.h"

@implementation InternetWeatherSource
-(void)inicializarValoresAPIKeyResultado{
        _APIkey = @"6eab3eefc68ec3b42f753e89f41eba42";
    NSURL *documentDir = [[NSFileManager defaultManager]
                          URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *plist = [documentDir URLByAppendingPathComponent:@"favoriteLocations.plist"];
        _directorioPlist = plist.path;
    
    NSURL *plist2 = [documentDir URLByAppendingPathComponent:@"preferences.plist"];
    _directorioPlist = plist.path;
    _directorioPlistPreferencias = plist2.path;
    
    //borrar el archivo por ahora mientras probamos!
    //[LocationWeatherObjetc deletePlisFileAtPath:_directorioPlist andAlsoPlistPreferences:_directorioPlistPreferencias];
   
        _resultado = nil;
}

+(NSString *)obtenerPreferencesPlistPath{
    NSURL *documentDir = [[NSFileManager defaultManager]
                          URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *plist2 = [documentDir URLByAppendingPathComponent:@"preferences.plist"];
    return plist2.path;
}

-(void)obtenerDatosPorNombre:(NSString *) nombreCiudadPais conUnidadMedida: (NSString *) metricsUnit enIdioma: (NSString *) language{
    _resultado = nil;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?q=%@&units=%@&lang=%@&APPID=%@", nombreCiudadPais, metricsUnit, language, _APIkey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             _resultado = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             NSLog(@"REST API > internetWeatherSource (obtenerDatos nombreCiudadPais): %@ \n\n", _resultado);
             
         }else{
             _resultado = nil;
         }
     }];
   // return _resultado;
}

-(void)obtenerDatosPorCodigo:(NSString *) codigoCiudadPais conUnidadMedida:(NSString *) metricsUnit enIdioma:(NSString *) language{
    _resultado = nil;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%@&units=%@&lang=%@&APPID=%@", codigoCiudadPais, metricsUnit, language, _APIkey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             id singleOne = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0
                                                              error:NULL];
             // __aux = _resultado;
             //NSLog(@"REST API > internetWeatherSource (obtenerDatos latitud<>Longitud): %@ \n\n", requestResultAux);
             //[self JSONobjReceived:requestResultAux];
             NSString *tempMeasureUnit = [[NSString alloc] init];
             if ([metricsUnit isEqualToString:@"metric"]) {
                 tempMeasureUnit = @"ºC";
             }else{tempMeasureUnit = @"ºF";}
             
             LocationWeatherObjetc *localidadAux = [[LocationWeatherObjetc alloc] init];
             id mainDetails = [singleOne valueForKey:@"main"];
             id sysDetails = [singleOne valueForKey:@"sys"];
             id weatherDetails = [singleOne valueForKey:@"weather"];
             id coordDetails = [singleOne valueForKey:@"coord"];
             
             [localidadAux setLocationName:[singleOne valueForKey:@"name"]];
             [localidadAux setLocationID:[singleOne valueForKey:@"id"]];
             [localidadAux setHumidity:[mainDetails valueForKey:@"humidity"]];
             [localidadAux setPreasure:[mainDetails valueForKey:@"pressure"]];
             [localidadAux setWeather:[weatherDetails[0] valueForKey:@"description"]];
             [localidadAux setLocationLatitude:[coordDetails valueForKey:@"lat"]];
             [localidadAux setLocationLongitude:[coordDetails valueForKey:@"lon"]];
             [localidadAux setTemperature:[NSString stringWithFormat:@"%@ %@",[mainDetails valueForKey:@"temp"], tempMeasureUnit]];
             [localidadAux setLocationParent:[sysDetails valueForKey:@"country"]];
             
             NSLog(@"InternetWeatherSource (obtener con ID): %@", localidadAux);
             
             [LocationWeatherObjetc saveNewLocation:localidadAux enDirectorio:_directorioPlist tambienDirectorioPrefs:(NSString *) _directorioPlistPreferencias];
             [self.JSONchangedDelegate currentPositionJSONobjChanged:singleOne];
             
             //return requestResultAux;

             
         }else{
             _resultado = nil;
            // return _resultado;
         }
     }];
    //NSLog(@"parada del debugger imprimiendo el _resultado: %@", _resultado);
    //return _resultado;
}

-(void)obtenerCiduadesPaisesPorListaIDs:(NSString *) listaIDs conUnidadMedida:(NSString *) metricsUnit enIdioma:(NSString *) language{
    //http://api.openweathermap.org/data/2.5/group?id=524901,703448,2643743&units=metric
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/group?id=%@&units=%@&lang=%@&APPID=%@", listaIDs, metricsUnit, language, _APIkey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             id resultado = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:NULL];
             NSLog(@"REST API > internetWeatherSource (obtenerCiudadesLista ListaIDs): %@ \n\n", resultado);
#warning aqui debo meter los valores o el valor en el userDefaults y luego en el mainviewcontroller refrescar el paginador y subir cambios al icloud
             //NSUserDefaults *appUserDefaults = [NSUserDefaults standardUserDefaults];
             
             NSMutableArray *arregloLocalidades = [[NSMutableArray alloc] init];
             
             NSString *tempMeasureUnit = [[NSString alloc] init];
             if ([metricsUnit isEqualToString:@"metric"]) {
                 tempMeasureUnit = @"ºC";
             }else{tempMeasureUnit = @"ºF";}
             NSMutableArray *listaCiudades = [resultado valueForKey:@"list"];
             NSMutableArray *listaIDLocalidades = [[NSMutableArray alloc] init];
             for (id singleOne in listaCiudades) {
                 LocationWeatherObjetc *localidadAux = [[LocationWeatherObjetc alloc] init];
                 id mainDetails = [singleOne valueForKey:@"main"];
                 id sysDetails = [singleOne valueForKey:@"sys"];
                 id weatherDetails = [singleOne valueForKey:@"weather"];
                 id coordDetails = [singleOne valueForKey:@"coord"];
                 
                 [localidadAux setLocationName:[singleOne valueForKey:@"name"]];
                 [localidadAux setLocationID:[singleOne valueForKey:@"id"]];
                 [listaIDLocalidades addObject:[singleOne valueForKey:@"id"]];
                 [localidadAux setHumidity:[mainDetails valueForKey:@"humidity"]];
                 [localidadAux setPreasure:[mainDetails valueForKey:@"pressure"]];
                 [localidadAux setWeather:[weatherDetails[0] valueForKey:@"description"]];
                 [localidadAux setLocationLatitude:[coordDetails valueForKey:@"lat"]];
                 [localidadAux setLocationLongitude:[coordDetails valueForKey:@"lon"]];
                 [localidadAux setTemperature:[NSString stringWithFormat:@"%@ %@",[mainDetails valueForKey:@"temp"], tempMeasureUnit]];
                 [localidadAux setLocationParent:[sysDetails valueForKey:@"country"]];
                 
                 [arregloLocalidades addObject:localidadAux];
             }
             [LocationWeatherObjetc saveLocationsList:arregloLocalidades enDirectorio:_directorioPlist tambienDirectorioPrefs:_directorioPlistPreferencias];
             //[appUserDefaults setValue:listaIDLocalidades forKey:@"localidades"];
             //NSLog(@"lista de ids de localidades: %@", listaIDLocalidades);
             [self.JSONchangedDelegate otherLocationsJSONobjChanged: resultado];
             
         }else{
             _resultado = nil;
         }
     }];
}

-(void)obtenerDatosLocalesConLatitude:(NSString *) latitud conLongitud: (NSString *) longitud conUnidadMedida:(NSString *)metricsUnit enIdioma:(NSString *) language{  //http://api.openweathermap.org/data/2.5/weather?lat=35&lon=139
    NSLog(@"location en ObtenerDatos con latitud->%@ y longitud->%@", latitud, longitud);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%@&lon=%@&units=%@&lang=%@&APPID=%@", latitud, longitud, metricsUnit, language, _APIkey]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
            id singleOne = [NSJSONSerialization JSONObjectWithData:data
                                                          options:0
                                                            error:NULL];
            // __aux = _resultado;
             //NSLog(@"REST API > internetWeatherSource (obtenerDatos latitud<>Longitud): %@ \n\n", requestResultAux);
             //[self JSONobjReceived:requestResultAux];
             NSString *tempMeasureUnit = [[NSString alloc] init];
             if ([metricsUnit isEqualToString:@"metric"]) {
                 tempMeasureUnit = @"ºC";
             }else{tempMeasureUnit = @"ºF";}
             
             LocationWeatherObjetc *localidadAux = [[LocationWeatherObjetc alloc] init];
             id mainDetails = [singleOne valueForKey:@"main"];
             id sysDetails = [singleOne valueForKey:@"sys"];
             id weatherDetails = [singleOne valueForKey:@"weather"];
             id coordDetails = [singleOne valueForKey:@"coord"];
             
             [localidadAux setLocationName:[singleOne valueForKey:@"name"]];
             [localidadAux setLocationID:[singleOne valueForKey:@"id"]];
             [localidadAux setHumidity:[mainDetails valueForKey:@"humidity"]];
             [localidadAux setPreasure:[mainDetails valueForKey:@"pressure"]];
             [localidadAux setWeather:[weatherDetails[0] valueForKey:@"description"]];
             [localidadAux setLocationLatitude:[coordDetails valueForKey:@"lat"]];
             [localidadAux setLocationLongitude:[coordDetails valueForKey:@"lon"]];
             [localidadAux setTemperature:[NSString stringWithFormat:@"%@ %@",[mainDetails valueForKey:@"temp"], tempMeasureUnit]];
             [localidadAux setLocationParent:[sysDetails valueForKey:@"country"]];
             
             [LocationWeatherObjetc saveCurrentLocationOnly:localidadAux enDirectorio:_directorioPlist tambienDirectorioPrefs:(NSString *) _directorioPlistPreferencias];
             [self.JSONchangedDelegate currentPositionJSONobjChanged:singleOne];
             
             //return requestResultAux;
             
         }else{
            // [self setResultado:nil]; _resultado = nil;
             //return requestResultAux;
         }
     }];
}

-(BOOL)cargaMasivaCiudadesPaises{
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"JSON_locationsResourceDocs/city.list" ofType:@"json"];  //JSON_locationsResourceDocs/city.list
    
    //création d'un string avec le contenu du JSON
    NSError *error1 = nil;
    NSData *JSONdata = [NSData dataWithContentsOfFile:filePath options:NSUTF8StringEncoding error:&error1];
    
    //Parsage du JSON à l'aide du framework importé
    NSError *error = nil;
    NSArray *JSONobj    = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableContainers error:&error];
    
    if (JSONdata) {
        if (JSONobj) {
            //NSString *className = NSStringFromClass([JSONobj class]);
            //NSLog(@"else del tipo de clase del JSONobj...: %@", className);
            [self setListadoCiudadesPaises:[[NSMutableArray alloc] initWithArray:JSONobj]];
            //_listadoCiudadesPaises = [[NSMutableArray alloc] initWithArray:JSONobj];
            //NSLog(@"REST API > internetWeatherSource (cargaMasivaCiudadesPaises): %@ \n\n", _listadoCiudadesPaises[1]);
            return YES;
        } else {
            NSLog(@"REST API > internetWeatherSource (error en cargado de listado por JSON mal formado): ERROR-> %@ \n\n", error);
            return NO;
        }
    } else {
        NSLog(@"REST API > internetWeatherSource (error en cargado de listado) \n\n");
        return NO;
    }
        
   // });

}

-(NSMutableArray *)obtenerListadoCiudadesPaises{
    return _listadoCiudadesPaises;
}


@end
