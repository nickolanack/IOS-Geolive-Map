//
//  GFKeywordEntryCell.m
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2014-08-08.
//  Copyright (c) 2014 Nick Blackwell. All rights reserved.
//

#import "AttributeMultiTextFieldCell.h"


@interface AttributeMultiTextFieldCell ()

@property NSMutableArray *keywords;
@property bool isEditing;

@end


@implementation AttributeMultiTextFieldCell


@synthesize delegate, tableView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
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




- (IBAction)onEditKeyword:(id)sender {
    [self.keywords setObject:self.keywordField.text atIndexedSubscript:self.keywords.count- 1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField endEditing:YES]; //so return button closes keyboard
    return YES;
    
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.isEditing=true;
    if(self.delegate.attributes==nil)self.delegate.attributes  =[[NSMutableDictionary alloc] initWithDictionary:@{@"keywords":@[]}];
    NSArray *k=nil;
    k=[self.delegate.attributes valueForKey:@"keywords"];
    if(k==nil){
        
        k=@[];
        
    }
    
    
    self.keywords=[[NSMutableArray alloc ]initWithArray:k];
    [self.keywords addObject:@""];
    

}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if(!self.isEditing)return;
    self.keywordField.text=@"";
    if([[self.keywords lastObject] isEqualToString:@""]){
        [self.keywords removeLastObject];
    }
    
    [self.delegate.attributes setValue:[[NSArray alloc] initWithArray:self.keywords] forKey:@"keywords"];
  
    [self.tableView reloadData];
    self.isEditing=false;
   
    
}


@end
