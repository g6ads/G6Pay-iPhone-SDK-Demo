//
//  G6OfferDTO.h
//  G6 Pay
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G6OfferDTO : NSObject {
    
    NSString *userId;
    NSString *offerId;
    NSString *offerName;
    float netPayout;
    float virtualCurrencyAmount;
    float userBalance;
    NSString *signature;
}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *offerId;
@property (nonatomic, copy) NSString *offerName;
@property (nonatomic) float netPayout;
@property (nonatomic) float virtualCurrencyAmount;
@property (nonatomic) float userBalance;
@property (nonatomic, copy) NSString *signature;

@end
