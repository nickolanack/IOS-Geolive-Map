//
//  PlacemarkViewController.m
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2014-08-07.
//  Copyright (c) 2014 Nick Blackwell. All rights reserved.
//

#import "FeatureViewController.h"
#import "GFDelegateCell.h"
#import "GFKeywordCell.h"
#import "GFTitleCell.h"



@interface FeatureViewController ()

@end

@implementation FeatureViewController

@synthesize delegate;

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton=true;
    self.tableView.editing=true;
}
-(void)viewDidAppear:(BOOL)animated{




}
#pragma Mark Buttons

- (IBAction)onSaveFormButtonTap:(id)sender {
    [self.delegate save];
}

- (IBAction)onCancelFormButtonTap:(id)sender:(id)sender {
    [self.delegate cancel];
}


-(void)viewWillDisappear:(BOOL)animated{

    [self.tableView setDelegate:nil];
    
}


#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    
    NSArray *keywords=[self.delegate.attributes objectForKey:@"keywords"];
    
    if(keywords!=nil){
        return 3+[keywords count];
        
    }
    
    return 3;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=nil;
    NSInteger row=[indexPath row];
    
    if(row==0){
        cell= [tableView dequeueReusableCellWithIdentifier:@"labelCell"];
        
    }
    
    if(row==1){
        cell= [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
        
        if([cell isKindOfClass:[GFTitleCell class]]){
            
            NSString *name=nil;
            if(self.delegate.details!=nil){
                name=[self.delegate.details objectForKey:@"name"];
            }
            
            if(name==nil){
                name=@"";
                [((GFTitleCell *) cell).titleField becomeFirstResponder];
            }
            [((GFTitleCell *) cell).titleField setText:name];
        }
        
    }
    
    if(row>1){
        NSArray *keywords=[self.delegate.attributes objectForKey:@"keywords"];
        if(keywords!=nil&&[keywords count]){
            
            if(row<(2+[keywords count])){
                
                cell= [tableView dequeueReusableCellWithIdentifier:@"keywordLabelCell"];
                if([cell isKindOfClass:[GFKeywordCell class]]){
                    ((GFKeywordCell *) cell).value.text=[keywords objectAtIndex:[indexPath item]-2];
                }
                
            }
            
            if(row==(2+[keywords count])){
                cell= [tableView dequeueReusableCellWithIdentifier:@"keywordCell"];
            }
            
        }else{
            
            if(row==2){
                cell= [tableView dequeueReusableCellWithIdentifier:@"keywordCell"];
            }
            
        }
    }
    
    

    if([cell conformsToProtocol:@protocol(GFDelegateCell)]){
        [((id<GFDelegateCell>)cell) setDelegate:self.delegate];
        [((id<GFDelegateCell>)cell) setTableView:tableView];
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row=indexPath.row;
    if(row==0)return 35;
    if(row>1){
        NSArray *keywords=[self.delegate.attributes objectForKey:@"keywords"];
        if(keywords!=nil&&[keywords count]){
            
            if(row<(2+[keywords count])){
                return 35;
            }
            
        }
    }
    return tableView.rowHeight;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row=indexPath.row;
    if(row>1){
        NSArray *keywords=[self.delegate.attributes objectForKey:@"keywords"];
        if(keywords!=nil&&[keywords count]){
            
            if(row<(2+[keywords count])){
                return YES;
            }
            
        }
    }
    return NO;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    
    if(editingStyle==UITableViewCellEditingStyleDelete){
        NSInteger index=indexPath.row-2;
        NSMutableArray *a=[[NSMutableArray alloc] initWithArray:[self.delegate.attributes objectForKey:@"keywords"]];
        [a removeObjectAtIndex:index];
        [self.delegate.attributes setObject:[[NSArray alloc] initWithArray:a] forKey:@"keywords"];
        [self.tableView reloadData];
    }
    
}

@end
