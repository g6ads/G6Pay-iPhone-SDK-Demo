//
//  G6Pay.m
//  G6_API
//

//  Copyright 2010 G6 Media. All rights reserved.
//

#import "G6Pay.h"

const NSString *secret_key=@"3754cc6199343d095.77764861";
const NSString *application_id=@"8";
const NSString *monetization_url=@"http://g6pay.com/api/buycurrency?app_id=";
const NSString *check_url=@"http://g6pay.com/api/iscompleted/app_id/";
const NSString *user_balance_url=@"http://g6pay.com/api/getuserbalance?app_id=";
const NSString *pay_per_install_url=@"http://g6pay.com/api/installconfirm?app_id=";
const NSString *credit_user_url=@"http://g6pay.com/api/credit?amount=";
const NSString *debit_user_url=@"http://g6pay.com/api/debit?amount=";

@implementation G6Pay

@synthesize connection, data, cur_signature, last_uid, last_offer_url, requestsAllowed;


-(void)track {
	

	NSString *appId = @"8";
	[self payPerInstall:appId];
	
}

/*
 This function generates a url which when loaded will display a list of available offers. It requires the users ID to be supplied.
 */
-(NSString *) displayOffers: (NSString *) userId
{
	NSString *timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
	NSString *toHash = [NSString stringWithFormat:@"%@%@%@%@",application_id, userId, timestamp, secret_key];
	NSString *hash = [self hashGen:toHash];
	
	self.cur_signature=hash;
	
	NSLog(@"%@",self.cur_signature);
	
	NSLog(@"%@",hash);
	NSString *url = [NSString stringWithFormat:@"%@%@&user_id=%@&timestamp=%@&signature=%@", monetization_url, application_id, userId, timestamp, hash];
	NSLog(@"%@", url);
	return url;
	
}
//Internal API function

-(NSString *) hashGen:(NSString*)input
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
/*
 Generates a URL to check to see whether or not the last offer has been completed, requires the users ID to be input 
 
 */
-(NSString *)offerCompleteUrl:(NSString *) uid
{
	NSString *offer_complete_url=[NSString stringWithFormat:@"%@%@%@",check_url,application_id,@"/signature/"];
	NSString *toHash = [NSString stringWithFormat:@"%@%@", self.cur_signature, secret_key];
	
	NSString *hash = [self hashGen:toHash];
	NSString *checkURL = [NSString stringWithFormat:@"%@%@%@%@", offer_complete_url,self.cur_signature,@"/signature2/",hash];
	self.last_offer_url=checkURL;
	return checkURL;
}

-(void)payPerInstall:(NSString *) referredapp{
	UIDevice *device = [UIDevice currentDevice];
	NSString *uniqueIdentifier = [device uniqueIdentifier];
	
	NSString* url = [NSString stringWithFormat:@"%@%@%@%@",pay_per_install_url,referredapp,@"&phone_id=",uniqueIdentifier];
	
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];	
	
}




-(void)checkOffer:(NSString *) userId{
	
	if(self.last_uid==nil){

		self.last_uid=userId;
	}
	
	if(self.last_offer_url==nil) { 

		[self offerCompleteUrl:userId];
	}
	self.data = nil;
	
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.last_offer_url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];	
	
}


-(void) creditUser:(NSString *) userId:(NSString *)amount {
	
	self.last_uid = userId;
	self.data = nil;
	NSString *timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
	NSString *toHash = [NSString stringWithFormat:@"%@%@%@%@%@%@", amount, timestamp, application_id, userId, timestamp, secret_key];
	NSString *hash = [self hashGen:toHash];
	
	NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", credit_user_url, amount, @"&credit_transaction_id=", timestamp, @"&app_id=", application_id, @"&user_id=", userId, @"&timestamp=", timestamp, @"&signature=", hash]; 
	
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}


-(void) debitUser:(NSString *) userId:(NSString *)amount {
	self.last_uid = userId;
	self.data = nil;
	NSString *timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
	NSString *toHash = [NSString stringWithFormat:@"%@%@%@%@%@%@", amount, timestamp, application_id, userId, timestamp, secret_key];
	NSString *hash = [self hashGen:toHash];
	
	
	NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@", debit_user_url, amount, @"&debit_transaction_id=", timestamp, @"&app_id=", application_id, @"&user_id=", userId, @"&timestamp=", timestamp, @"&signature=", hash];  
	
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
}


-(NSString *)checkUserBalance:(NSString *) userId {
	self.data = nil;
	NSString *timestamp = [NSString stringWithFormat:@"%d", (long)[[NSDate date] timeIntervalSince1970]];
	NSString *toHash = [NSString stringWithFormat:@"%@%@%@%@", application_id, userId, timestamp, secret_key];
	
	NSString *hash = [self hashGen:toHash];
	
	NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@", user_balance_url, application_id, @"&user_id=", userId, @"&timestamp=", timestamp, @"&signature=", hash];
	
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	//convert data to string
    NSString *balance= [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];

	return balance;
}

- (void)connection:(NSURLConnection *)theConnection	didReceiveData:(NSData *)incrementalData {
	
    if (self.data==nil) self.data = [[NSMutableData alloc] initWithCapacity:2048];
    [self.data appendData:incrementalData];

}

- (NSMutableDictionary *)parseCompleteOffer:(NSString *)toParse {
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
	
	NSMutableDictionary *toReturn = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
									 payout, @"payout",
									 amount, @"amount",
									 offer, @"offer",
									 user, @"user",
									 balance, @"balance",
									 signature, @"signature",
									 nil];
	
	return toReturn;
}
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	
	
	
	//ASCII Method
    NSString *result= [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
	
	NSLog(@"%@",result);
	

		/**
	if([result isEqualToString:@"pending"] && self.requestsAllowed){
		//Add your pending callback here
		[self checkOffer:self.last_uid];
		
	}

	if([result isEqualToString:@"invalid request"] && self.requestsAllowed){
		
		[self checkOffer:self.last_uid];
		
	}
	**/
	if([result hasPrefix:@"userbalance"] && self.requestsAllowed){
		
		NSString *numericValueOnly = [result substringFromIndex:12];
		NSString *numbericTrimQuotes = [numericValueOnly stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"balanceReceived" object:numbericTrimQuotes];
		
	}
	if([result hasPrefix:@"net_payout"]){
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"cpaActionComplete" object:[self parseCompleteOffer:result]];
	
	}
	if([result hasPrefix:@"success"]){
		

		
		[self checkUserBalance:last_uid];
		
	}
	self.data = nil;
}



@end
