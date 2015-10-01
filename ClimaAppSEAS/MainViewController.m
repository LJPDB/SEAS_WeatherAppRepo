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

@property (nonatomic, retain) NSString *UCIdentifier;

@property (nonatomic) int testNumber;

@end


@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _weatherWebsiteObject = [[InternetWeatherSource alloc] init];
    [_weatherWebsiteObject inicializarValoresAPIKeyResultado];
    _weatherWebsiteObject.JSONchangedDelegate = self;
    
    //[_weatherWebsiteObject obtenerDatosPorNombre:@"Venezuela" conUnidadMedida:@"metric" enIdioma:@"es"];
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
#warning [self mostrarValoresEnUI]; aqui debe llamarse a la funcion que pinte toooooodo lo que se trajo del icloud o los valores por defecto siempre tomando como unico punto de referencia, lo que este en el userDefaults
        
        _objetoUbicacion = [[UserActualLocation alloc] init];
        _objetoUbicacion.locationChangedDelegate = self;
        
        if (_objetoUbicacion.requestForLocatePermission) {
            [_objetoUbicacion ubicacionActual];
        } else {
            NSMutableArray *listaIDLocalidadesAlmacenadas = [self obtenerListaLocalidades];
            if (![listaIDLocalidadesAlmacenadas[0]isEqualToString:@"empty"]) {
                _pageTitles = [[NSMutableArray alloc] initWithArray:listaIDLocalidadesAlmacenadas];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_weatherWebsiteObject obtenerCiduadesPaisesPorListaIDs:[listaIDLocalidadesAlmacenadas componentsJoinedByString:@","] conUnidadMedida:[self obtenerMedicionPref] enIdioma:[self obtenerIdioma]];
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
#warning pintar las localidades
            _pageTitles = [[NSMutableArray alloc] initWithArray:listaLocalidadesAlmacenadas];
        }
        [self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no internet conn content", nil)] conTitulo:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no internet conn title", nil)]];
    }
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = NSLocalizedString(@"weather main title", nil);
    //_testNumber++;
    //NSLog(@"test number in viewWillAppear: %i", _testNumber);
    
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    //[_objetoUbicacion ubicacionActual];
    //UserActualLocation *locationObj = [[UserActualLocation alloc] init];
   /* if (![self.objetoUbicacion revisarPermisosLocalizacion]) {
        //[locationObj ubicacionActual];
        [self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no location permission content", nil)] conTitulo:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no location permission title", nil)]];
    }*/
    //[self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%lu",(unsigned long)[self.pageTitles count]] conTitulo:@"numero de paginas"];
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
    //pageContentViewController.labelTestContentView.text = self.pageTitles[index];
    //[pageContentViewController.viewDidLoad]
    
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
    //pageContentViewController.temperatureMeasurement = [self obtenerMedicionPref];
    pageContentViewController.humidity = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"humidity", nil), humidity]];
    pageContentViewController.preassure = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"preassure", nil), preassure]];
    pageContentViewController.weather = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"weather", nil), weather]];
    pageContentViewController.latitude = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"latitude", nil), latitude]];
    pageContentViewController.longitude = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"longitude", nil), longitude]];
    //NSLog(@"labels array: %@", self.pageTitles[index]);
    pageContentViewController.pageIndex = index;
    
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
#warning [self mostrarValoresEnUI]; luego de esto deben pintarse los cambios nuevamente!
        
       
       // [_weatherWebsiteObject obtenerCiduadesPaisesPorListaIDs:@"524901,703448,2643743" conUnidadMedida:@"metric" enIdioma:@"es"];
    });

}

-(void)otherLocationsJSONobjChanged:(id)JSONobj{
    NSLog(@"JSON Lista de CIUDADES: %@", JSONobj);
    _pageTitles = [[NSMutableArray alloc] initWithArray: [self obtenerListaLocalidadesNoInternet]];
    [self createPageviewerPerItem];
    #warning aqui debe actualizarse la pocision actual en el arreglo del Plist y luego en la variable de icloud para que se sincronice y luego se pinta pero eso es en el viewDidLoad y en cualquier otro que haga falta...
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
    
  /*  LocationWeatherObjetc *location1 = [[LocationWeatherObjetc alloc] init];
    [location1 setLocationName:@"Italy"];
    [location1 setLocationLatitude:@"323232323.32323"];
    [location1 setLocationLongitude:@"323232.43"];
    [location1 setPreasure:@"234.4"];
    [location1 setHumidity:@"10"];
    [location1 setSeaLevel:@"785"];
    
    LocationWeatherObjetc *location2 = [[LocationWeatherObjetc alloc] init];
    [location2 setLocationName:@"Spain"];
    [location2 setLocationLatitude:@"323232323.32323"];
    [location2 setLocationLongitude:@"323232.43"];
    [location2 setPreasure:@"234.4"];
    [location2 setHumidity:@"10"];
    [location2 setSeaLevel:@"785"];
    
    NSMutableArray *localidadesTest = [[NSMutableArray alloc] initWithObjects:location1,location2, nil];
    [preferencias setValue:localidadesTest forKey:@"localidades"];
    
    NSMutableArray *localidades = [[NSMutableArray alloc] initWithArray:[preferencias valueForKey:@"localidades"]];
    NSLog(@"preferencias localidades: %@", [preferencias valueForKey:@"localidades"]);
    LocationWeatherObjetc *aux = localidades[0];
    NSLog(@"localidades pos 0: %@", aux.locationName);  */
    
    return preferencias;
}

-(void)validarConfiguracionExistentEnICloud:(NSString *)UCIdentifier
                  setearObseverParaVariable:(NSUbiquitousKeyValueStore *)iCloudStore{
    // iCloud - configuracion de la cuenta/sincronizacion
    NSURL *iCloud = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:UCIdentifier];
    
#warning mientras pruebo voy a siempre eliminar la variable del icloud
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

@end
