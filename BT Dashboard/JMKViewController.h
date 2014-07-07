//
//  JMKViewController.h
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/5/14.
//  Copyright (c) 2014 John M. P. Knox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface JMKViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong) dispatch_queue_t btDispatchQueue;
@property (nonatomic, strong) CBCentralManager * centralManager;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
