//
//  G6Protocol.h
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol G6OffersDelegate <NSObject>

/**
 * Called when a user has successfully completed an offer.
 * @param offer Details of the offer
 */
-(void) offerWasCompleted:(G6OfferDTO *)offer;

@end

@protocol G6UserAccountDelegate <NSObject>

/**
 * This is called when the user was successfully credited.
 * @param userId This is the unique id of the user in your application
 * @param transactionId The unique transaction id
 * @param amount The amount in this transaction
 */
- (void)creditUserSuccess:(NSString *)userId transactionId:(NSString *)transactionId amount:(float)amount;

/**
 * There was an error attempting to make this server call.  Please check
 * network availability, then contact G6 support
 * @param userId This is the unique id of the user in your application
 * @param transactionId The unique transaction id
 * @param amount The amount in this transaction
 */
- (void)creditUserFailure:(NSString *)userId transactionId:(NSString *)transactionId amount:(float)amount;

/**
 * This is called when the user was successfully debited.
 * @param userId This is the unique id of the user in your application
 * @param transactionId The unique transaction id
 * @param amount The amount in this transaction
 */
- (void)debitUserSuccess:(NSString *)userId transactionId:(NSString *)transactionId amount:(float)amount;

/**
 * There was an error attempting to make this server call.  Please check
 * network availability, then contact G6 support
 * @param userId This is the unique id of the user in your application
 * @param transactionId The unique transaction id
 * @param amount The amount in this transaction
 */
- (void)debitUserFailure:(NSString *)userId transactionId:(NSString *)transactionId amount:(float)amount;

/**
 * The user's balance was successfully retrieved from the server
 * @param userId This is the unique id of the user in your application
 * @param balance The current balance of the user
 */
- (void)getUserBalanceSuccess:(NSString *)userId balance:(float) balance;

/**
 * There was an error attempting to make this server call.  Please check
 * network availability, then contact G6 support
 * @param userId This is the unique id of the user in your application
 */
- (void)getUserBalanceFail:(NSString *)userId;

@end

@protocol G6TransactionDelegate <NSObject>

/**
 * Called when the server responds with the transactions for this user
 * @param userId This is the unique id of the user in your application
 * @param transactions Array of G6TransactionDTO.. The transactions for this user (in no particular order)
 */
- (void)getAllTransactionsSuccess:(NSString *)userId transactions:(NSArray *)transactions;

@optional
/**
 * There was an error attempting to make this server call.  Please check
 * network availability, then contact G6 support
 * @param userId This is the unique id of the user in your application
 */
- (void)getAllTransactionsFail:(NSString *)userId;

@end

