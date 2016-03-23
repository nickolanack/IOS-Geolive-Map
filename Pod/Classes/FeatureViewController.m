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
#import "MapFormDelegate.h"



@interface FeatureViewController ()

@property id<MapFormDelegate> formDelegate;

@property UIImagePickerController *picker;
@property CLLocationManager *locMan;


@end

@implementation FeatureViewController

@synthesize delegate, media, attributes, details;

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.hidesBackButton=true;
    self.tableView.editing=true;
    
    
    if([[UIApplication sharedApplication].delegate conformsToProtocol:@protocol(MapFormDelegate)]){
        _formDelegate=[UIApplication sharedApplication].delegate;
    }
    
    
    
    
    if(!self.picker){
        
        _picker = [[UIImagePickerController alloc] init];
        
        //picker.wantsFullScreenLayout = YES;
        _picker.navigationBarHidden = YES;
        _picker.toolbarHidden = YES;
        
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //picker.showsCameraControls=YES;
        
        _picker.mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        _picker.delegate = self;
        
    }
    
    _locMan =[[CLLocationManager alloc] init];
    
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        
        if([ CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
            [_locMan requestWhenInUseAuthorization];
            [_locMan startUpdatingLocation];
        }else{
            [_locMan startUpdatingLocation];
        }
        
        
        
    }else{
        
        NSLog(@"Denied location");
    }
    
    self.attributes=[[NSMutableDictionary alloc] initWithDictionary:@{@"keywords":@[]}];
    self.details=[[NSMutableDictionary alloc] initWithDictionary:@{@"name":@""}];
    
    [self takePhoto];
    
}

#pragma Mark Buttons

- (IBAction)onSaveFormButtonTap:(id)sender {
    
    
    NSMutableDictionary *data=self.media;
    
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,data);
    
    NSDictionary *formData=@{@"name":[self.details objectForKey:@"name"], @"attributes":self.attributes, @"location":[_locMan location]};
    
    [self displayUploadStatus];
    
    FeatureViewController * __block me=self;
    
    void (^progressHandler)(float) = ^(float percentFinished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [me.progressView setProgress:percentFinished];
        });
        
    };
    void (^completion)(NSDictionary *) = ^(NSDictionary *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [me hideUploadStatus];
            [me.progressView setProgress:0.0];
            
            if([[me.navigationController topViewController] isKindOfClass:[FeatureViewController class]]){
                [me.navigationController popViewControllerAnimated:true];
            }
        });
    };
    
    
    if([[data objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]){
        
        /*
         * Upload Image Files
         */
        
        if([data valueForKey:@"success"]==nil&&[data valueForKey:@"uploading"]==nil){
            [data setValue:[NSNumber numberWithBool:true] forKey:@"uploading"];
            
            [_formDelegate saveForm:formData withImage:[data objectForKey:UIImagePickerControllerOriginalImage] withProgressHandler:progressHandler andCompletion:completion];
            
        }else if ([data valueForKey:@"uploading"]!=nil){
            
        }
    }else{
        
        if([[data objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]){
            
            
            /*
             * Upload Video Files
             */
            
            
            if([data valueForKey:@"success"]==nil&&[data valueForKey:@"uploading"]==nil){
                
                [_formDelegate  saveForm:formData withVideo:[data objectForKey:UIImagePickerControllerMediaURL] withProgressHandler:progressHandler andCompletion:completion];
            }
            
        }
        
    }
    
    
}

-(void)displayUploadStatus{
    [self.label setHidden:false];
    [self.progressView setHidden:false];
}

-(void)hideUploadStatus{
    [self.label setHidden:true];
    [self.progressView setHidden:true];
}

- (IBAction)onCancelFormButtonTap:(id)sender {
    
    if([[self.navigationController topViewController] isKindOfClass:[FeatureViewController class]]){
        [self.navigationController popViewControllerAnimated:true];
    }

}


-(void)viewWillDisappear:(BOOL)animated{

    [self.tableView setDelegate:nil];
    
}


#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    
    NSArray *keywords=[attributes objectForKey:@"keywords"];
    
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
            if(details!=nil){
                name=[details objectForKey:@"name"];
            }
            
            if(name==nil){
                name=@"";
                [((GFTitleCell *) cell).titleField becomeFirstResponder];
            }
            [((GFTitleCell *) cell).titleField setText:name];
        }
        
    }
    
    if(row>1){
        NSArray *keywords=[attributes objectForKey:@"keywords"];
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
        [((id<GFDelegateCell>)cell) setDelegate:self];
        [((id<GFDelegateCell>)cell) setTableView:tableView];
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row=indexPath.row;
    if(row==0)return 35;
    if(row>1){
        NSArray *keywords=[attributes objectForKey:@"keywords"];
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
        NSArray *keywords=[attributes objectForKey:@"keywords"];
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
        NSMutableArray *a=[[NSMutableArray alloc] initWithArray:[attributes objectForKey:@"keywords"]];
        [a removeObjectAtIndex:index];
        [attributes setObject:[[NSArray alloc] initWithArray:a] forKey:@"keywords"];
        [self.tableView reloadData];
    }
    
}



-(void)takePhoto{
    
    [self presentViewController:_picker animated:false completion:^{
        
    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:info];
    self.media=dict;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
}

@end
