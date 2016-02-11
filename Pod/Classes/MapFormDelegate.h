
//
//  Created by Nick Blackwell on 2013-07-25.
//
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>


@protocol MapFormDelegate <NSObject>



-(void)uploadImage:(UIImage *) image withProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion;
-(void)uploadVideo:(NSURL *) video withProgressHandler:(void (^)(float percentFinished)) progress andCompletion:(void (^)(NSDictionary * response)) completion;


-(void)storeFormData:(NSDictionary *)data forForm:(NSString *) name withCompletion:(void (^)(NSDictionary * response)) completion;

@optional

@end
