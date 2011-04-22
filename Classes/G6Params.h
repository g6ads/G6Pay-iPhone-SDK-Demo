//
//  G6Params.h
//  G6 Pay SDK
//
//  Created by Peter Hsu on 4/20/11.
//  Copyright 2011 G6 Media. All rights reserved.
//

#import <Foundation/Foundation.h>

#define G6_NOTIFICATION_OFFER_COMPLETED           @"g6OfferCompleted"
#define G6_NOTIFICATION_DEBIT_USER_SUCCESS        @"g6DebitUserSuccess"
#define G6_NOTIFICATION_DEBIT_USER_FAIL           @"g6DebitUserFail"
#define G6_NOTIFICATION_CREDIT_USER_SUCCESS       @"g6CreditUserSuccess"
#define G6_NOTIFICATION_CREDIT_USER_FAIL          @"g6CreditUserFail"
#define G6_NOTIFICATION_USER_BALANCE_SUCCESS      @"g6UserBalanceSuccess"
#define G6_NOTIFICATION_USER_BALANCE_FAIL         @"g6UserBalanceFail"
#define G6_NOTIFICATION_GET_TRANSACTIONS_SUCCESS  @"g6GetTransactionSuccess"
#define G6_NOTIFICATION_GET_TRANSACTIONS_FAIL     @"g6GetTransactionFail"

#define G6_API_CALL_OFFERWALL           @"offerwall"
#define G6_API_CALL_ISCOMPLETED         @"iscompleted"
#define G6_API_CALL_CREDIT              @"credit"
#define G6_API_CALL_DEBIT               @"debit"
#define G6_API_CALL_BALANCE             @"balance"
#define G6_API_CALL_TRANSACTIONS        @"transactions"
#define G6_API_CALL_INSTALL             @"install"

#define G6_API_URL_INSTALLCONFIRM       @"http://www.g6pay.com/api/installconfirm"

#define G6_API_URL_OFFERWALL            @"http://www.g6pay.com/api/buycurrency"
#define G6_API_URL_ISCOMPLETED          @"http://www.g6pay.com/api/iscompleted"

#define G6_API_URL_CREDIT               @"http://www.g6pay.com/api/credit"
#define G6_API_URL_DEBIT                @"http://www.g6pay.com/api/debit"
#define G6_API_URL_BALANCE              @"http://www.g6pay.com/api/getuserbalance"

#define G6_API_URL_TRANSACTIONS         @"http://www.g6pay.com/api/getalltransactions"

#define ANDROID_MANIFEST_APP_ID         @"G6_APP_ID"
#define ANDROID_MANIFEST_SECRET_KEY     @"G6_SECRET_KEY"

#define G6_PARAM_APP_ID                 @"app_id"
#define G6_PARAM_SECRET_KEY             @"secret_key"
#define G6_PARAM_UDID                   @"udid"
#define G6_PARAM_PHONE_ID               @"phone_id"
#define G6_PARAM_USER_ID                @"user_id"
#define G6_PARAM_OFFER_ID               @"offer_id"
#define G6_PARAM_OFFER_NAME             @"offer_name"
#define G6_PARAM_NET_PAYOUT             @"net_payout"
#define G6_PARAM_CURRENCY               @"virtual_currency_amount"
#define G6_PARAM_DATE                   @"date"
#define G6_PARAM_DESCRIPTION            @"description"
#define G6_PARAM_USER_BALANCE           @"user_balance"
#define G6_PARAM_SIGNATURE              @"signature"
#define G6_PARAM_TIMESTAMP              @"timestamp"
#define G6_PARAM_PLATFORM               @"platform"
#define G6_PARAM_CREDIT_TRANSACTION_ID  @"credit_transaction_id"
#define G6_PARAM_DEBIT_TRANSACTION_ID   @"debit_transaction_id"
#define G6_PARAM_AMOUNT                 @"amount"