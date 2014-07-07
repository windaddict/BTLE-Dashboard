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

@end

@implementation JMKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.btDispatchQueue = dispatch_queue_create("btDispatchQueue", DISPATCH_QUEUE_SERIAL);
    
//    self.centralManager = [[CBCentralManager alloc]initWithDelegate: self queue:self.btDispatchQueue options: @{CBCentralManagerOptionRestoreIdentifierKey: @"JMKViewController"}];
    self.centralManager = [[CBCentralManager alloc]initWithDelegate: self queue:self.btDispatchQueue options: nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.centralManager stopScan];
}
                                        
                                        

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Managing the UI

- (void)logActivity: (NSString*)logMessage{
    logMessage = [logMessage stringByAppendingString:@"\n\n"];
    NSLog(@"%@", logMessage);
    JMKViewController __weak *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.textView.text = [self.textView.text stringByAppendingString:logMessage];
    });
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [self logActivity: @"did connect peripheral"];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self logActivity:@"did disconnect peripheral"];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    [self logActivity:[NSString stringWithFormat:@"did discover peripheral: %@", peripheral.description]];
    if(CBPeripheralStateConnected == peripheral.state){
        peripheral.delegate = self;
        [peripheral discoverServices:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [self logActivity:@"did fail to connect to peripheral"];
}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    [self logActivity:@"did retrieve connected peripherals"];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    [self logActivity:@"did retrieve peripherals"];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict{
    [self logActivity:@"did restore state"];
    
    NSArray* restoredPeripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    for(CBPeripheral* peripheral in restoredPeripherals){
        [self logActivity:[NSString stringWithFormat:@"restored peripheral: %@", peripheral.description]];
    }
    
    NSArray * UUIDs = dict[CBCentralManagerRestoredStateScanServicesKey];
    for(CBUUID* uuid in UUIDs){
        [self logActivity:[NSString stringWithFormat:@"restored UUIDs: %@", uuid.description]];
    }
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    
    CBUUID *alertNotificationServiceUUID = [CBUUID UUIDWithString:@"1811"];
    CBUUID *batteryServiceUUID = [CBUUID UUIDWithString:@"180F"];
    CBUUID *runningServiceUUID = [CBUUID UUIDWithString:@"1814"];
    CBUUID *userDataServiceUUID = [CBUUID UUIDWithString:@"181C"];
    CBUUID *genericAttributeServiceUUID = [CBUUID UUIDWithString:@"1801"];
    CBUUID *genericAccessServiceUUID = [CBUUID UUIDWithString:@"1800"];
    
    NSArray *servicesToSearchFor = @[alertNotificationServiceUUID, batteryServiceUUID, @"1810", @"1805", @"1818", @"1816", @"180A", @"1808", @"1809", @"180D", @"1812", @"1802", @"1803", @"1819", @"1807", @"180E", @"1806", runningServiceUUID, @"1813", @"1804", userDataServiceUUID, genericAttributeServiceUUID, genericAccessServiceUUID];

    NSArray *connectedPeripherals = nil;
    

    [self logActivity:@"did update state"];
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            [self logActivity:@"CBCentralManagerStatePoweredOff"];
            //TODO:
            break;
        case CBCentralManagerStatePoweredOn:
            [self logActivity:@"CBCentralManagerStatePoweredOn"];
            connectedPeripherals = [self.centralManager retrieveConnectedPeripheralsWithServices:servicesToSearchFor];
            [self logActivity:[NSString stringWithFormat:@"connectedPeripherals: %@", connectedPeripherals.description]];
            
            for(CBPeripheral *peripheral in connectedPeripherals){
                [self logActivity:[NSString stringWithFormat:@"Got %@: with services: %@", peripheral.name, peripheral.services]];
            }
            
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateResetting:
            [self logActivity:@"CBCmanagerStateResetting"];
            //TODO:
            break;
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateUnsupported:
            [self logActivity:@"CBMangerState ??"];
            break;
        default:
            break;
    }
}

#pragma mark - CBPeripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if(error){
        [self logActivity:error.description];
    }
    [self logActivity:[NSString stringWithFormat: @"Peripheral didDiscoverServices for: %@", peripheral.name]];
    for (CBService *service in peripheral.services) {
        [self logActivity:[NSString stringWithFormat:@"Found service: %@", service.description]];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices{
    [self logActivity:@"Peripheral didModifyServices"];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [self logActivity:@"Peripheral didUpadateNotificationStateForCharacteristic"];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [self logActivity:@"Peripheral didUpdateValueForCharacteristic:"];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    [self logActivity:@"Peripheral didUpdateValueForDescriptor"];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    [self logActivity:@"Peripheral didWriteValueForCharacteristic"];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error{
    [self logActivity:@"Peripheral didWriteValueForDescriptor"];
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
    [self logActivity:@"Peripheral didupdateName"];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error{
    [self logActivity:@"Peripheral didUpdateRSSI"];
}

@end
