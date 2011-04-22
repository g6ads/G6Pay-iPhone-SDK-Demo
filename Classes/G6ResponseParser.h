//
//  G6ResponseParser.h
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G6OfferDTO.h"
#import "G6TransactionDTO.h"

@interface G6ResponseParser : NSObject {
    
}

+ (G6OfferDTO *)parseOffer:(NSString *)offerString;
+ (BOOL)verifySuccess:(NSString *)successString;
+ (NSArray *)parseTransactions:(NSString *)transactionString;
+ (NSNumber *)parseBalance:(NSString *)balanceString;

@end
