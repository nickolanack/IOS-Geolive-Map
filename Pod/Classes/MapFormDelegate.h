
//
//  Created by Nick Blackwell on 2013-07-25.
//
//

#import <Foundation/Foundation.h>
#import "FeatureCell.h"
//#import <UIKit/UIKit.h>


@protocol MapFormDelegate <NSObject>

-(void)saveForm:(NSDictionary *) data withCompletion:(void (^)(NSDictionary * response)) completion;

-(void)saveForm:(NSDictionary *) data withImage:(UIImage *) image withProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion;
-(void)saveForm:(NSDictionary *) data withVideo:(NSURL *) video withProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion;



-(void)uploadImage:(UIImage *) image withProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion;
-(void)uploadVideo:(NSURL *) video withProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion;


-(void)storeFormData:(NSDictionary *)data forForm:(NSString *) name withCompletion:(void (^)(NSDictionary * response)) completion;

-(void)listUsersMenuItemsWithCompletion:(void (^)(NSArray * results)) completion;
-(void)formatMenuItemsCell:(FeatureCell *)cell withData:(NSDictionary *)data;

@optional

@end
