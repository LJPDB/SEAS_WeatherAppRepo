//
//  InternetWeatherSource.h
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 9/8/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationWeatherObjetc.h"
@class InternetWeatherSource;

@protocol JSONreceivedDelegate <NSObject>

-(void)currentPositionJSONobjChanged:(id)JSONobj;
-(void)otherLocationsJSONobjChanged:(id)JSONobj;

@end

@interface InternetWeatherSource : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong, retain) NSMutableArray *listadoCiudadesPaises;
@property (nonatomic, strong, retain) id resultado;
@property (nonatomic, retain) NSString *APIkey;
@property (nonatomic, retain) NSString *directorioPlist;
@property (nonatomic, retain) NSString *directorioPlistPreferencias;

@property (nonatomic, weak) id<JSONreceivedDelegate> JSONchangedDelegate;

-(void)inicializarValoresAPIKeyResultado;

-(void)obtenerDatosPorNombre:(NSString *) nombreCiudadPais conUnidadMedida: (NSString *) metricsUnit enIdioma: (NSString *) language;

-(void)obtenerDatosPorCodigo:(NSString *) codigoCiudadPais conUnidadMedida:(NSString *) metricsUnit enIdioma:(NSString *) language;

-(void)obtenerCiduadesPaisesPorListaIDs:(NSString *) listaIDs conUnidadMedida:(NSString *) metricsUnit enIdioma:(NSString *) language;

-(void)obtenerDatosLocalesConLatitude:(NSString *) latitud conLongitud: (NSString *) longitud conUnidadMedida:(NSString *)metricsUnit enIdioma:(NSString *) language;


-(NSMutableArray *)obtenerListadoCiudadesPaises;

+(NSString *)obtenerPreferencesPlistPath;

-(BOOL)cargaMasivaCiudadesPaises;

@end
