//
//  GFKewordCell.h
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2014-08-08.
//  Copyright (c) 2014 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFDelegateCell.h"

@interface GFKeywordCell : UITableViewCell<GFDelegateCell>

@property (weak, nonatomic) IBOutlet UILabel *value;

@property int index;

@end
