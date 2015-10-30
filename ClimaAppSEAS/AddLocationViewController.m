//
//  AddLocationViewController.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 8/29/15.
//  Copyright (c) 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "AddLocationViewController.h"

@interface AddLocationViewController ()

@property (strong, nonatomic, retain) NSMutableArray *resultadoBusqueda;

@end

@implementation AddLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"addLocation listado de paises: %lu", (unsigned long)_listadoCiudadesPaises.count);
    id aux = _listadoCiudadesPaises;

    
    //NSLog(@"addLocation objeto paises: %@", [aux valueForKey:@"name"]);
    _resultadoBusqueda = [[NSMutableArray alloc] init];
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
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"citiesCountriesCell"];
    id aux = _listadoCiudadesPaises[indexPath.row];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[self.resultadoBusqueda objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"country subtitle tableview", nil),[[self.resultadoBusqueda objectAtIndex:indexPath.row] valueForKey:@"country"]];
        [label setText:[NSString stringWithFormat:@"%@", [[self.resultadoBusqueda objectAtIndex:indexPath.row] valueForKey:@"_id"]]];
    } else {
        //NSLog(@"nombre desde la funcion de armado de la tabla: %@", [aux valueForKey:@"name"]);
        //[_resultadoBusqueda removeAllObjects];
        cell.textLabel.text = [aux valueForKey:@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"country subtitle tableview", nil),[aux valueForKey:@"country"]];
        [label setText:[NSString stringWithFormat:@"%@", [aux valueForKey:@"_id"]]];
        // [self.hiddenCellLabel setText:[NSString stringWithFormat:@"test %ld", (long)indexPath.row]];

    }
    
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *locationID;
    if (tableView==self.searchDisplayController.searchResultsTableView) {
        locationID = (NSString *)[  [self.resultadoBusqueda objectAtIndex:indexPath.row] valueForKey:@"_id"];
    } else {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *taggedLabel =(UILabel*) [selectedCell.contentView viewWithTag:1];
        locationID = taggedLabel.text;
    }
   
    [self.delegate addedLocation:locationID];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return _resultadoBusqueda.count;
    } else {
        return _listadoCiudadesPaises.count;
    }
}


#pragma Metodos delegados de Barra de busqueda

-(void)filterContentForSearchText:(NSString *)searchText scope:(NSString *) scope{
    //NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    //id aux = self.listadoCiudadesPaises ;
    //self.resultadoBusqueda = [[aux valueForKey:@"name"] filteredArrayUsingPredicate:resultPredicate];
    //dispatch_async(dispatch_get_main_queue(), ^{
        [_resultadoBusqueda removeAllObjects];
        int count = 0;
        for (id strObj in _listadoCiudadesPaises)
        {
            if ([ [strObj valueForKey:@"name"] containsString:searchText ]){
                //NSLog (@"Found: %@", strObj);
                [_resultadoBusqueda addObject:strObj];
            }
            count ++;
        }
        [self.tableView reloadData];
    //});
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterContentForSearchText:searchString scope:@"Title"];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption{
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:@"Title"];
    return YES;
}
-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    [_resultadoBusqueda removeAllObjects];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [_resultadoBusqueda removeAllObjects];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    //[_resultadoBusqueda removeAllObjects];
}


@end
