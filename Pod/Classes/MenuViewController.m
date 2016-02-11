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

#import "ConnectionListener.h"

#import "GeoliveServer.h"
#import "StoredParameters.h"


#import "GeolLayer.h"
#import "GeolMarker.h"



#import "HTMLParser.h"
#import "ImageUtilities.h"

#import "MapViewController.h"


#import "FeatureCell.h"
#import "StyleProvider.h"
#import "MapFormDelegate.h"


@interface MenuViewController ()

@property NSMutableDictionary *media;


@property ConnectionListener *listener;
@property CLLocationManager *locMan;

@property UIImagePickerController *picker;
@property NSArray *usersFeatures;

@property NSIndexPath *selectedFeaturePath;

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
    
    if([[UIApplication sharedApplication].delegate conformsToProtocol:@protocol(MapFormDelegate)]){
        _delegate=[UIApplication sharedApplication].delegate;
    }
    
    if(!_delegate){
        @throw [[NSException alloc] initWithName:@"No MapFormDelegate" reason:@"Requires MapFormDelegate to handle implementation specific methods" userInfo:nil];
    }
    
   
    if(_styler&&[_styler respondsToSelector:@selector(textForNamedItem:withDefault:)]){
   
        [self.startNewFormButton setTitle:[_styler textForNamedlabel:@"newformbutton.title" withDefault:self.startNewFormButton.titleLabel.text] forState:UIControlStateNormal];
        
    }
    
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

   
    [self performSelector:@selector(refreshUsersFeaturesList) withObject:nil afterDelay:5.0];
    
}



-(void)displayUploadStatus{
    [self.label setHidden:false];
    [self.progressView setHidden:false];
}

-(void)hideUploadStatus{
    [self.label setHidden:true];
    [self.progressView setHidden:true];
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
            
           
            [self performSegueWithIdentifier:@"showAttributes" sender:self];
            
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
    
    if([[data objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]){
        
        /*
         * Upload Image Files
         */
        
        if([data valueForKey:@"success"]==nil&&[data valueForKey:@"uploading"]==nil){
            [data setValue:[NSNumber numberWithBool:true] forKey:@"uploading"];
        
            [_delegate uploadImage:[data objectForKey:UIImagePickerControllerOriginalImage] withProgressHandler:^(float percentFinished) {
                [self.progressView setProgress:percentFinished];
            } andCompletion:^(NSDictionary *response) {
                [self createMarkerAfterUpload:response];
                [self hideUploadStatus];
                [self.progressView setProgress:0.0];
                
            }];
            
        }else if ([data valueForKey:@"uploading"]!=nil){
            
        }
    }else{
        if([[data objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]){
            
            
            /*
             * Upload Video Files
             */
            
            if([data valueForKey:@"success"]==nil&&[data valueForKey:@"uploading"]==nil){
                
                [_delegate uploadVideo:[data objectForKey:UIImagePickerControllerMediaURL] withProgressHandler:^(float percentFinished) {
                    [self.progressView setProgress:percentFinished];
                } andCompletion:^(NSDictionary *response) {
                    [self createMarkerAfterUpload:response];
                }];
            }
            
        }
        
    }
}



-(void)clearData{

    self.media=nil;
    self.attributes=nil;
    self.details=nil;

}

-(void)createMarkerAfterUpload:(NSDictionary *)response{
    
    //[self takePhoto];
    
    
    [self.progressView setProgress:0.0];
    [self displayUploadStatus];
    
    if([[response objectForKey:@"success"] boolValue]){
        GeolLayer *l=[[GeolLayer alloc] init];
        [l setID:[[GeoliveServer SharedInstance] getDefaultLayer]];
        GeolMarker *m=[[GeolMarker alloc] init];
        
        
        NSString *name=nil;
        if(self.details!=nil){
            name=[self.details objectForKey:@"name"];
        }
        if(name==nil)name=@"";
        
        
        [m setName:name];
        [m setDescription:[response objectForKey:@"html"]];
        [m setLayer:l];
        
        
        [m setIcon:[[GeoliveServer SharedInstance] getDefaultIcon]];
        CLLocation *location=[self.locMan location];
        [m setLatlng:[location coordinate]];
        NSLog(@"Coordinate: %@", location);
        [m save];
        
        if([[self.attributes valueForKey:@"keywords"] count]){
            
            //[m setAttributesArray:self.attributes table:[StoredParameters GetObjectForKey:@"AttributeTable"]];
        }

        NSString *ID=[m getID];
        
        NSLog(@"%@",[m getID]);
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        [notification setHasAction:YES];
        
        NSString *title=@"untitled";
        if(![name isEqualToString:@""]){
            title=name;
        }
        
        [notification setAlertBody:[NSString stringWithFormat:@"Created Marker: %@, (%@)", title, ID]];
        [notification setAlertAction:@"Cool"];
        [notification setApplicationIconBadgeNumber:0];
        [notification setSoundName:UILocalNotificationDefaultSoundName];
        //UIApplication *a=((UIApplication *)[StoredParameters GetObjectForKey:@"Application"]);
  
        
        notification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        
        [self refreshUsersFeaturesList];
        
       // [a presentLocalNotificationNow:notification];
        
    }
    
    [self clearData];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UIViewController *vc=[segue destinationViewController];
    
    if([vc isKindOfClass:[FeatureViewController class]]){
        
        FeatureViewController *dvc=(FeatureViewController *)vc;
        [dvc setDelegate:self];
    
    }
    
    
    if([vc isKindOfClass:[FeatureDetailViewController class]]){
        
        FeatureDetailViewController *fvc=(FeatureDetailViewController *)vc;
        [fvc setMetadata:[_usersFeatures objectAtIndex:[_selectedFeaturePath row]]];
        
    }
    
    if([vc isKindOfClass:[MapViewController class]]){
        
        //MapViewController *mvc=(MapViewController *)vc;
        
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


-(void)refreshUsersFeaturesList{
    [self hideEmptyMessage];
    [self displayUpdatingMessage];
    
    MenuViewController *me=self;

    
    [[[GeoliveServer SharedInstance] getJson] queryTask:@"users_mapitem_list" WithJson:@{} completion:^(NSDictionary *result){
        NSLog(@"%@", result);
        if([result objectForKey:@"success"]&&[[result objectForKey:@"success"] boolValue]==true){
        
            
            _usersFeatures=[result objectForKey:@"results"];
            [me reloadCollection];
        
        }
    }];

    //[self performSelector:@selector(reloadCollection) withObject:nil afterDelay:10.0];
    
}

-(void)reloadCollection{
    
    //_usersFeatures=@[@"",@"",@"",@"",@""];
    [self hideUpdatingMessage];
    [self.collectionView reloadData];
}

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
    [self.updatingSpinner setHidden:false];
}
-(void)hideUpdatingMessage{
    [self.updatingLabel setHidden:true];
    [self.updatingSpinner setHidden:true];
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
    
    NSArray *images=[HTMLParser ParseImageUrls:[feature objectForKey:@"description"]];
    if([images count]){
    
        NSString *image=[images objectAtIndex:0];
        if([image rangeOfString:@"http" options:NSCaseInsensitiveSearch].location!=0){
            GeoliveServer *s=[GeoliveServer SharedInstance];
           image= [s.server stringByAppendingString:[@"/" stringByAppendingString:image]];
            
        }
        
        
        
        [ImageUtilities CachedImageFromUrl:image completion:^(UIImage *image){
           
            [fcell.imageView setImage: [ImageUtilities ThumbnailImage:image Width:200 AndHeight:200]];
        }];
    }
    
    
    NSString *icon=[feature objectForKey:@"icon"];
    
    if(icon&&(![icon isEqualToString:@""])){
        if([icon rangeOfString:@"http" options:NSCaseInsensitiveSearch].location!=0){
            GeoliveServer *s=[GeoliveServer SharedInstance];
            icon= [s.server stringByAppendingString:[@"/" stringByAppendingString:icon]];
            
        }
        
        
        [ImageUtilities CachedImageFromUrl:icon completion:^(UIImage *image){
            [fcell.placemarkView setImage:image];
        }];
    
    
    }
    
    
    return cell;

}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    _selectedFeaturePath=indexPath;
    return true;
}

- (IBAction)onMapButtonTap:(id)sender {
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
    UIViewController *myController = [storyboard instantiateInitialViewController];
    [self.navigationController pushViewController: myController animated:YES];
}
@end
