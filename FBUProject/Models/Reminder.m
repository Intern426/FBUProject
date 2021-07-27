//
//  Reminder.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "Reminder.h"

@implementation Reminder


@dynamic author;
@dynamic instruction;
@dynamic alarm;
@dynamic prescription;
@dynamic prescriptionName;
@dynamic quantityLeft;

-(instancetype) initWithPrescription:(Prescription*) prescription time: (NSDate*) date instructions: (NSString*) instruction quantity: (int) quantity{
    self = [super init];
    self.prescription = prescription.prescriptionPointer;
    self.prescriptionName = prescription.displayName;
    self.alarm = date;
    self.instruction = instruction;
    self.quantityLeft = quantity;
    self.author = [PFUser currentUser];
    return self;
}

+ (nonnull NSString *)parseClassName {
    return @"Reminder";
}

+ (NSMutableArray *)initWithArray:(NSArray *)data{
    NSMutableArray *reminders = [[NSMutableArray alloc] init];
    for (PFObject *object in data) {
        Reminder* reminder = [[Reminder alloc] initWithParseData:object];
        [reminders addObject:reminder];
    }
    return reminders;
}

-(instancetype) initWithParseData:(PFObject*) reminder{
    self = [super init];
    PFObject* authorObject = reminder[@"author"];
    PFQuery *findAuthor = [PFQuery queryWithClassName:@"User"];
    self.author =  [findAuthor getObjectWithId:authorObject.objectId];
    self.alarm = reminder[@"alarm"];
    self.instruction = reminder[@"instruction"];
    PFObject* prescriptionObject = reminder[@"prescription"];
    PFQuery *findPrescription = [PFQuery queryWithClassName:@"Prescription"];
    self.prescription =  [findPrescription getObjectWithId:prescriptionObject.objectId];
    self.quantityLeft = reminder[@"quantityLeft"];
    self.prescriptionName = reminder[@"prescriptionName"];
    return self;
}

@end
