//
//  Order.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/22/21.
//

#import "Order.h"
#import "Prescription.h"
@import CoreLocation;

@implementation Order

// Keys needed to process order
NSString* const NAME_KEY = @"name";
NSString* const TYPE_KEY = @"type";
NSString* const STATE_KEY = @"state";

NSString* const FULFILLMENT_KEY = @"fulfillments";
NSString* const QUANTITY_KEY = @"quantity";
NSString* const AMOUNT_KEY = @"amount";
NSString* const CURRENCY_KEY = @"currency";
NSString* const RECIPIENT_KEY = @"recipient";

NSString* const SHIPMENT_DETAILS_KEY= @"shipment_details";
// shipments values
NSString* const SHIPMENT_VALUE= @"SHIPMENT";
NSString* const PICKUP_VALUE= @"PICKUP";
NSString* const SHIPMENT_STATE_VALUE= @"PROPOSED";

NSString* const LINE_ITEMS_KEY = @"line_items";
NSString* const BASE_PRICE_MONEY_KEY = @"base_price_money";
NSString* const ITEM_TYPE_KEY = @"item_type";
NSString* const DISPLAY_NAME_KEY = @"display_name";


// F
-(instancetype) init {
    self = [super init];
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Key" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    
    self.location_id = [dict objectForKey:@"square_location_id"];
    self.object_id = [[[NSProcessInfo processInfo] globallyUniqueString] substringWithRange:NSMakeRange(0, 44)];
    self.line_items = [[NSMutableDictionary alloc] init];
    self.fullfillment = [[NSMutableDictionary alloc] init];
    
    [self setupShipping];
    return self;
}

-(void) buyPrescriptions:(NSMutableArray*) prescriptions{
    NSMutableArray *arrayOfPrescriptions = [[NSMutableArray alloc]init];
    for (Prescription *prescription in prescriptions) {
        NSMutableDictionary *dictionaryEntry = [[NSMutableDictionary alloc]init];
        [dictionaryEntry addEntriesFromDictionary:@{QUANTITY_KEY: [NSString stringWithFormat:@"%d", prescription.quantity]}];
        
        // Deals with amount
        NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
        
        
        [amount addEntriesFromDictionary:@{AMOUNT_KEY:[NSNumber numberWithFloat:[prescription.retrievePrice30 floatValue] * 100]}];
        [amount addEntriesFromDictionary:@{CURRENCY_KEY: @"USD"}];
        
        [dictionaryEntry addEntriesFromDictionary:@{BASE_PRICE_MONEY_KEY: amount}];
        [dictionaryEntry addEntriesFromDictionary:@{ITEM_TYPE_KEY: @"ITEM"}];
        [dictionaryEntry addEntriesFromDictionary:@{NAME_KEY: prescription.displayName}];
        
        [arrayOfPrescriptions addObject:dictionaryEntry];
    }
    [self.line_items addEntriesFromDictionary:@{LINE_ITEMS_KEY: arrayOfPrescriptions}];
}

-(void) setupShipping{ // Sets up the fullfillment dictionary
    PFUser *buyer = [PFUser currentUser];
    NSMutableArray *arrayForShipping = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dictionaryEntry = [[NSMutableDictionary alloc]init];
    [dictionaryEntry addEntriesFromDictionary:@{TYPE_KEY: SHIPMENT_VALUE}];
    [dictionaryEntry addEntriesFromDictionary:@{STATE_KEY: SHIPMENT_STATE_VALUE}];
    
    // Deals with shipment details
    NSMutableDictionary *shipmentDetails = [[NSMutableDictionary alloc] init];
    
    // Handles the details of the recipient
    NSMutableDictionary *recipientDetails = [[NSMutableDictionary alloc] init];
    [recipientDetails addEntriesFromDictionary:@{DISPLAY_NAME_KEY: buyer[@"name"]}]; // Bare minimum - can add address tho
    
    [shipmentDetails addEntriesFromDictionary:@{RECIPIENT_KEY: recipientDetails}];
    [dictionaryEntry addEntriesFromDictionary:@{SHIPMENT_DETAILS_KEY:shipmentDetails}];
    [arrayForShipping addObject:dictionaryEntry];
    
    [self.fullfillment addEntriesFromDictionary:@{FULFILLMENT_KEY: arrayForShipping}];
}

@end
