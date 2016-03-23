//
//  MenuViewController.h
//  GeoFormsMappit
//
//  Created by Nick Blackwell on 2013-10-22.
//  Copyright (c) 2013 Nick Blackwell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MenuViewController : UIViewController<UINavigationControllerDelegate, CLLocationManagerDelegate , UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>







- (IBAction)onPhotoClick:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *emptyMsgLabel;
@property (weak, nonatomic) IBOutlet UIButton *emptyMsgUrl;

@property (weak, nonatomic) IBOutlet UILabel *updatingLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updatingSpinner;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;



@property (weak, nonatomic) IBOutlet UIButton *startNewFormButton;


@end
