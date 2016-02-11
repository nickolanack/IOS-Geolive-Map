//
//  GFTitleCell.h
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2014-08-08.
//  Copyright (c) 2014 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GFDelegateCell.h"

@interface GFTitleCell : UITableViewCell<GFDelegateCell, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleField;
- (IBAction)onEditTitle:(id)sender;


@end
