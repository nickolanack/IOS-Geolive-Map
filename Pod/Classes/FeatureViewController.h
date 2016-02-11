//
//  PlacemarkViewController.h
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2014-08-07.
//  Copyright (c) 2014 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuViewController.h"

@interface FeatureViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property MenuViewController *delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;




- (IBAction)saveClick:(id)sender;
- (IBAction)cancelClick:(id)sender;

@end
