//
//  G6ResponseParser.m
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 Abaca Technology. All rights reserved.
//

#import "G6ResponseParser.h"


@implementation G6ResponseParser


+ (BOOL)verifySuccess:(NSString *)successString {
    return [successString isEqualToString:@"success"];
}

// userbalance:"192.60"
+ (NSNumber *)parseBalance:(NSString *)balanceString {
    
    NSArray *tokens = [balanceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                       
    if (tokens == nil || [tokens count] < 2) return nil;
    return [NSNumber numberWithFloat:[[tokens objectAtIndex:1] floatValue]];
}

+ (G6OfferDTO *)parseOffer:(NSString *)toParse {
    NSMutableString *parseable = [NSMutableString stringWithString:toParse];
	
	NSRange payout_p = [toParse rangeOfString:@"net_payout="];
	NSRange amount_p = [toParse rangeOfString:@":virtual_currency_amount="];
	NSRange offer_p = [toParse rangeOfString:@":offer_id="];
	NSRange user_p = [toParse rangeOfString:@":user_id="];
	NSRange balance_p = [toParse rangeOfString:@":user_balance="];
	NSRange signature_p = [toParse rangeOfString:@":signature="];
	
	NSString *payout = [parseable substringWithRange:NSMakeRange((payout_p.location + payout_p.length), (amount_p.location - (payout_p.location + payout_p.length)))];
	NSString *amount = [parseable substringWithRange:NSMakeRange((amount_p.location + amount_p.length), (offer_p.location - (amount_p.location + amount_p.length)))];
	NSString *offer = [parseable substringWithRange:NSMakeRange((offer_p.location + offer_p.length), (user_p.location - (offer_p.location + offer_p.length)))];
	NSString *user = [parseable substringWithRange:NSMakeRange((user_p.location + user_p.length), (balance_p.location - (user_p.location + user_p.length)))];
	NSString *balance = [parseable substringWithRange:NSMakeRange((balance_p.location + balance_p.length), (signature_p.location - (balance_p.location + balance_p.length)))];
	NSString *signature = [parseable substringWithRange:NSMakeRange((signature_p.location + signature_p.length),([toParse length] - (signature_p.location + signature_p.length)))];
	
    
    G6OfferDTO *dto = [[[G6OfferDTO alloc] init] autorelease];
    dto.netPayout = [payout floatValue];
    dto.userBalance = [balance floatValue];
    dto.virtualCurrencyAmount = [amount floatValue];
    dto.offerId = offer;
    dto.userId = user;
    
	NSMutableDictionary *toReturn = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									 payout, @"payout",
									 amount, @"amount",
									 offer, @"offer",
									 user, @"user",
									 balance, @"balance",
									 signature, @"signature",
									 nil];
	
    
    return dto;
    
}
@end
