//
//  G6TransactionDTO.m
//  G6 Pay
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import "G6TransactionDTO.h"


@implementation G6TransactionDTO

@synthesize userId;
@synthesize offerId;
@synthesize offerName;
@synthesize netPayout;
@synthesize virtualCurrencyAmount;
@synthesize date;
@synthesize description;


- (void)dealloc {
    [userId release];
    [offerId release];
    [offerName release];
    [date release];
    [description release];
    
    [super dealloc];
}
@end
