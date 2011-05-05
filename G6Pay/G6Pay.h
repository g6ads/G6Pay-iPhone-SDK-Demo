//
//  G6Pay.h
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

#import "G6OfferDTO.h"
#import "G6Protocol.h"
#import "G6Params.h"
#import "G6ResponseParser.h"
#import "G6OfferViewController.h"

#define G6_VERSION 1.0

#define G6_DEFAULT_TIMEOUT  60
#define G6_DEFAULT_POLL_INTERVAL 30

@interface G6Pay : NSObject {
	
    NSMutableDictionary *requests;
    
    NSString *appId;
    NSString *secretKey;
    
    BOOL pollForCompletedOffers;
    float pollInterval;
    
    NSTimer *offersTimer;
}


+ (G6Pay *)initSDKWithAppId:(NSString *)appId andSecretKey:(NSString *)secretKey;

+ (G6Pay *)getG6Instance;


// Get the offers URL if you want to display the web view yourself
- (NSString *)getOffersURL:(NSString *)userId;

- (void)showOffers:(NSString *)userId
          delegate:(id<G6OffersDelegate>)delegate
            parent:(UIViewController *)parent
 showNavigationBar:(BOOL)showNavigationBar
navigationBarOnTop:(BOOL)navigationBarOnTop;

- (void)creditUser:(NSString *)transactionId
            userId:(NSString *)userId
            amount:(float)amount
          delegate:(id<G6UserAccountDelegate>)delegate;

- (void)debitUser:(NSString *)transactionId
           userId:(NSString *)userId
           amount:(float)amount
         delegate:(id<G6UserAccountDelegate>)delegate;

- (void)getUserBalance:(NSString *)userId
              delegate:(id<G6UserAccountDelegate>)delegate;

- (void)getAllTransactions:(NSString *)userId
                  delegate:(id<G6TransactionDelegate>)delegate;

- (void)installConfirm;

- (void)startOffersPoll:(NSString *)userId delegate:(id<G6OffersDelegate>)delegate;
- (void)stopOffersPoll;

@property (nonatomic) BOOL pollForCompletedOffers;
@property (nonatomic) float pollInterval;

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *secretKey;
@property (nonatomic, retain) NSTimer *offersTimer;

@end
