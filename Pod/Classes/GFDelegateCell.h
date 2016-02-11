//
//  GFDelegateCell.h
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2014-08-08.
//  Copyright (c) 2014 Nick Blackwell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuViewController.h"

@protocol GFDelegateCell <NSObject>

@property MenuViewController *delegate;
@property UITableView *tableView;



@end
