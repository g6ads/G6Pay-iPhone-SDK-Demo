//
//  G6OfferDTO.m
//  G6 Pay
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import "G6OfferDTO.h"

@implementation G6OfferDTO

@synthesize userId;
@synthesize offerId;
@synthesize offerName;
@synthesize netPayout;
@synthesize virtualCurrencyAmount;
@synthesize userBalance;
@synthesize signature;


- (void)dealloc {
    [userId release];
    [offerId release];
    [offerName release];
    [signature release];
    
    [super dealloc];
}
@end
