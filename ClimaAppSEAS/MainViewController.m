//
//  MainViewController.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/20/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) NSUbiquitousKeyValueStore *iCloudStore;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicadorCarga;
@property (strong, nonatomic) IBOutlet UIView *contenedorViewPrincipal;
@property NSTimer *temporizador;
@property (nonatomic, retain) NSString *UCIdentifier;

@property (nonatomic) int testNumber;

@property (nonatomic, retain) NSString *dateUpdated;

@end


@implementation MainViewController

- (void)viewDidLoad {
    self.indicadorCarga.hidesWhenStopped = YES;
    [super viewDidLoad];
    _dateUpdated = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"never", nil)];
    _weatherWebsiteObject = [[InternetWeatherSource alloc] init];
    [_weatherWebsiteObject inicializarValoresAPIKeyResultado];
    _weatherWebsiteObject.JSONchangedDelegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL fillCitiesCountries = [_weatherWebsiteObject cargaMasivaCiudadesPaises];
        if (fillCitiesCountries) {
            NSLog(@"Countries/Cities load successfull!");
        } else {
            [self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no massive data loaded content", nil)] conTitulo:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no massive data loaded title", nil)]];
        }
    });
    
    _UCIdentifier = @"iCloud.com.ljpdb.ClimaAppSEAS";
    [self validarConfiguracionExistentEnICloud:_UCIdentifier setearObseverParaVariable:_iCloudStore];
    
    AppDelegate *appDelegateAUX =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NetworkStatus networkConn = [appDelegateAUX.testConnectionObject currentReachabilityStatus];
    
    if (networkConn != NotReachable) {  //networkStatus
        _objetoUbicacion = [[UserActualLocation alloc] init];
        _objetoUbicacion.locationChangedDelegate = self;
        
        if (_objetoUbicacion.requestForLocatePermission) {
            [_objetoUbicacion ubicacionActual];
        } else {
            NSMutableArray *listaIDLocalidadesAlmacenadas = [self obtenerListaLocalidades];
            if (![listaIDLocalidadesAlmacenadas[0]isEqualToString:@"empty"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_weatherWebsiteObject obtenerCiduadesPaisesPorListaIDs:[listaIDLocalidadesAlmacenadas componentsJoinedByString:@","] conUnidadMedida:[self obtenerMedicionPref] enIdioma:[self obtenerIdioma]];
                    _pageTitles = [[NSMutableArray alloc] initWithArray: [self obtenerListaLocalidadesNoInternet]];
                    [self createPageviewerPerItem];
                    _dateUpdated = [[NSString alloc] initWithFormat:@"%@", [self obtenerFechaActual]];
                    [self.indicadorCarga stopAnimating];
                    [self.indicadorCarga removeFromSuperview];
                });
            } else {
                // que hacer cuando no hay nada....
            }
            
            [self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no location permission content", nil)] conTitulo:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no location permission title", nil)]];
            // agregar un label dinamicamente al view y poner que no se tienen permisos para ubiccion del usuario
        }

    } else {
        NSMutableArray *listaLocalidadesAlmacenadas = [self obtenerListaLocalidadesNoInternet];
        if (listaLocalidadesAlmacenadas.count>0) {
            _pageTitles = [[NSMutableArray alloc] initWithArray:listaLocalidadesAlmacenadas];
            [self createPageviewerPerItem];
        }
        [self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no internet conn content", nil)] conTitulo:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no internet conn title", nil)]];
    }
    
    [self.contenedorViewPrincipal addSubview:self.indicadorCarga];
    self.temporizador = [NSTimer scheduledTimerWithTimeInterval:(1.0/2.0) target:self selector:@selector(cargandoMain) userInfo:nil repeats:YES];
    
}

-(void)cargandoMain{
    if (! self.contenedorViewPrincipal) {
        [self.indicadorCarga stopAnimating];
    } else {
        [self.indicadorCarga startAnimating];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = NSLocalizedString(@"weather main title", nil);
    //_testNumber++;
    //NSLog(@"test number in viewWillAppear: %i", _testNumber);
    [super viewWillAppear:animated];
}


-(void)viewDidAppear:(BOOL)animated{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"addLocationSegue"]) {
        AddLocationViewController *nextController = segue.destinationViewController;
        nextController.delegate = self;
        [nextController setListadoCiudadesPaises:[_weatherWebsiteObject obtenerListadoCiudadesPaises]];
        NSLog(@"Segue number of elements: %lu", (unsigned long)_weatherWebsiteObject.listadoCiudadesPaises.count);
    }else{
        SettingsViewController *nextController = segue.destinationViewController;
        nextController.dateFromMain = _dateUpdated;
        nextController.settingsChangedDelegate = self;
        
    }
}

#pragma mark - Page View Controller Data Source
-(void)createPageviewerPerItem{
    // Create page view controller
    if(![self pageViewController]){
        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil]; 
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageViewController.dataSource = self;
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 5);

    }
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    // Do any additional setup after loading the view.
    /*********************************************/
} 



- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (((unsigned long)[self.pageTitles count] == 0) || (index >= (unsigned long)[self.pageTitles count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    
    NSString *locName = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"locationName"]];
    NSString *locParent = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"locationParent"]];
    NSString *locTemp = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"temperature"]];
    NSString *humidity = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"humidity"]];
    NSString *preassure = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"preasure"]];
    NSString *weather = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"weather"]];
    NSString *latitude = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"locationLatitude"]];
    NSString *longitude = [NSString stringWithFormat:@"%@", [self.pageTitles[index] valueForKey:@"locationLongitude"]];

    NSLog(@"impresion del carton: %@", locTemp);
    
    pageContentViewController.locationName = [NSString stringWithFormat:@"%@", locName];
    pageContentViewController.countryName = [NSString stringWithFormat:@"%@", locParent];
    pageContentViewController.temperature = [NSString stringWithFormat:@"%@", locTemp];
    pageContentViewController.humidity = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"humidity", nil), humidity]];
    pageContentViewController.preassure = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"preassure", nil), preassure]];
    pageContentViewController.weather = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"weather", nil), weather]];
    pageContentViewController.latitude = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"latitude", nil), latitude]];
    pageContentViewController.longitude = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"longitude", nil), longitude]];
    //NSLog(@"labels array: %@", self.pageTitles[index]);
    pageContentViewController.pageIndex = index;
    [self.indicadorCarga stopAnimating];
    return pageContentViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == (unsigned long)[self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return (unsigned long)[self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - Cambios en las preferencias delegate
-(void)tempUnitChanged:(BOOL)itChanged{
    if (itChanged) {
        //refrescar datos en el servidor!!
        NSLog(@"Cambio la preferencia de unidad de medicion y es: %@", [self obtenerMedicionPref]);
        dispatch_async(dispatch_get_main_queue(), ^{            
            [_weatherWebsiteObject obtenerCiduadesPaisesPorListaIDs:[[self obtenerListaLocalidades] componentsJoinedByString:@","] conUnidadMedida:[self obtenerMedicionPref] enIdioma:[self obtenerIdioma]];
            _pageTitles = [[NSMutableArray alloc] initWithArray: [self obtenerListaLocalidadesNoInternet]];
            _dateUpdated = [[NSString alloc] initWithFormat:@"%@", [self obtenerFechaActual]];
            [self.indicadorCarga stopAnimating];
            [self.indicadorCarga removeFromSuperview];

            [self createPageviewerPerItem];
        });
    }
}
-(void)favoriteLocationsListChanged:(BOOL)listChanged{
    if (listChanged) {
        //refrescar datos en el servidor!!
        NSLog(@"Cambio la preferencia de lista de ciudades..!!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [_weatherWebsiteObject obtenerCiduadesPaisesPorListaIDs:[[self obtenerListaLocalidades] componentsJoinedByString:@","] conUnidadMedida:[self obtenerMedicionPref] enIdioma:[self obtenerIdioma]];
            _pageTitles = [[NSMutableArray alloc] initWithArray: [self obtenerListaLocalidadesNoInternet]];
            _dateUpdated = [[NSString alloc] initWithFormat:@"%@", [self obtenerFechaActual]];
            [self.indicadorCarga stopAnimating];
            [self.indicadorCarga removeFromSuperview];

            [self createPageviewerPerItem];
        });
        
    }
}

#pragma mark - LocationChangedDelegate
-(void)locationDidChange:(CLLocation *)location{
    //NSLog(@"MainViewController Protocol (Location did change): %@", location);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_weatherWebsiteObject obtenerDatosLocalesConLatitude:[NSString stringWithFormat:@"%+.6f", location.coordinate.latitude] conLongitud:[NSString stringWithFormat:@"%+.6f", location.coordinate.longitude] conUnidadMedida:[self obtenerMedicionPref] enIdioma:[self obtenerIdioma]];
    });
}

#pragma mark - Obtener datos de la ubicacion local, de los cambios que se realicen en los settings y de las localidades agregadas a favoritos

-(void)currentPositionJSONobjChanged:(id)JSONobj{
    NSLog(@"JSON Cambio!!!... %@", JSONobj);
    NSMutableArray *listaIDLocalidadesAlmacenadas = [self obtenerListaLocalidades];
    NSLog(@"lista de IDs de localidades del viewdidload: --->  %@", listaIDLocalidadesAlmacenadas);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([listaIDLocalidadesAlmacenadas[0] isEqualToString:@"empty"]) {
            NSLog(@"entre al if de si es es empty!");
        }else{
            NSLog(@"entre en el ELSE del if del empty");
            [_weatherWebsiteObject obtenerCiduadesPaisesPorListaIDs:[listaIDLocalidadesAlmacenadas componentsJoinedByString:@","] conUnidadMedida:[self obtenerMedicionPref] enIdioma:[self obtenerIdioma]];
        }
    });

}

-(void)otherLocationsJSONobjChanged:(id)JSONobj{
    NSLog(@"JSON Lista de CIUDADES: %@", JSONobj);
    _pageTitles = [[NSMutableArray alloc] initWithArray: [self obtenerListaLocalidadesNoInternet]];
    _dateUpdated = [[NSString alloc] initWithFormat:@"%@", [self obtenerFechaActual]];
    [self.indicadorCarga stopAnimating];
    [self.indicadorCarga removeFromSuperview];

    [self createPageviewerPerItem];
}


#pragma mark - AddLocationDelegate

-(void)addedLocation:(NSString *)location{
    NSLog(@"AddLocationView Protocol (addedLocation): %@", location);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_weatherWebsiteObject obtenerDatosPorCodigo:location conUnidadMedida:[self obtenerMedicionPref] enIdioma:[self obtenerIdioma]];
    });
}

#pragma mark - Funcion para el cambio de la variable iCloud y seteos de preferencias en/de icloud

-(void) iCloudVariableHaCambiado: (NSNotification *) notification{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Change detected"
                          message:@"iCloud key-value store change detected"
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil];
    [alert show];
}

-(NSString *)obtenerMedicionPref{
    NSMutableDictionary *preferenciasAlmacenadasSistema = [NSKeyedUnarchiver unarchiveObjectWithFile:[_weatherWebsiteObject directorioPlistPreferencias]];
    return [preferenciasAlmacenadasSistema valueForKey:@"medicion"];
}

-(NSString *)obtenerIdioma{
    return [NSString stringWithFormat:@"%@", NSLocalizedString(@"language", @"returns actual language used")];
}

-(NSMutableArray *)obtenerListaLocalidadesNoInternet{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[_weatherWebsiteObject directorioPlist]];
}
-(NSMutableArray *)obtenerListaLocalidades{
    NSMutableDictionary *preferenciasAlmacenadasSistema = [NSKeyedUnarchiver unarchiveObjectWithFile:[_weatherWebsiteObject directorioPlistPreferencias]];
    NSMutableArray *localidades = [[NSMutableArray alloc] initWithArray:[[preferenciasAlmacenadasSistema valueForKey:@"localidades"] componentsSeparatedByString:@","]];
    
    return localidades;
}


-(id)obtenerPreferenciasDefault{
    NSArray *llaves = @[@"medicion", @"localidades"];
    NSArray *valores = @[@"metric", @"empty"];
    NSMutableDictionary *preferencias = [[NSMutableDictionary alloc] initWithObjects:valores forKeys:llaves];
    
    return preferencias;
}

-(void)validarConfiguracionExistentEnICloud:(NSString *)UCIdentifier
                  setearObseverParaVariable:(NSUbiquitousKeyValueStore *)iCloudStore{
    // iCloud - configuracion de la cuenta/sincronizacion
    NSURL *iCloud = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UCIdentifier];
    //[[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:@"preferencias"];
    
    ///************************///
    
    
    id variablePreferenciasAuxiliar = [self obtenerPreferenciasDefault];
    NSLog(@"icloud: %@",iCloud);
    if (iCloud) {        
        NSLog(@"variable icloud existe");
        if([[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"preferencias"]){
            NSLog(@"existe en icloud");
            variablePreferenciasAuxiliar = [[NSUbiquitousKeyValueStore defaultStore] objectForKey:@"preferencias"];
            [NSKeyedArchiver archiveRootObject:variablePreferenciasAuxiliar toFile:[_weatherWebsiteObject directorioPlistPreferencias]];
            NSMutableArray *auxLocationsList = [NSKeyedUnarchiver unarchiveObjectWithFile:[_weatherWebsiteObject directorioPlist]];
            if (auxLocationsList) {
                int i = 0;
                BOOL exist = NO;
                NSMutableArray *arregloIDsDeICloud = [[NSMutableArray alloc] initWithArray:[[variablePreferenciasAuxiliar valueForKey:@"localidades"] componentsSeparatedByString:@","]];
                [arregloIDsDeICloud removeObjectAtIndex:0];
                NSMutableArray *auxLocationsListCOPY = [[NSMutableArray alloc] initWithArray:auxLocationsList];
                for (LocationWeatherObjetc *aux in auxLocationsList) {
                    if (i==0) {
                        i++;
                    } else {
                        NSString *stringIDFromFile = [NSString stringWithFormat:@"%@", [aux locationID]];
                        for (NSString *IDdeICloud in arregloIDsDeICloud) {
                            if (stringIDFromFile==IDdeICloud) {
                                exist = YES;
                            }
                        }
                        if(!exist){
                            [auxLocationsListCOPY removeObjectAtIndex:i];
                        }
                        exist = NO;
                        i++;
                    }
                }
                [NSKeyedArchiver archiveRootObject:auxLocationsListCOPY toFile:[_weatherWebsiteObject directorioPlist]];
            }
        }else{
            NSLog(@"no existe en icloud");
            if([[NSFileManager defaultManager] fileExistsAtPath:[_weatherWebsiteObject directorioPlistPreferencias]]){
                NSMutableDictionary *preferenciasAlmacenadasSistema = [NSKeyedUnarchiver unarchiveObjectWithFile:[_weatherWebsiteObject directorioPlistPreferencias]];
                [[NSUbiquitousKeyValueStore defaultStore] setObject:preferenciasAlmacenadasSistema forKey:@"preferencias"];
            }else{
                [NSKeyedArchiver archiveRootObject:variablePreferenciasAuxiliar toFile:[_weatherWebsiteObject directorioPlistPreferencias]];
                [[NSUbiquitousKeyValueStore defaultStore] setObject:variablePreferenciasAuxiliar forKey:@"preferencias"];
            }
            [[NSUbiquitousKeyValueStore defaultStore] synchronize];
        }
    } else {
        [self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no icloud alert title", nil)] conTitulo:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no icloud alert content", nil)]];
        if(![[NSFileManager defaultManager] fileExistsAtPath:[_weatherWebsiteObject directorioPlistPreferencias]]){
            [NSKeyedArchiver archiveRootObject:variablePreferenciasAuxiliar toFile:[_weatherWebsiteObject directorioPlistPreferencias]];
        }
    }
    
    NSLog(@"archivo de preferencias: %@", variablePreferenciasAuxiliar);
    
    //********************fin del seteo en el UserDefaults******************************//
    
    // register to observe notifications from the store
    [[NSNotificationCenter defaultCenter]
     addObserver: self
     selector: @selector (iCloudVariableHaCambiado:)
     name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification
     object: self.iCloudStore];
    
    // get changes that might have happened while this
    // instance of your app wasn't running
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    //*****************************************//

}

#pragma mark - Funciones para generalizar la impresion de alertas en los dispositivos

-(void)imprimirAlertaSimpleConMensaje:(NSString *)mensaje conTitulo:(NSString *)titulo{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:titulo
                          message:mensaje
                          delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil];
    [alert show];

}

-(NSString *)obtenerFechaActual{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm:ss"];
    NSString *dateString = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", dateString);
    return dateString;
}

@end
