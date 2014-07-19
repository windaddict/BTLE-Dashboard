//
//  JMKBluetoothManager.h
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/19/14.
//  Copyright (c) 2014 John M. P. Knox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol JMKBluetoothManagerDelegate <NSObject>

@optional
-(void)peripheralDiscovered:(CBPeripheral*)peripheral;
-(void)logActivity:(NSString*)message;

@end

@interface JMKBluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) NSMutableDictionary *peripherals;

-(void)startPeripheralScan;
-(void)addDelegate: (id<JMKBluetoothManagerDelegate>) delegate;
-(void)removeDelegate: (id<JMKBluetoothManagerDelegate>) delegate;

@end
