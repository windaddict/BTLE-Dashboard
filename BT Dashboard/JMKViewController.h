//
//  JMKViewController.h
//  BT Dashboard
//
//  Created by John M. P. Knox on 7/5/14.
//  Copyright (c) 2014 John M. P. Knox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JMKBluetoothManager.h"

@interface JMKViewController : UIViewController  <JMKBluetoothManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *peripheralTableView;

@end
