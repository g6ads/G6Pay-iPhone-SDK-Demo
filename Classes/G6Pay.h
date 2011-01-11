//
//  G6Pay.h
//  G6_API
//
//  Created by Rangel Spasov on 10/4/10.
//  Copyright 2010 G6 Media. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>


@interface G6Pay : NSObject {
	NSURLConnection *connection;
	NSMutableData* data;
	
	NSString *cur_signature;
	NSString *last_offer_url;
	NSString *last_uid;
	BOOL requestsAllowed;
}




//-(void)FetchHTMLCode:(NSString *)url;
-(NSString *) displayOffers: (NSString *) userId;


@property (retain) NSURLConnection *connection;
@property (retain) NSMutableData* data;
@property (retain) NSString *cur_signature;
@property (retain) NSString *last_offer_url;
@property (retain) NSString *last_uid;
@property BOOL requestsAllowed;

@end
