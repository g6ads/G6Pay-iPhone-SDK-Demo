//
//  G6Pay.m
//  G6_API
//
//
//  Copyright 2010 G6 Media. All rights reserved.
//

#import "G6Pay.h"


G6Pay *_theInstance = nil;
BOOL initialized = NO;

@implementation G6Pay

@synthesize appId;
@synthesize secretKey;
@synthesize pollForCompletedOffers;
@synthesize pollInterval;
@synthesize offersTimer;

//Internal API function
+(NSString *) hashGen:(NSString*)input
{
	const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
	NSData *localdata = [NSData dataWithBytes:cstr length:input.length];
	uint8_t hashGen[CC_SHA256_DIGEST_LENGTH];
	CC_SHA256(localdata.bytes, localdata.length, hashGen);
	NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
	for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", hashGen[i]];
	
	return output;
	
}


- (id)init {
    self = [super init];
    
    if (self) {
        requests = [[NSMutableDictionary alloc] init];
        self.pollForCompletedOffers = NO;
        pollInterval = G6_DEFAULT_POLL_INTERVAL;
    }
    
    return self;
}


+ (id)initSDKWithAppId:(NSString *)appId andSecretKey:(NSString *)secretKey {
    if (_theInstance != nil) {
        [_theInstance release];
        _theInstance = nil;
    }
    
    _theInstance = [[G6Pay alloc] init];
    
    _theInstance.secretKey = secretKey;
    _theInstance.appId = appId;
    
    initialized = YES;
    
    NSLog(@"G6Pay SDK initialized");
    
    return _theInstance;
    
}

+ (G6Pay *)getG6Instance {
    if (_theInstance == nil)
        NSLog(@"G6Pay error - G6 instance not initialized.. Please call +(void)initSDKWithAppId::");
    
    return _theInstance;
}

#pragma mark Outgoing network calls 

+ (NSString *)keyForConnection:(NSURLConnection *)connection {
    return [NSString stringWithFormat:@"%ld", (long)connection];
}

+ (NSString *)constructSig:(NSArray *)sigParams 
                 secretKey:(NSString *)secretKey {
    
    NSMutableString *sigBuf = [NSMutableString string];
    
    for (int i=0; i<[sigParams count]; i+=2) {
        NSString *val = [sigParams objectAtIndex:i+1];
        if ([val isKindOfClass:NSNumber.class]) val = [((NSNumber *)val) stringValue];
        [sigBuf appendString:val];
    }
    
    [sigBuf appendString:secretKey];
    
    return [G6Pay hashGen:sigBuf];
    

}

+ (NSString *)constructURL:(NSString *)methodName
                 sigParams:(NSArray *)sigParams 
              nonsigParams:(NSArray *)nonsigParams 
                 secretKey:(NSString *)secretKey {
    
    // hash
    NSString *baseURL = nil;
    
    if ([methodName isEqualToString:G6_API_CALL_OFFERWALL]) {
        baseURL = G6_API_URL_OFFERWALL;
    } else if ([methodName isEqualToString:G6_API_CALL_ISCOMPLETED]) {
        baseURL = G6_API_URL_ISCOMPLETED;
    } else if ([methodName isEqualToString:G6_API_CALL_CREDIT]) {
        baseURL = G6_API_URL_CREDIT;
    } else if ([methodName isEqualToString:G6_API_CALL_DEBIT]) {
        baseURL = G6_API_URL_DEBIT;
    } else if ([methodName isEqualToString:G6_API_CALL_BALANCE]) {
        baseURL = G6_API_URL_BALANCE;
    } else if ([methodName isEqualToString:G6_API_CALL_TRANSACTIONS]) {
        baseURL = G6_API_URL_TRANSACTIONS;
    } else if ([methodName isEqualToString:G6_API_CALL_INSTALL]) {
        baseURL = G6_API_URL_INSTALLCONFIRM;
    }

    NSMutableString *sb = [baseURL mutableCopy];
    
    BOOL first = YES;
    BOOL hasSignature = NO;
    
    for (int i=0; i<[sigParams count]; i+=2) {
        
        NSString *key = [sigParams objectAtIndex:i];
        NSString *val = [sigParams objectAtIndex:i+1];
        if ([val isKindOfClass:NSNumber.class]) val = [((NSNumber *)val) stringValue];
        
        if (first)
            [sb appendString:@"?"];
        else
            [sb appendString:@"&"];
        [sb appendString:key];
        [sb appendString:@"="];
        
        [sb appendString:val];
     
        if ([[sigParams objectAtIndex:i] isEqualToString:@"signature"])
            hasSignature = YES;
        
        first = NO;
    }

    if (!hasSignature)
        [sb appendString:@"&signature="];
    else
        [sb appendString:@"&signature2="];
    
    [sb appendString:[self constructSig:sigParams secretKey:secretKey]];
    
    for (int i=0; i<[nonsigParams count]; i+=2) {
        NSString *key = [nonsigParams objectAtIndex:i];
        NSString *val = [nonsigParams objectAtIndex:i+1];
        if ([val isKindOfClass:NSNumber.class]) val = [((NSNumber *)val) stringValue];
        
        if (first)
            [sb appendString:@"?"];
        else
            [sb appendString:@"&"];
        [sb appendString:key];
        [sb appendString:@"="];
        
        [sb appendString:val];
        
    }
    
    return sb;
}

// using an array of tuples, because no ordered dictionary out of the box
- (void)makeCall:(NSString *)methodName
       sigParams:(NSArray *)sigParams
    nonsigParams:(NSArray *)nonsigParams
        delegate:(id)delegate {
    
    NSString *url = [G6Pay constructURL:methodName
                              sigParams:sigParams
                           nonsigParams:nonsigParams
                              secretKey:secretKey];
    
    NSLog(@"*** G6Pay url %@", url);
    
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                         timeoutInterval:G6_DEFAULT_TIMEOUT];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];	

    NSMutableData *data = [[NSMutableData alloc] init];
    
    if (delegate == nil)
        delegate = [NSNull null];
    
    NSMutableDictionary *thisConnection = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    connection, @"_connection",
                                    methodName, @"_methodName",
                                    data, @"_data",
                                    delegate, @"_delegate",
                                    nil];
    
    // add params to the dictionary..
    for (int i=0; i < [sigParams count]; i+=2 ) {
        // aaah - ugly - be careful
        [thisConnection setObject:[sigParams objectAtIndex:i+1]
                           forKey:[sigParams objectAtIndex:i]];
    }
    if (nonsigParams != nil) {
        for (int i=0; i < [nonsigParams count]; i+=2 ) {
            // aaah - ugly - be careful
            [thisConnection setObject:[nonsigParams objectAtIndex:i+1]
                               forKey:[nonsigParams objectAtIndex:i]];
        }
    }
    
    [requests setObject:thisConnection forKey:[G6Pay keyForConnection:connection]];
    
    [connection release];
    [data release];
    
    
}

#pragma mark NSURLConnection callbacks

// Handle any errors and call the appropriate callback
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSString *key = [G6Pay keyForConnection:connection];
    NSDictionary *thisConnection = [requests objectForKey:key];
	
    if (thisConnection != nil) {
        
        
        id delegate = [thisConnection objectForKey:@"_delegate"];
        if ([delegate isKindOfClass:NSNull.class])
            delegate = nil;
        
        NSString *methodName = [thisConnection objectForKey:@"_methodName"];
        
        if ([methodName isEqualToString:G6_API_CALL_OFFERWALL]) {
            
        } else if ([methodName isEqualToString:G6_API_CALL_ISCOMPLETED]) {
            
        } else if ([methodName isEqualToString:G6_API_CALL_CREDIT]) {
            if (delegate != nil) {
                id<G6UserAccountDelegate>d = delegate;
                [d creditUserFailure:[thisConnection objectForKey:G6_PARAM_USER_ID]
                       transactionId:[thisConnection objectForKey:G6_PARAM_CREDIT_TRANSACTION_ID]
                              amount:[[thisConnection objectForKey:G6_PARAM_AMOUNT] floatValue]];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_CREDIT_USER_FAIL
             object:nil];
            
        } else if ([methodName isEqualToString:G6_API_CALL_DEBIT]) {
            if (delegate != nil) {
                id<G6UserAccountDelegate>d = delegate;
                [d debitUserFailure:[thisConnection objectForKey:G6_PARAM_USER_ID]
                      transactionId:[thisConnection objectForKey:G6_PARAM_DEBIT_TRANSACTION_ID]
                             amount:[[thisConnection objectForKey:G6_PARAM_AMOUNT] floatValue]];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_DEBIT_USER_FAIL
             object:nil];
        } else if ([methodName isEqualToString:G6_API_CALL_BALANCE]) {
            if (delegate != nil) {
                id<G6UserAccountDelegate>d = delegate;
                [d getUserBalanceFail:[thisConnection objectForKey:G6_PARAM_USER_ID]];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_USER_BALANCE_FAIL
             object:nil];
        } else if ([methodName isEqualToString:G6_API_CALL_TRANSACTIONS]) {
            if (delegate != nil) {
                id<G6TransactionDelegate>d = delegate;
                [d getAllTransactionsFail:[thisConnection objectForKey:G6_PARAM_USER_ID]];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_GET_TRANSACTIONS_FAIL
             object:nil];
        } else if ([methodName isEqualToString:G6_API_CALL_INSTALL]) {
            
        }

        // clean up
        [requests removeObjectForKey:key];
    }

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData {
    
    NSString *key = [G6Pay keyForConnection:connection];
    NSDictionary *thisConnection = [requests objectForKey:key];
	
    if (thisConnection != nil) {
        
        NSMutableData *data = [thisConnection objectForKey:@"_data"];
        [data appendData:incrementalData];
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
	
    NSString *key = [G6Pay keyForConnection:connection];
    NSDictionary *thisConnection = [requests objectForKey:key];
	
    if (thisConnection != nil) {
	
        NSMutableData *data = [thisConnection objectForKey:@"_data"];
        
        NSString *response = [[NSString alloc] initWithData:data
                                                  encoding:NSASCIIStringEncoding];
        
        id delegate = [thisConnection objectForKey:@"_delegate"];
        if ([delegate isKindOfClass:NSNull.class])
            delegate = nil;
        
        NSString *methodName = [thisConnection objectForKey:@"_methodName"];

        NSLog(@"Connection finished %@ %@", methodName, response);
        // handle the response..
        
        if ([methodName isEqualToString:G6_API_CALL_OFFERWALL]) {
            
        } else if ([methodName isEqualToString:G6_API_CALL_ISCOMPLETED]) {
            G6OfferDTO *dto = [G6ResponseParser parseOffer:response];
            
            if (dto == nil) {
                [self connection:connection didFailWithError:nil];
                return;
            }
            
            if (delegate != nil) {
                id<G6OffersDelegate>d = delegate;
                [d offerWasCompleted:dto];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_OFFER_COMPLETED
             object:dto];

        } else if ([methodName isEqualToString:G6_API_CALL_CREDIT]) {
            BOOL succeeded = [G6ResponseParser verifySuccess:response];
            
            if (!succeeded) {
                [self connection:connection didFailWithError:nil];
                return;
            }
            
            if (delegate != nil) {
                id<G6UserAccountDelegate>d = delegate;
                [d creditUserSuccess:[thisConnection objectForKey:G6_PARAM_USER_ID]
                       transactionId:[thisConnection objectForKey:G6_PARAM_CREDIT_TRANSACTION_ID]
                              amount:[[thisConnection objectForKey:G6_PARAM_AMOUNT] floatValue]];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_CREDIT_USER_SUCCESS
             object:[thisConnection objectForKey:G6_PARAM_CREDIT_TRANSACTION_ID]];
            
        } else if ([methodName isEqualToString:G6_API_CALL_DEBIT]) {
            BOOL succeeded = [G6ResponseParser verifySuccess:response];
            
            if (!succeeded) {
                [self connection:connection didFailWithError:nil];
                return;
            }
            
            if (delegate != nil) {
                id<G6UserAccountDelegate>d = delegate;
                [d debitUserSuccess:[thisConnection objectForKey:G6_PARAM_USER_ID]
                       transactionId:[thisConnection objectForKey:G6_PARAM_DEBIT_TRANSACTION_ID]
                              amount:[[thisConnection objectForKey:G6_PARAM_AMOUNT] floatValue]];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_DEBIT_USER_SUCCESS
             object:[thisConnection objectForKey:G6_PARAM_DEBIT_TRANSACTION_ID]];
        } else if ([methodName isEqualToString:G6_API_CALL_BALANCE]) {
            NSNumber *balance = [G6ResponseParser parseBalance:response];
            
            if (balance == nil) {
                [self connection:connection didFailWithError:nil];
                return;
            }
            
            if (delegate != nil) {
                id<G6UserAccountDelegate>d = delegate;
                [d getUserBalanceSuccess:[thisConnection objectForKey:G6_PARAM_USER_ID]
                                 balance:[balance floatValue]];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_USER_BALANCE_SUCCESS
             object:balance];
        } else if ([methodName isEqualToString:G6_API_CALL_TRANSACTIONS]) {
            NSArray *transactions = [G6ResponseParser parseTransactions:response];
            
            if (transactions == nil) {
                [self connection:connection didFailWithError:nil];
                return;
            }
            
            if (delegate != nil) {
                id<G6TransactionDelegate>d = delegate;
                [d getAllTransactionsSuccess:[thisConnection objectForKey:G6_PARAM_USER_ID]
                                transactions:transactions];
            }
            [[NSNotificationCenter defaultCenter]
             postNotificationName:G6_NOTIFICATION_GET_TRANSACTIONS_SUCCESS
             object:transactions];
        } else if ([methodName isEqualToString:G6_API_CALL_INSTALL]) {
            
        }

        // clean up
        [requests removeObjectForKey:key];
    }
	

}


#pragma mark Public methods

- (NSDictionary *)getOffersURLAndSignature:(NSString *)userId {
    
    NSArray *sigParams = [NSArray arrayWithObjects:
                          G6_PARAM_APP_ID, appId,
                          G6_PARAM_USER_ID, userId,
                          G6_PARAM_TIMESTAMP, [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]],
                          nil];
    
    NSArray *nonsigParams = [NSArray arrayWithObjects:
                             G6_PARAM_UDID, [[UIDevice currentDevice] uniqueIdentifier],
                             nil];

    NSString *url = [G6Pay constructURL:G6_API_CALL_OFFERWALL
                              sigParams:sigParams
                           nonsigParams:nonsigParams
                              secretKey:secretKey];

    NSString *sig = [G6Pay constructSig:sigParams secretKey:secretKey];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            url, @"url",
            sig, @"signature",
            nil];
}

- (NSString *)getOffersURL:(NSString *)userId {
    return [[self getOffersURLAndSignature:userId] objectForKey:@"url"];
}

- (void)showOffers:(NSString *)userId
          delegate:(id<G6OffersDelegate>)delegate
            parent:(UIViewController *)parent
 showNavigationBar:(BOOL)showNavigationBar 
navigationBarOnTop:(BOOL)navigationBarOnTop {
    
    NSDictionary *urlAndSig = [self getOffersURLAndSignature:userId];
    NSString *url = [urlAndSig objectForKey:@"url"];
    NSString *signature = [urlAndSig objectForKey:@"signature"];
    
    NSLog(@"G6Pay offers URL: %@", url);
    NSLog(@"G6Pay offers signature: %@", signature);
    
    G6OfferViewController *vc = [[G6OfferViewController alloc] initWithURL:url
                                                              andSignature:signature
                                                         andOffersDelegate:delegate
                                                             andG6Instance:self];
    
    vc.showNavBar = showNavigationBar;
    vc.navBarOnTop = navigationBarOnTop;
    vc.offersDelegate = delegate;
    
    [parent presentModalViewController:vc animated:YES];
}


- (void)creditUser:(NSString *)transactionId
            userId:(NSString *)userId
            amount:(float)amount
          delegate:(id<G6UserAccountDelegate>)delegate {
    
    if (!initialized) {
        NSLog(@"G6Pay error - G6 instance not initialized.. Please call +(void)initSDKWithAppId::");
        return;
    }

    NSArray *sigParams = [NSArray arrayWithObjects:
                          G6_PARAM_AMOUNT, [NSNumber numberWithFloat:amount],
                          G6_PARAM_CREDIT_TRANSACTION_ID, transactionId,
                          G6_PARAM_APP_ID, appId,
                          G6_PARAM_USER_ID, userId,
                          G6_PARAM_TIMESTAMP, [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]],
                          nil];
    
    [self makeCall:G6_API_CALL_CREDIT
         sigParams:sigParams
      nonsigParams:nil
          delegate:delegate];
}

- (void)debitUser:(NSString *)transactionId
           userId:(NSString *)userId
           amount:(float)amount
         delegate:(id<G6UserAccountDelegate>)delegate {
    
    if (!initialized) {
        NSLog(@"G6Pay error - G6 instance not initialized.. Please call +(void)initSDKWithAppId::");
        return;
    }

    NSArray *sigParams = [NSArray arrayWithObjects:
                          G6_PARAM_AMOUNT, [NSNumber numberWithFloat:amount],
                          G6_PARAM_DEBIT_TRANSACTION_ID, transactionId,
                          G6_PARAM_APP_ID, appId,
                          G6_PARAM_USER_ID, userId,
                          G6_PARAM_TIMESTAMP, [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]],
                          nil];
    
    [self makeCall:G6_API_CALL_DEBIT
         sigParams:sigParams
      nonsigParams:nil
          delegate:delegate];
}

- (void)getUserBalance:(NSString *)userId
              delegate:(id<G6UserAccountDelegate>)delegate {
 
    if (!initialized) {
        NSLog(@"G6Pay error - G6 instance not initialized.. Please call +(void)initSDKWithAppId::");
        return;
    }
    
    NSArray *sigParams = [NSArray arrayWithObjects:
                          G6_PARAM_APP_ID, appId,
                          G6_PARAM_USER_ID, userId,
                          G6_PARAM_TIMESTAMP, [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]],
                          nil];
    
    [self makeCall:G6_API_CALL_BALANCE
         sigParams:sigParams
      nonsigParams:nil
          delegate:delegate];
}

- (void)getAllTransactions:(NSString *)userId
                  delegate:(id<G6TransactionDelegate>)delegate {
    if (!initialized) {
        NSLog(@"G6Pay error - G6 instance not initialized.. Please call +(void)initSDKWithAppId::");
        return;
    }

    NSArray *sigParams = [NSArray arrayWithObjects:
                          G6_PARAM_APP_ID, appId,
                          G6_PARAM_USER_ID, userId,
                          G6_PARAM_TIMESTAMP, [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]],
                          nil];
    
    [self makeCall:G6_API_CALL_TRANSACTIONS
         sigParams:sigParams
      nonsigParams:nil
          delegate:delegate];

}

- (void)installConfirm {
    if (!initialized) {
        NSLog(@"G6Pay error - G6 instance not initialized.. Please call +(void)initSDKWithAppId::");
        return;
    }

    NSArray *sigParams = [NSArray arrayWithObjects:
                          G6_PARAM_APP_ID, appId,
                          G6_PARAM_PHONE_ID, [[UIDevice currentDevice] uniqueIdentifier],
                          nil];
    
    [self makeCall:G6_API_CALL_INSTALL
         sigParams:sigParams
      nonsigParams:nil
          delegate:nil];
    
}


- (void)checkOffers:(NSString *)signature delegate:(id<G6OffersDelegate>)delegate {
    NSArray *sigParams = [NSArray arrayWithObjects:
                          G6_PARAM_APP_ID, appId,
                          G6_PARAM_SIGNATURE, signature,
                          nil];
    
    [self makeCall:G6_API_CALL_ISCOMPLETED
         sigParams:sigParams
      nonsigParams:nil
          delegate:delegate];
}

- (void)checkOffers:(NSTimer *)timer {
    if (timer != nil && timer.userInfo != nil) {
        [self checkOffers:[timer.userInfo objectForKey:@"signature"]
                 delegate:[timer.userInfo objectForKey:@"delegate"]];
    }
}


- (void)stopOffersPoll {
    [offersTimer invalidate];
    self.offersTimer = nil;
}

- (void)startOffersPoll:(NSString *)signature
               delegate:(id<G6OffersDelegate>)delegate {
    
    if (pollForCompletedOffers) {
        
        if (offersTimer != nil) {
            [offersTimer invalidate];
            self.offersTimer = nil;
        }
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  signature, @"signature",
                                  delegate, @"delegate",
                                  nil];
        
        NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                  interval:pollInterval
                                                    target:self
                                                  selector:@selector(checkOffers:)
                                                  userInfo:userInfo
                                                   repeats:YES];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
        
        self.offersTimer = timer;

        // Start up the polling..
        
    }
}


- (void)dealloc {
    [appId release];
    [secretKey release];
    [requests release];
    [offersTimer release];
    
    [super dealloc];
}

@end
