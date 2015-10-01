//
//  PageContentViewController.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/28/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *preassureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*self.labelTestContentView.text = self.testLabelContent;*/
    //self.view.backgroundColor = [UIColor  blueColor];  //aqui se cambia color de fondo del viewcontroller pero aun el control del paginado sigue de color blanco....
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
   // self.labelTestContentView.text = [NSString stringWithFormat:@"%ld", (long)self.testLabelContent];
    UIColor *topColor = [UIColor colorWithRed:(0/255.0) green:(100/255.0) blue:(216/255.0) alpha:1.0];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    self.locationNameLabel.text = [NSString stringWithFormat:@"%@", self.locationName];
    self.countryNameLabel.text = [NSString stringWithFormat:@"%@", self.countryName];
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@", self.temperature];
    self.humidityLabel.text = [NSString stringWithFormat:@"%@", self.humidity];
    self.preassureLabel.text = [NSString stringWithFormat:@"%@", self.preassure];
    self.weatherLabel.text = [NSString stringWithFormat:@"%@", self.weather];
    self.latitudeLabel.text = [NSString stringWithFormat:@"%@", self.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%@", self.longitude];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
