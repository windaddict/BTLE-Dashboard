//
//  JMKViewController.m
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/5/14.
//  Copyright (c) 2014 John M. P. Knox.
/*
 BTLE Dashboard
 Copyright (C) 2014 John M. P. Knox
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "JMKViewController.h"
#import "JMKPeripheralDetailViewController.h"
#import <CoreBluetooth/CBUUID.h>

@interface JMKViewController ()
@property (nonatomic, strong) JMKBluetoothManager * bluetoothManager;
@end

@implementation JMKViewController

static const NSString *kJMKPeripheralCellReuseIdentifier = @"JMKPeripheralCell";

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];

    if(self){
        //TODO: setup
    }
    return self;
}

-(void)dealloc{
    [self.bluetoothManager removeDelegate: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"BTLE Peripherals";
    self.view.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.25 alpha:1.0];
    
    self.peripheralTableView.delegate = self;
    self.peripheralTableView.dataSource = self;
    [self.peripheralTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:(NSString*)kJMKPeripheralCellReuseIdentifier];
    
	// Do any additional setup after loading the view, typically from a nib.
    if(nil == self.bluetoothManager){
        self.bluetoothManager = [JMKBluetoothManager new];
    }
    [self.bluetoothManager addDelegate:self];
    [self.bluetoothManager startPeripheralScan];
}

-(void)viewWillDisappear:(BOOL)animated{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (sender == self) {
        JMKPeripheralDetailViewController * detailVC = segue.destinationViewController;
        detailVC.peripheral = [self peripheralForIndexPath:self.peripheralTableView.indexPathForSelectedRow];
        detailVC.advertisementDictionary = [self advertisementDictionaryForPeripheralIdentifier:detailVC.peripheral.identifier];
    }
}

- (CBPeripheral*)peripheralForIndexPath:(NSIndexPath *) indexPath{
    NSString* key = [self.bluetoothManager.peripherals allKeys][indexPath.row];
    CBPeripheral* peripheral = self.bluetoothManager.peripherals[key];
    return peripheral;
}

- (NSDictionary*)advertisementDictionaryForPeripheralIdentifier:(NSUUID *) identifier{
    NSDictionary *adDict = self.bluetoothManager.advertisedServices[identifier];
    return adDict;
}

#pragma mark - JMKBluetoothManagerDelegate

/**
 * Log message and send to UI
 */
- (void)logActivity: (NSString*)logMessage{
    self.textView.text = [self.textView.text stringByAppendingString:logMessage];
}

-(void)peripheralDiscovered:(CBPeripheral*)peripheral{
    [self.peripheralTableView reloadData];
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //TODO: drill down
    [self performSegueWithIdentifier:@"peripheralDetail" sender:self];
}

#pragma UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.bluetoothManager.peripherals allKeys] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:(NSString*)kJMKPeripheralCellReuseIdentifier];
    CBPeripheral* peripheral = [self peripheralForIndexPath:indexPath];
    [cell.textLabel setText:peripheral.name];
    return cell;
}

@end
