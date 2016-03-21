//
//  MenuViewController.m
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2013-10-22.
//  Copyright (c) 2013 Nick Blackwell. All rights reserved.
//

#import "MenuViewController.h"
#import "FeatureViewController.h"
#import "FeatureDetailViewController.h"



#import "MapViewController.h"


#import "FeatureCell.h"
#import "StyleProvider.h"
#import "MapFormDelegate.h"




@interface MenuViewController ()

@property NSMutableDictionary *media;



@property CLLocationManager *locMan;

@property UIImagePickerController *picker;
@property NSArray *usersFeatures;

@property NSIndexPath *selectedFeaturePath;

@property UIRefreshControl *refreshControl;

@property id<StyleProvider> styler;
@property id<MapFormDelegate> delegate;


@end

@implementation MenuViewController

@synthesize media, attributes, details;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    if([[UIApplication sharedApplication].delegate conformsToProtocol:@protocol(StyleProvider)]){
        _styler=[UIApplication sharedApplication].delegate;
    }
    
    if(!_styler){
        @throw [[NSException alloc] initWithName:@"No StyleProvider" reason:@"Requires StyleProvider to handle styles" userInfo:nil];
    }
    
    if([[UIApplication sharedApplication].delegate conformsToProtocol:@protocol(MapFormDelegate)]){
        _delegate=[UIApplication sharedApplication].delegate;
    }
    
    if(!_delegate){
        @throw [[NSException alloc] initWithName:@"No MapFormDelegate" reason:@"Requires MapFormDelegate to handle implementation specific methods" userInfo:nil];
    }
    
    [self initBottomBar];
    

    [self.startNewFormButton setTitle:[_styler textForNamedLabel:@"newformbutton.title" withDefault:self.startNewFormButton.titleLabel.text] forState:UIControlStateNormal];
    [self.emptyMsgLabel setText:[_styler textForNamedLabel:@"emptymessage.label" withDefault:self.emptyMsgLabel.text]];
   
    self.locMan=[[CLLocationManager alloc] init];
    [self.locMan setDelegate:self];
    
    [self.progressView setProgress:0.0];
    
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    {
        
        if([ CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
            [self.locMan requestWhenInUseAuthorization];
            [self.locMan startUpdatingLocation];
        }else{
            [self.locMan startUpdatingLocation];
        }
        
        
        
    }else{
        
        NSLog(@"Denied location");
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
    
    

    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshUsersFeaturesList)
             forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:_refreshControl];

   
    [self performSelector:@selector(refreshUsersFeaturesList) withObject:nil afterDelay:5.0];
    
}






- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status __OSX_AVAILABLE_STARTING(__MAC_10_7,__IPHONE_4_2){


}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)takePhoto{
    
    

    
    [self presentViewController:_picker animated:false completion:^{
        
        
    }];
    
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    if(self.media==nil){
        
        //[self takePhoto]; //always take a photo first
        
    }else{
        bool showAttributes=true;
        if(showAttributes&&self.attributes==nil&&self.details==nil){
            
            
            self.attributes=[[NSMutableDictionary alloc] initWithDictionary:@{@"keywords":@[]}];
            self.details=[[NSMutableDictionary alloc] initWithDictionary:@{@"name":@""}];
            
            
           
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserForm" bundle:nil];
            UIViewController *myController = [storyboard instantiateInitialViewController];
            [((FeatureViewController *)myController) setDelegate:self];
            [self.navigationController pushViewController: myController animated:YES];
            
        }else{
            
            [self save];
            
        }
        
    }
    
}
-(void)cancel{

    [self clearData];
    if([[self.navigationController topViewController] isKindOfClass:[FeatureViewController class]]){
        [self.navigationController popViewControllerAnimated:true];
    }

}
-(void)save{
    
    if([[self.navigationController topViewController] isKindOfClass:[FeatureViewController class]]){
        [self.navigationController popViewControllerAnimated:true];
    }
    
    NSMutableDictionary *data=self.media;
    
    NSLog(@"%s: %@",__PRETTY_FUNCTION__,data);
    
    NSDictionary *formData=@{@"name":[self.details objectForKey:@"name"], @"attributes":self.attributes, @"location":[self.locMan location]};

    [self displayUploadStatus];
    
    MenuViewController * __block me=self;
    
    void (^progressHandler)(float) = ^(float percentFinished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [me.progressView setProgress:percentFinished];
        });
        
    };
    void (^completion)(NSDictionary *) = ^(NSDictionary *response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [me hideUploadStatus];
            [me.progressView setProgress:0.0];
            [me clearData];
            [me refreshUsersFeaturesList];
        });
    };
    
    
    if([[data objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]){
        
        /*
         * Upload Image Files
         */
    
        if([data valueForKey:@"success"]==nil&&[data valueForKey:@"uploading"]==nil){
            [data setValue:[NSNumber numberWithBool:true] forKey:@"uploading"];
           
            [_delegate saveForm:formData withImage:[data objectForKey:UIImagePickerControllerOriginalImage] withProgressHandler:progressHandler andCompletion:completion];
            
        }else if ([data valueForKey:@"uploading"]!=nil){
            
        }
    }else{
        
                 if([[data objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]){
            
            
            /*
             * Upload Video Files
             */
            
          
            if([data valueForKey:@"success"]==nil&&[data valueForKey:@"uploading"]==nil){
            
                [_delegate  saveForm:formData withVideo:[data objectForKey:UIImagePickerControllerMediaURL] withProgressHandler:progressHandler andCompletion:completion];
            }
            
        }
        
    }
}



-(void)clearData{

    self.media=nil;
    self.attributes=nil;
    self.details=nil;

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UIViewController *vc=[segue destinationViewController];
    
    
    if([vc isKindOfClass:[FeatureDetailViewController class]]){
        
        FeatureDetailViewController *fvc=(FeatureDetailViewController *)vc;
        [fvc setMetadata:[_usersFeatures objectAtIndex:[_selectedFeaturePath row]]];
        
    }
    


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

- (IBAction)onPhotoClick:(id)sender {
    [self takePhoto];
}



#pragma mark Status

-(void)hideEmptyMessage{
    [self.emptyMsgLabel setHidden:true];
    [self.emptyMsgUrl setHidden:true];
}
-(void)displayEmptyMessage{
    
    [self.emptyMsgLabel setHidden:false];
    [self.emptyMsgUrl setHidden:false];
}
-(void)displayUpdatingMessage{
    [self.updatingLabel setHidden:false];
    //[self.updatingSpinner setHidden:false];
}
-(void)hideUpdatingMessage{
    [self.updatingLabel setHidden:true];
    //[self.updatingSpinner setHidden:true];
}

-(void)displayUploadStatus{
    [self.label setHidden:false];
    [self.progressView setHidden:false];
}

-(void)hideUploadStatus{
    [self.label setHidden:true];
    [self.progressView setHidden:true];
}

#pragma mark Collection View
-(void)refreshUsersFeaturesList{
    [self hideEmptyMessage];
    [self displayUpdatingMessage];
    
    if(!_refreshControl.refreshing){
        [_refreshControl beginRefreshing];
    }
    
    
    
    
    [_delegate listUsersMenuItemsWithCompletion:^(NSArray *results) {
        _usersFeatures=results;
        [self hideUpdatingMessage];
        [self reloadCollection];
        [_refreshControl endRefreshing];
    }];
    
    
    
    //[self performSelector:@selector(reloadCollection) withObject:nil afterDelay:10.0];
    
}

-(void)reloadCollection{
    
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if(_usersFeatures==nil||[_usersFeatures count]==0){
        
        
        [self displayEmptyMessage];
        return 0;
    }
    [self hideEmptyMessage];
    return [_usersFeatures count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    

    UICollectionViewCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"featureCell" forIndexPath:indexPath];
    
    FeatureCell *fcell=(FeatureCell *)cell;
    
    NSDictionary *feature=[_usersFeatures objectAtIndex:[indexPath row]];
    
    [_delegate formatMenuItemsCell:fcell withData:feature];
    
    
    
    return cell;

}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    _selectedFeaturePath=indexPath;
    return true;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserItemDetail" bundle:nil];
    UIViewController *myController = [storyboard instantiateInitialViewController];
    [((FeatureDetailViewController *)myController) setMetadata:[_usersFeatures objectAtIndex:[_selectedFeaturePath row]]];
    [self.navigationController pushViewController: myController animated:YES];
    
}


#pragma mark Bottom Bar Buttons

-(void)initBottomBar{
    
    int buttonCount= [_delegate menuFormNumberOfButtons];
    NSArray *buttons=@[self.bottomButton0];
    for(int i=0;i<buttons.count;i++){
        UIButton *button=[buttons objectAtIndex:i];
        
        if(i<buttonCount){
            UIImage *image =[_styler imageForNamedImage:[NSString stringWithFormat:@"button.%i", i] withDefault:nil];
            if(image){
                [button setImage:image forState:UIControlStateNormal];
            }
        }else{
            [button setHidden:true];
            
        }
    }

}

- (IBAction)onMapButtonTap:(id)sender {
    
    [_delegate menuForm:(MenuViewController *) self BottomBarButtonWasTappedAtIndex:0];
    
}
- (IBAction)onHelpTap:(id)sender {
    
    [_delegate menuFormHelpButtonWasTapped:(MenuViewController *) self];
    
}
@end
