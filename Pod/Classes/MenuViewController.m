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







@property NSArray *usersFeatures;

@property NSIndexPath *selectedFeaturePath;

@property UIRefreshControl *refreshControl;

@property id<StyleProvider> styler;
@property id<MapFormDelegate> delegate;


@end

@implementation MenuViewController



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




-(void)viewDidAppear:(BOOL)animated{
    

    
}


-(void)displayForm{

    
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"UserForm" bundle:nil];
    UIViewController *myController = [storyboard instantiateInitialViewController];
    [((FeatureViewController *)myController) setDelegate:self];
    [self.navigationController pushViewController: myController animated:YES];

}


-(void)save{
    
   
}




-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UIViewController *vc=[segue destinationViewController];
    
    
    if([vc isKindOfClass:[FeatureDetailViewController class]]){
        
        FeatureDetailViewController *fvc=(FeatureDetailViewController *)vc;
        [fvc setMetadata:[_usersFeatures objectAtIndex:[_selectedFeaturePath row]]];
        
    }
    
}
- (IBAction)onPhotoClick:(id)sender {
    [self displayForm];
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

//Dynamic collectionview size to fit the most
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{


    int extra=((int)_collectionView.frame.size.width)%131;
    extra+=3;
    return UIEdgeInsetsMake(0, extra/2, 0, extra/2);
   

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

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [_collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark Bottom Bar Buttons

-(void)initBottomBar{
    
    return;
    
    //DEPRECATED;
    /*
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
    */

}




- (IBAction)onMapButtonTap:(id)sender {
    
    [_delegate menuForm:(MenuViewController *) self BottomBarButtonWasTappedAtIndex:0];
    
}
- (IBAction)onHelpTap:(id)sender {
    
    [_delegate menuFormHelpButtonWasTapped:(MenuViewController *) self];
    
}
@end
