//
//  Reminder.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/14/21.
//

#import "Reminder.h"

@implementation Reminder

-(instancetype) initWithPrescription:(Prescription*) prescription time: (NSDate*) date instructions: (NSString*) instruction quantity: (int) quantity{
    self = [super init];
    self.prescription = prescription;
    self.prescriptionName = prescription.displayName;
    self.time = date;
    self.instructions = instruction;
    self.quantityLeft = quantity;
    self.assignedUser = [PFUser currentUser];
    return self;
}

@end
