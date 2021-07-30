//
//  Prescription.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "Prescription.h"
#import "Parse/Parse.h"

@implementation Prescription

+ (NSMutableArray *)prescriptionsDataInArray:(NSArray *)data{
    NSMutableArray *prescriptions = [NSMutableArray array];
    for (PFObject *object in data) {
        Prescription *prescription = [[Prescription alloc] initWithParseData:object];
        [prescriptions addObject:prescription];
    }
    return prescriptions;
}

- (instancetype)initWithParseData:(PFObject *)prescription {
    self = [super init];
    [self parseDrugName:[prescription[@"drugName"] capitalizedString]]; // breaks apart drug name to get name and dosage amount
    self.amount30 = prescription[@"day30amount"];
    self.amount90 = prescription[@"day90amount"];
    self.price30 = prescription[@"day30price"];
    self.price90 = [prescription[@"day90price"] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    self.prescriptionPointer = prescription;
    return self;
}

- (NSNumber*) retrievePrice30 {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *result = [formatter numberFromString:[self.price30 substringWithRange:NSMakeRange(1, self.price30.length - 1)]];
    return result;
}

- (NSNumber*) retrievePrice90 {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *result = [formatter numberFromString:[self.price90 substringWithRange:NSMakeRange(1, self.price90.length - 1)]];
    return result;
}

- (void) parseDrugName:(NSString*)drugInformation {
    NSArray* drugInformationArray = [drugInformation componentsSeparatedByString:@" "];
    NSMutableString *drugName = [[NSMutableString alloc]init];
    BOOL isDrugName = YES;
    int i;
    for (i = 0; i < drugInformationArray.count && isDrugName; i++) {
        NSString *result =  drugInformationArray[i];
        if (result.length > 0) {
            unichar firstCharacter = [result characterAtIndex:0];
            NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
            if ([numericSet characterIsMember:firstCharacter]) { // Starts with a number so not the drug name (dosage)
                isDrugName = NO;
            } else {
                [drugName appendString: [NSString stringWithFormat:@"%@ ", result]];
            }
        } else {
            isDrugName = NO;
        }
    }
    self.displayName = drugName;
    if (i != drugInformationArray.count) { // means that the whole string wasn't used for the name
        self.dosageAmount = [drugInformation componentsSeparatedByString:self.displayName][1];
    }
}

- (BOOL)isEqual:(id)other
{
    if (other == self) {
        return YES;
    } else {
        if (![other isKindOfClass:[Prescription class]])
            return NO;
        Prescription *comparePrescription = (Prescription*) other;
        return [self.displayName isEqual:comparePrescription.displayName] && [self.dosageAmount isEqual:comparePrescription.dosageAmount];
    }
}

@end
