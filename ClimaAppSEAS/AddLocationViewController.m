//
//  AddLocationViewController.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/29/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "AddLocationViewController.h"

@interface AddLocationViewController ()
//@property (weak, nonatomic) IBOutlet UILabel *hiddenCellLabel;

@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"addLocation listado de paises: %lu", (unsigned long)_listadoCiudadesPaises.count);
    id aux = _listadoCiudadesPaises[0];

    NSLog(@"addLocation objeto paises: %@", [aux valueForKey:@"name"]);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = NSLocalizedString(@"add location", nil);
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

#pragma mark - Display and selection in tableView

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"citiesCountriesCell"];
    id aux = _listadoCiudadesPaises[indexPath.row];
    //NSLog(@"nombre desde la funcion de armado de la tabla: %@", [aux valueForKey:@"name"]);
    cell.textLabel.text = [aux valueForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"country subtitle tableview", nil),[aux valueForKey:@"country"]];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    [label setText:[NSString stringWithFormat:@"%@", [aux valueForKey:@"_id"]]];
   // [self.hiddenCellLabel setText:[NSString stringWithFormat:@"test %ld", (long)indexPath.row]];
    
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  //  NSString *cellTitle = selectedCell.textLabel.text;
  //  NSString *cellSubtitle = selectedCell.detailTextLabel.text;
    UILabel *taggedLabel =(UILabel*) [selectedCell.contentView viewWithTag:1];
    NSString *labelID = taggedLabel.text;
    
    //NSLog(@"row toucheada: \n Localidad -> %@ \n  Pais -> %@ \n ID -> %@", cellTitle, cellSubtitle, labelID);
   
    [self.delegate addedLocation:labelID];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _listadoCiudadesPaises.count;
}

@end
