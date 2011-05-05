//
//  G6ResponseParser.m
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import "G6ResponseParser.h"
#import "G6Params.h"


#define DTO_USER_ID              @"user_id"
#define DTO_OFFER_ID             @"offer_id"
#define DTO_OFFER_NAME           @"offer_name"
#define DTO_NET_PAYOUT           @"net_payout"
#define DTO_VIR_CUR_AMT          @"virtual_currency_amount"
#define DTO_DATE                 @"date"
#define DTO_DESC                 @"description"
#define DTO_USER_BALANCE         @"user_balance"
#define DTO_SIGNATURE            @"signature"

@implementation G6ResponseParser


+ (BOOL)verifySuccess:(NSString *)successString {
    return [successString isEqualToString:@"success"];
}

// userbalance:"192.60"
+ (NSNumber *)parseBalance:(NSString *)balanceString {
    
    @try {
        NSArray *tokens = [[balanceString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsSeparatedByString:@":"];
        if (tokens == nil && [tokens count] > 0) {
            if (![[tokens objectAtIndex:0] isEqualToString:@"userbalance"])
                return nil;
        }
    }
    @catch (NSException *ex) {
        return nil;
    }
    
    NSArray *tokens = [balanceString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                       
    if (tokens == nil || [tokens count] < 2) return nil;
    return [NSNumber numberWithFloat:[[tokens objectAtIndex:1] floatValue]];
}

+ (G6OfferDTO *)parseOffer:(NSString *)body {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    @try {
        NSArray *tokens = [[body stringByTrimmingCharactersInSet:
                            [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                           componentsSeparatedByString:@":"];
        
        for (NSString *keyVal in tokens) {
            NSArray *keyValList = [keyVal componentsSeparatedByString:@"="];
            
            NSString *key = [keyValList objectAtIndex:0];
            NSString *val = [keyValList objectAtIndex:1];
            
            [dict setObject:val forKey:key];
        }
        
        G6OfferDTO *dto = [[[G6OfferDTO alloc] init] autorelease];
        dto.netPayout = [[dict objectForKey:G6_PARAM_NET_PAYOUT] floatValue];
        dto.userBalance = [[dict objectForKey:G6_PARAM_USER_BALANCE] floatValue];
        dto.virtualCurrencyAmount = [[dict objectForKey:G6_PARAM_CURRENCY] floatValue];
        dto.offerId = [dict objectForKey:G6_PARAM_OFFER_ID];
        dto.offerName = [dict objectForKey:G6_PARAM_OFFER_NAME];
        dto.userId = [dict objectForKey:G6_PARAM_USER_ID];
        dto.signature = [dict objectForKey:G6_PARAM_SIGNATURE];
        
        return dto;
    }
    @catch (NSException *ex) {
        return nil;
    }
}

+ (G6TransactionDTO *)transactionFromDict:(NSDictionary *)dict {
    
    
    G6TransactionDTO *dto = [[[G6TransactionDTO alloc] init] autorelease];
    NSString *key;
    
    key = DTO_USER_ID;
    if ([dict objectForKey:key] != nil) {
        dto.userId = [dict objectForKey:key];
    }
    
    key = DTO_OFFER_ID;
    if ([dict objectForKey:key] != nil) {
        dto.offerId = [dict objectForKey:key];
    }
    
    key = DTO_OFFER_NAME;
    if ([dict objectForKey:key] != nil) {
        dto.offerName = [dict objectForKey:key];
    }
    
    key = DTO_NET_PAYOUT;
    if ([dict objectForKey:key] != nil) {
        dto.netPayout = [[dict objectForKey:key] floatValue];
    }
    
    key = DTO_VIR_CUR_AMT;
    if ([dict objectForKey:key] != nil) {
        dto.virtualCurrencyAmount = [[dict objectForKey:key] floatValue];
    }
    
    key = DTO_DATE;
    if ([dict objectForKey:key] != nil) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        
        @try {
            [format setDateFormat:@"yyyy-MM-dd' 'HH:mm:ss"];
            NSDate *parsed = [format dateFromString:[dict objectForKey:key]];
            dto.date = parsed;
        }
        @catch (NSException* ex) {
            
        }

        [format release];
        
    }
    
    key = DTO_DESC;
    if ([dict objectForKey:key] != nil) {
        dto.description = [dict objectForKey:key];
    }
    
    return dto;
}

+ (NSArray *)parseTransactions:(NSString *)body {
    @try {
        NSMutableArray *result = [NSMutableArray array];
        
        body = [body stringByTrimmingCharactersInSet:
                [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // chop the [ and ]
        NSString *listOfDicts = [[body substringToIndex:[body length]-1] substringFromIndex:1];
        
        NSMutableString *keyBuf = [NSMutableString string];
        NSMutableString *valBuf = [NSMutableString string];
        
        BOOL valueIsNum = NO;
        BOOL valueIsNull = NO;
        
        NSString *key = nil;
        NSString *val = nil;
        int state = 0;
        int oldState = state;
        // 0 = new dto
        // 1 = pre-key
        // 2 = key
        // 3 = between key/val
        // 4 = pre-val
        // 5 = val
        // 6 = finished val
        char oldC = '0';
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < [listOfDicts length]; i++) {
            char c = [listOfDicts characterAtIndex:i];
            
            if (oldState != state) {
                //NSLog(@"G6Pay State changed to %d", state);
            }
            oldState = state;
            
            switch (state) {
                case 0: // new DTO
                    // reset everything
                    valueIsNum = NO;
                    valueIsNull = NO;
                    keyBuf = [NSMutableString string];
                    valBuf = [NSMutableString string];
                    key = nil;
                    val = nil;
                    dict = [NSMutableDictionary dictionary];
                    
                    if (c == '{')
                        state++;
                    break;
                case 1: // pre-key
                    if (c == '"')
                        state++;
                    break;
                case 2: // key
                    if (c == '"') {
                        state++;
                        key = keyBuf;
                    } else {
                        [keyBuf appendFormat:@"%c",c];
                    }
                    break;
                case 3: // between key and value
                    if (c == ':')
                        state++;
                    break;
                case 4: // pre-val
                    if (c >= '0' && c <= '9' || c == '-' || c == '.') {
                        valueIsNum = YES;
                        [valBuf appendFormat:@"%c",c];
                        state++;
                    }
                    if (c == 'n') {
                        valueIsNull = YES;
                        state++;
                    }
                    if (c == '"') {
                        valueIsNum = NO;
                        valueIsNull = NO;
                        state++;
                    }
                    break;
                case 5: // val
                    ;
                    BOOL nextState = NO;
                    if (valueIsNum) {
                        if (c >= '0' && c <= '9' || c == '-' || c == '.') {
                            [valBuf appendFormat:@"%c",c];
                        } else {
                            // we decrement, because we're on a char we
                            // don't understand
                            i--;
                            nextState = YES;
                        }
                    } else if (valueIsNull) {
                        if (c == 'n' || c == 'u' || c =='l') {
                            // still null
                        } else {
                            // we decrement, because we're on a char we
                            // don't understand
                            i--;
                            nextState = YES;
                        }
                    } else {
                        if (c == '"' && oldC != '\\') {
                            nextState = YES;
                        } else {
                            [valBuf appendFormat:@"%c",c];
                        }
                    }
                    if (nextState) {
                        
                        if (!valueIsNull) {
                            val = valBuf;
                            [dict setObject:[val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                     forKey:[key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                        }
                        
                        state++;
                        keyBuf = [NSMutableString string];
                        valBuf = [NSMutableString string];
                    }
                    break;
                case 6: // post-val
                    if (c == ',')
                        state = 1; // pre-key
                    if (c == '}') {
                        // we've wrapped up another DTO, phew
                        [result addObject:[G6ResponseParser transactionFromDict:dict]];
                        state = 0; // pre-dto
                    }
                    break;
                default:
                    break;
            }
            oldC = c;
        }
        
        return result; 
    }
    @catch (NSException* ex) {
        NSLog(@"G6Pay exception parsing response");
        return nil;
    }
}


@end
