//
//  G6TransactionDTO.h
//  G6 Pay
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G6TransactionDTO : NSObject {
    
    NSString *userId;
    NSString *offerId;
    NSString *offerName;
    float netPayout;
    float virtualCurrencyAmount;
    NSDate *date;
    NSString *description;

}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *offerId;
@property (nonatomic, copy) NSString *offerName;
@property (nonatomic) float netPayout;
@property (nonatomic) float virtualCurrencyAmount;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSString *description;

@end
