//
//  JMKViewController.m
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/5/14.
//  Copyright (c) 2014 John M. P. Knox. All rights reserved.
//

#import "JMKViewController.h"
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
    NSString* key = [self.bluetoothManager.peripherals allKeys][indexPath.row];
    CBPeripheral* peripheral = self.bluetoothManager.peripherals[key];
    [cell.textLabel setText:peripheral.name];
    return cell;
}

@end
