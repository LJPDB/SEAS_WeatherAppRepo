//
//  SettingsViewControllerPhone.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/29/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *ultimaVezActualizadoLabel;
@property (nonatomic) NSString *dateUpdated;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    self.dateUpdated = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"never", nil)];
    self.ultimaVezActualizadoLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"last time updated", nil), self.dateUpdated];
    [super viewDidLoad];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
