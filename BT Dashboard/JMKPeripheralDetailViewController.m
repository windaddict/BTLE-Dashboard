//
//  JMKPeripheralDetailViewController.m
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/19/14.
//  Copyright (c) 2014 John M. P. Knox. All rights reserved.
//

#import "JMKPeripheralDetailViewController.h"
#import "JMKPeripheralDetailCell.h"

@interface JMKPeripheralDetailViewController ()

@end

@implementation JMKPeripheralDetailViewController

static const NSString *kDetailCellIdentifier = @"detailCell";

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.detailTableView.delegate = self;
    self.detailTableView.dataSource = self;
    [self.detailTableView registerNib:[UINib nibWithNibName:@"JMKPeripheralDetailCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:(NSString*)kDetailCellIdentifier];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.peripheral.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - peripheral data


-(NSString*)advertisementDictionaryKeyForIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section != 1){
        NSLog(@"ERROR: advertisementDictionaryForIndexPath asked for wrong section");
        return nil;
    }
    NSArray * keys = [self.advertisementDictionary allKeys];
    return keys[indexPath.row];
}

-(NSDictionary*)advertisementDictionaryForIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section != 1){
        NSLog(@"ERROR: advertisementDictionaryForIndexPath asked for wrong section");
        return nil;
    }
    return self.advertisementDictionary[[self advertisementDictionaryKeyForIndexPath:indexPath]];
}

-(NSString*)nameForAdvertisementDataKey:(NSString *)key{
    if([key isEqualToString:CBAdvertisementDataLocalNameKey]){
        return @"Local Name";
    } else if ([key isEqualToString:CBAdvertisementDataManufacturerDataKey]){
        return @"Manufacturer Data";
    } else if([key isEqualToString: CBAdvertisementDataServiceDataKey]){
        return @"Service Data Key";
    } else if([key isEqualToString: CBAdvertisementDataServiceUUIDsKey]){
        return @"Service UUID";
    } else if([key isEqualToString: CBAdvertisementDataOverflowServiceUUIDsKey]){
        return @"Overflow Service UUIDs";
    } else if([key isEqualToString: CBAdvertisementDataTxPowerLevelKey]){
        return @"Tx Power Level";
    } else if([key isEqualToString: CBAdvertisementDataIsConnectable]){
        return @"Is Connectable";
    } else if([key isEqualToString: CBAdvertisementDataSolicitedServiceUUIDsKey]){
        return @"Solicited Service UUIDs";
    }
                
    return [NSString stringWithFormat:@"*%@", key];
}

-(NSString*)removeLineBreaks:(NSString*)input{
    return [input stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

#pragma mark - Table view data source
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Peripheral";
            break;
        case 1:
            return @"Advertisement Data";
            break;
        default:
            break;
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0: //peripheral details
            return 4;
            break;
        case 1: //services
            return [self.advertisementDictionary count];
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JMKPeripheralDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString*)kDetailCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *stateDescription = @"";

    if(indexPath.section == 0){
        switch (indexPath.row) {
            case 0:
                [cell.titleLabel setText:@"Name"];
                [cell.detailLabel setText:self.peripheral.name];
                break;
            case 1:
                [cell.titleLabel setText:@"State"];
                CBPeripheralState state = self.peripheral.state;
                if(state == CBPeripheralStateConnected){
                    stateDescription = @"Connected";
                } else if (state == CBPeripheralStateConnecting){
                    stateDescription = @"Connecting";
                } else if (state == CBPeripheralStateDisconnected){
                    stateDescription = @"Disconnected";
                }
                [cell.detailLabel setText:stateDescription];
                break;
            case 2:
                [cell.titleLabel setText:@"Identifier"];
                [cell.detailLabel setText:[self.peripheral.identifier UUIDString]];
                break;
            case 3:
                [cell.titleLabel setText:@"RSSI (dB)"];
                [cell.detailLabel setText:self.peripheral.RSSI.stringValue];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1){
        [cell.titleLabel setText:[self nameForAdvertisementDataKey:[self advertisementDictionaryKeyForIndexPath:indexPath]]];
        NSString *detailString = [self removeLineBreaks:[[self advertisementDictionaryForIndexPath:indexPath] description]];
        [cell.detailLabel setText:detailString];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
