//
//  Prescription.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/12/21.
//

#import "Prescription.h"
#import "LoremIpsum/LoremIpsum.h"

@implementation Prescription

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    self.brandName = [dictionary[@"term"] capitalizedString];
    self.displayName = self.brandName;
    self.genericName = LoremIpsum.word;
    self.manufacturer = @"Brand";
    self.dosageAmount = @"500 mg";
    self.dosageForm = @"60 tablets";
    return self;
}

+ (NSMutableArray *)prescriptionsWithArray:(NSArray *)dictionaries{
    NSMutableArray *prescriptions = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Prescription *prescription = [[Prescription alloc] initWithDictionary:dictionary];
        [prescriptions addObject:prescription];
    }
    return prescriptions;
}

+ (NSMutableArray *)prescriptionsWithStrings:(NSArray *)dictionaries{
    NSMutableArray *prescriptions = [NSMutableArray array];
    for (NSString *string in dictionaries) {
        Prescription *prescription = [[Prescription alloc] initWithString:string];
        [prescriptions addObject:prescription];
    }
    return prescriptions;
}

- (instancetype)initWithString:(NSString *)brand {
    self = [super init];
    self.brandName = [brand capitalizedString];
    self.displayName = self.brandName;
    self.genericName = LoremIpsum.word;
    self.manufacturer = @"Brand";
    self.dosageAmount = @"500 mg";
    self.dosageForm = @"60 tablets";
    return self;
}
@end
