//
//  JMKBluetoothManager.h
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol JMKBluetoothManagerDelegate <NSObject>

@optional
-(void)peripheralDiscovered:(CBPeripheral*)peripheral;
-(void)logActivity:(NSString*)message;

@end

@interface JMKBluetoothManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) NSMutableDictionary *peripherals; ///< A dictionary of CBPeripherals with their identifier as key
@property (nonatomic, strong) NSMutableDictionary *advertisedServices; ///< a dictionary with key peripheral.identifier. values are dictionaries

-(void)startPeripheralScan;
-(void)addDelegate: (id<JMKBluetoothManagerDelegate>) delegate;
-(void)removeDelegate: (id<JMKBluetoothManagerDelegate>) delegate;

@end
