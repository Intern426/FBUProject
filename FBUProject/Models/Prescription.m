//
//  Prescription.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "Prescription.h"
#import "LoremIpsum/LoremIpsum.h"
#import "Parse/Parse.h"

@implementation Prescription


+ (NSMutableArray *)prescriptionsWithArray:(NSArray *)dictionaries{
    NSMutableArray *prescriptions = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
 //       Prescription *prescription = [[Prescription alloc] init];
  //      [prescriptions addObject:prescription];
    }
    return prescriptions;
}


+ (NSMutableArray *)prescriptionsDatainArray:(NSArray *)data{
    NSMutableArray *prescriptions = [NSMutableArray array];
    for (PFObject *object in data) {
        Prescription *prescription = [[Prescription alloc] initWithParseData:object];
        [prescriptions addObject:prescription];
    }
    return prescriptions;
}

- (instancetype)initWithParseData:(PFObject *)prescription {
    self = [super init];
    NSArray *information = [[prescription[@"drugName"] capitalizedString] componentsSeparatedByString:@" "];
    [self parseDrugName:information]; // initializes drug name and dosage amount
    self.amount30 = prescription[@"day30amount"];
    self.amount90 = prescription[@"day90amount"];
    self.price30 = prescription[@"day30price"];
    self.price90 = prescription[@"day90price"];
    self.prescriptionPointer = prescription;
    return self;
}

- (void) parseDrugName:(NSArray*)information {
    NSMutableString *drugName = [[NSMutableString alloc]init];
    BOOL isDrugName = YES;
    int i;
    for (i = 0; i < information.count && isDrugName; i++) {
        NSString *result =  information[i];
        unichar firstCharacter = [result characterAtIndex:0];
        NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
        if ([numericSet characterIsMember:firstCharacter]) { // Starts with a number so not the drug name
            isDrugName = NO;
            i--;
        } else {
            [drugName appendString: [NSString stringWithFormat:@"%@ ", result]];
        }
    }
    self.displayName = drugName;
    NSMutableString *dosageInformation = [[NSMutableString alloc] init];
    for (int j = i; j < information.count; j++)
        [dosageInformation appendString:[NSString stringWithFormat:@"%@ ", information[j]]];
    self.dosageAmount = dosageInformation;
}




+ (NSMutableArray *)prescriptionsWithStrings:(NSArray *)dictionaries{
    NSMutableArray *prescriptions = [NSMutableArray array];
    for (NSString *string in dictionaries) {
      //  Prescription *prescription = [[Prescription alloc] initWithString:string];
      //  [prescriptions addObject:prescription];
    }
    return prescriptions;
}


@end
