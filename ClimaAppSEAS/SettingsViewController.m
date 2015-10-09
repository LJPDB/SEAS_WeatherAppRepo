//
//  SettingsViewControllerPhone.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/29/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "SettingsViewController.h"
#import "LocationWeatherObjetc.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *unidadMedicionTemperaturaLabel;
@property (weak, nonatomic) IBOutlet UILabel *ultimaVezActualizadoLabel;
@property (weak, nonatomic) IBOutlet UIButton *listaFavoritosButton;
@property (nonatomic) NSString *dateUpdated;

@property (weak, nonatomic) IBOutlet UISegmentedControl *CelsiusFahrenheitControl;


@end

@implementation SettingsViewController
- (IBAction)cambioMedidaTemperatura:(UISegmentedControl *)sender {    
    NSLog(@"SegmentedControl change to: %ld", (long)sender.selectedSegmentIndex);
    //[self.settingsChangedDelegate tempUnitChanged:YES];
}

- (void)viewDidLoad {
    self.dateUpdated = [[NSString alloc] initWithFormat:@"%@", self.dateFromMain];
    self.ultimaVezActualizadoLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"last time updated", nil), self.dateFromMain];
    self.unidadMedicionTemperaturaLabel.text = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"temperature unit preferences label", nil)];
    [self.listaFavoritosButton setTitle:NSLocalizedString(@"favorite locations list preference button", nil) forState:UIControlStateNormal];
    
    
    NSURL *documentDir = [[NSFileManager defaultManager]
                          URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *plist2 = [documentDir URLByAppendingPathComponent:@"preferences.plist"];
    NSString *directorioPlistPreferencias = plist2.path;
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:directorioPlistPreferencias]];
    NSString *tempUnitVal = [preferences valueForKey:@"medicion"];
    if ([tempUnitVal isEqualToString:@"metric"]) {
        _CelsiusFahrenheitControl.selectedSegmentIndex=0;
    }else{
        _CelsiusFahrenheitControl.selectedSegmentIndex=1;
    }
    [super viewDidLoad];
    //FavoriteTableViewController *auxObjectForDelegation = [[FavoriteTableViewController alloc] init];
    //auxObjectForDelegation.favListDelegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = NSLocalizedString(@"settings block", nil);
    self.navigationController.navigationBar.topItem.backBarButtonItem.title = NSLocalizedString(@"back navbar", nil);
    // then call the super
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSString *tempUnitSelected;
    if (_CelsiusFahrenheitControl.selectedSegmentIndex == 0) {
        tempUnitSelected=@"metric";
    } else {
        tempUnitSelected=@"imperial";
    }
    NSURL *documentDir = [[NSFileManager defaultManager]
                          URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *plist2 = [documentDir URLByAppendingPathComponent:@"preferences.plist"];
    NSString *directorioPlistPreferencias = plist2.path;
    NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:directorioPlistPreferencias]];
    if (![[preferences valueForKey:@"medicion"]isEqualToString:tempUnitSelected]) {
        [preferences setValue:tempUnitSelected forKey:@"medicion"];
        [NSKeyedArchiver archiveRootObject:preferences toFile:directorioPlistPreferencias];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [LocationWeatherObjetc salvarAsyncPreferenciasICloud:preferences];
            [self.settingsChangedDelegate tempUnitChanged:YES];
        });
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toFavoriteLocationsList"]) {
        FavoriteTableViewController *nextController = segue.destinationViewController;
        nextController.favListDelegate = self;
      //  [nextController setListadoCiudadesPaises:[_weatherWebsiteObject obtenerListadoCiudadesPaises]];
      //  NSLog(@"Segue number of elements: %lu", (unsigned long)_weatherWebsiteObject.listadoCiudadesPaises.count);
    }

}

#pragma mark - Funcion para el delegado de la eliminacion de una localidad en la lista de favoritos
-(void) locationWasEliminated:(BOOL)locationEliminated{
    NSLog(@"delegado activado por eliminacion...!!");
    [self.settingsChangedDelegate favoriteLocationsListChanged:YES];
}

@end
