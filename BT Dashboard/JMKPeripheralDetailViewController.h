//
//  JMKPeripheralDetailViewController.h
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/19/14.
//  Copyright (c) 2014 John M. P. Knox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface JMKPeripheralDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) NSDictionary *advertisementDictionary;

@end
