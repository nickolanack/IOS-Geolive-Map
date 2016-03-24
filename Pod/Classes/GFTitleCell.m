//
//  GFTitleCell.m
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2014-08-08.
//  Copyright (c) 2014 Nick Blackwell. All rights reserved.
//

#import "GFTitleCell.h"

@implementation GFTitleCell

@synthesize delegate, tableView, fieldName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
    fieldName=@"name";
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onEditTitle:(id)sender {
    
    [self.delegate.details setObject:self.titleField.text forKey:fieldName];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    return YES;
}
@end
