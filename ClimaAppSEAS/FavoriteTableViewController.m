//
//  FavoriteTableViewController.m
//  ClimaAppSEAS
//
//  Created by Leonardo Puga De Biase on 10/1/15.
//  Copyright © 2015 Leonardo Puga De Biase. All rights reserved.
//

#import "FavoriteTableViewController.h"
#import "LocationWeatherObjetc.h"

@interface FavoriteTableViewController ()
@property (nonatomic) NSString *directorioPlist;
@property (nonatomic) NSString *directorioPlistPreferencias;
@property (nonatomic, strong) NSMutableArray *listaLocalidadesCompletas;
@property (nonatomic, strong) NSMutableArray *listaLocalidadesCompletasCopy;
@property (nonatomic) NSMutableDictionary *listaLocalidadesIDs;
@end

@implementation FavoriteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *documentDir = [[NSFileManager defaultManager]
                          URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSURL *plist = [documentDir URLByAppendingPathComponent:@"favoriteLocations.plist"];
    _directorioPlist = plist.path;
    
    
    NSURL *plist2 = [documentDir URLByAppendingPathComponent:@"preferences.plist"];
    _directorioPlist = plist.path;
    _directorioPlistPreferencias = plist2.path;
    _listaLocalidadesIDs = [[NSMutableDictionary alloc] initWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:_directorioPlistPreferencias]];
    _listaLocalidadesCompletas = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:_directorioPlist]];
    _listaLocalidadesCompletasCopy = [[NSMutableArray alloc] initWithArray:_listaLocalidadesCompletas];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // _listaLocalidadesCompletasCopy = _listaLocalidadesCompletas;
    return _listaLocalidadesCompletasCopy.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favoriteReusableCell" forIndexPath:indexPath];
    
    UILabel *mainLabel = [[UILabel alloc] init];
    mainLabel.tag = 10;
    mainLabel.font = [UIFont systemFontOfSize:14.0];
    mainLabel.textColor = [UIColor blackColor];
    [mainLabel setText:[NSString stringWithFormat:@"%@", [_listaLocalidadesCompletasCopy[indexPath.row] valueForKey:@"locationID"]]];
    [cell.contentView addSubview:mainLabel];
    
    cell.textLabel.text = [_listaLocalidadesCompletasCopy[indexPath.row] valueForKey:@"locationName"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"country subtitle tableview", nil),[_listaLocalidadesCompletasCopy[indexPath.row] valueForKey:@"locationParent"]];
    
    
    //[cell.contentView addSubview:label];
    // Configure the cell...
    
    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        UITableViewCell *auxCell = [tableView cellForRowAtIndexPath:indexPath];
        
        [tableView beginUpdates];
        [self deleteFavoriteLocationAtIndex:indexPath.row inTableCell:auxCell];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
       // [tableView reloadData];
        [tableView endUpdates];
        [_favListDelegate locationWasEliminated:YES];      
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 0;
    }else{
        return 50;
    }
}

-(void)deleteFavoriteLocationAtIndex:(long)index  inTableCell:(UITableViewCell *)tableCell{
    UILabel *mainLabel = (UILabel *)[tableCell.contentView viewWithTag:10];
    NSLog(@"ID a eliminar: %@ at index: %ld", mainLabel.text, index);
    NSString *auxLocationID=[[NSString alloc] init];
    NSString *labelLocationID=[[NSString alloc] initWithFormat:@"%@", mainLabel.text];
    for (LocationWeatherObjetc *aux in _listaLocalidadesCompletas) {
        auxLocationID = [NSString stringWithFormat:@"%@", [aux locationID]];
        if ([auxLocationID isEqualToString:labelLocationID]) {
            [_listaLocalidadesCompletasCopy removeObjectAtIndex:index];
        }
    }   
    
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [LocationWeatherObjetc deleteLocation:mainLabel.text enDirectorio:_directorioPlist tambienDirectorioPrefs:_directorioPlistPreferencias];
    //});
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
