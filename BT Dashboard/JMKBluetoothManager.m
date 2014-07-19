//
//  JMKBluetoothManager.m
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/19/14.
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

#import "JMKBluetoothManager.h"
#import <CoreBluetooth/CBUUID.h>

/**
 * A class used to wrap delegates for insertion into an array so they can be weakly referenced
 */
@interface JMKDelegateWrapper : NSObject
@property (nonatomic, weak) id<JMKBluetoothManagerDelegate> weakDelegate;
@end

@implementation JMKDelegateWrapper
//empty implementation
@end

@interface JMKBluetoothManager ()
@property (nonatomic, strong) dispatch_queue_t btDispatchQueue;
@property (nonatomic, strong) CBCentralManager * centralManager;
@property (nonatomic, strong) NSMutableArray *delegates;
@property (nonatomic, assign) BOOL isScanningForPeripherals;
@end

@implementation JMKBluetoothManager


-(id)init{
    self = [super init];
    if(self){
        self.peripherals = [NSMutableDictionary new];
        self.delegates = [NSMutableArray new];
        self.btDispatchQueue = dispatch_queue_create("btDispatchQueue", DISPATCH_QUEUE_SERIAL);
        self.isScanningForPeripherals = NO;
    }
    return self;
}

-(void)startPeripheralScan{
    if(!self.isScanningForPeripherals){
        self.isScanningForPeripherals = YES;
        //    self.centralManager = [[CBCentralManager alloc]initWithDelegate: self queue:self.btDispatchQueue options: @{CBCentralManagerOptionRestoreIdentifierKey: @"JMKViewController"}];
        self.centralManager = [[CBCentralManager alloc]initWithDelegate: self queue:self.btDispatchQueue options: nil];
    }
}

#pragma mark - utility
/**
 * Log message and send to UI
 */
- (void)logActivity: (NSString*)logMessage{
    logMessage = [logMessage stringByAppendingString:@"\n\n"];
    NSLog(@"%@", logMessage);

    //send logging message to any delegates
    for (JMKDelegateWrapper *wrapper in self.delegates) {
        if ([wrapper.weakDelegate respondsToSelector:@selector(logActivity:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wrapper.weakDelegate logActivity:logMessage];
            });
        }
    }
}

-(void)addDelegate:(id<JMKBluetoothManagerDelegate>)delegate{
    //we should check for duplicates since we wrap the delegates
    NSUInteger index = [self.delegates indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        JMKDelegateWrapper* delegateWrapper = obj;
        if (delegateWrapper.weakDelegate == delegate) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if(NSNotFound == index){
        JMKDelegateWrapper *wrapper = [JMKDelegateWrapper new];
        wrapper.weakDelegate = delegate;
        [self.delegates addObject:wrapper];
    }
}

-(void)removeDelegate:(id<JMKBluetoothManagerDelegate>)delegate{
    NSUInteger index = [self.delegates indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        JMKDelegateWrapper* delegateWrapper = obj;
        if (delegateWrapper.weakDelegate == delegate) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    if(NSNotFound == index){
        NSLog(@"ERROR: tried to remove a delegate that doesn't exist");
        
    } else {
        [self.delegates removeObjectAtIndex:index];
    }
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
    self.peripherals[peripheral.identifier] = peripheral;
    
    for (NSString* key in [advertisementData allKeys]) {
        [self logActivity:[NSString stringWithFormat:@"Peripheral advertisement key: %@, Description: %@", key, [advertisementData[key] description]]];
    }
    
    //send logging message to any delegates
    for (JMKDelegateWrapper *wrapper in self.delegates) {
        if ([wrapper.weakDelegate respondsToSelector:@selector(peripheralDiscovered:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wrapper.weakDelegate peripheralDiscovered:peripheral];
            });
        }
    }
    
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
            [self logActivity:@"CBManagerState ??"];
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
