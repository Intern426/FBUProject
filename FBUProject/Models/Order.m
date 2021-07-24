//
//  Order.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/22/21.
//

#import "Order.h"
#import "Prescription.h"

@implementation Order

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

-(void) buyPrescription:(NSMutableArray*) prescriptions quantity:(NSString *) quantity{
    NSMutableArray *arrayOfPrescriptions = [[NSMutableArray alloc]init];
    for (Prescription *prescription in prescriptions) {
        NSMutableDictionary *dictionaryEntry = [[NSMutableDictionary alloc]init];
        [dictionaryEntry addEntriesFromDictionary:@{@"quantity": quantity}];
        
        // Deals with amount
        NSMutableDictionary *amount = [[NSMutableDictionary alloc] init];
        [amount addEntriesFromDictionary:@{@"amount": prescription.retrievePrice30}];
        [amount addEntriesFromDictionary:@{@"currency": @"USD"}];
        
        [dictionaryEntry addEntriesFromDictionary:@{@"base_price_money": amount}];
        [dictionaryEntry addEntriesFromDictionary:@{@"item_type": @"ITEM"}];
        [dictionaryEntry addEntriesFromDictionary:@{@"name": prescription.displayName}];
        
        [arrayOfPrescriptions addObject:dictionaryEntry];
    }
    [self.line_items addEntriesFromDictionary:@{@"line_items": arrayOfPrescriptions}];
}

-(void) setupShipping{ // Sets up the fullfillment dictionary
    PFUser *buyer = [PFUser currentUser];
    NSMutableArray *arrayForShipping = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dictionaryEntry = [[NSMutableDictionary alloc]init];
    [dictionaryEntry addEntriesFromDictionary:@{@"type": @"SHIPMENT"}];
    [dictionaryEntry addEntriesFromDictionary:@{@"state": @"PROPOSED"}];
    
    // Deals with shipment details
    NSMutableDictionary *shipmentDetails = [[NSMutableDictionary alloc] init];
    
    // Handles the details of the recipient
    NSMutableDictionary *recipientDetails = [[NSMutableDictionary alloc] init];
    [recipientDetails addEntriesFromDictionary:@{@"display_name": buyer[@"name"]}]; // Bare minimum
    
    [shipmentDetails addEntriesFromDictionary:@{@"recipient": recipientDetails}];
    
    [dictionaryEntry addEntriesFromDictionary:@{@"shipment_details":shipmentDetails}];
    
    [self.fullfillment addEntriesFromDictionary:@{@"fullfillments": dictionaryEntry}];
}

@end
