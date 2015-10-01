//
//  PresentationViewControllerPhone.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/28/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "PresentationViewController.h"

@interface PresentationViewController ()
@property (weak, nonatomic) IBOutlet UIButton *presentationBeginButton;
@property (weak, nonatomic) AppDelegate *appDelegate;
@end

@implementation PresentationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NetworkStatus networkConn = [_appDelegate.testConnectionObject currentReachabilityStatus];
    
    [self.testLabelLocalized setText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"climate panorama", nil)]];
    // Do any additional setup after loading the view.
    [self.presentationBeginButton setTitle:[NSString stringWithFormat:@"%@", NSLocalizedString(@"presentation BEGIN button", @"just to pass to main viewcontroller")] forState:UIControlStateNormal];
    
    if (networkConn != NotReachable) {  //networkStatus
        self.presentationBeginButton.enabled = YES;
    } else {
        self.presentationBeginButton.enabled = NO;
        [self imprimirAlertaSimpleConMensaje:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no internet conn content", nil)] conTitulo:[NSString stringWithFormat:@"%@", NSLocalizedString(@"no internet conn title", nil)]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma Mark - Funciones para generalizar la impresion de alertas en los dispositivos

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
