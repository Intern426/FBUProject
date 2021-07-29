//
//  NewReminderViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/16/21.
//

#import "NewReminderViewController.h"
#import "Reminder.h"
#import "Prescription.h"

@interface NewReminderViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *prescriptionField;
@property (weak, nonatomic) IBOutlet UITextField *instructionsField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UIButton *qualityButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (strong, nonatomic) NSArray *prescriptions;

@property (strong, nonatomic) Prescription* prescription;

// Fields for autocomplete
@property (strong, nonatomic) NSMutableSet *prescriptionNames;
@property (nonatomic) int autocompleteCharacterCount;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation NewReminderViewController
  

- (void)viewDidLoad {
    [super viewDidLoad];

    self.prescriptionField.delegate = self;
    [self getAllPrescriptions];
    
    self.autocompleteCharacterCount = 0;
    self.timer = [[NSTimer alloc] init];
    // Do any additional setup after loading the view.
}

-(void) getAllPrescriptions {
    PFQuery *query = [PFQuery queryWithClassName:@"Prescription"];
    [query orderByAscending:@"drugName"];
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *prescriptions, NSError *error) {
        if (prescriptions != nil) {
            // do something with the array of object returned by the call
            self.prescriptions = [Prescription prescriptionsDataInArray:prescriptions];
            [self getPrescriptionsNames];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
    }];
}

-(void) getPrescriptionsNames{
    self.prescriptionNames = [[NSMutableSet alloc] init];
    for (Prescription *prescription in self.prescriptions) {
        [self.prescriptionNames addObject:prescription.displayName];
    }
}


// Autocomplete Source: https://medium.com/@aestusLabs/inline-autocomplete-textfields-swift-3-tutorial-for-ios-a88395ca2635
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

-(BOOL) autocomplete:(UITextField*) textField usingString:(NSString*) string withArray:(NSArray*) prescriptionNames {
    if (string.length != 0) {
        UITextRange *selectedTextRange = textField.selectedTextRange;
        if (selectedTextRange.end == textField.endOfDocument) {
            
        }
    }
    return true;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)didTapSave:(id)sender {
    NSString *instructions = self.instructionsField.text;
    Prescription *prescription = self.prescriptions[0];
    NSDate* time = self.timePicker.date;
    NSLog(@"time");
    int quantityLeft = 30;
    Reminder *newReminder = [[Reminder alloc] initWithPrescription:prescription name:self.prescriptionField.text time:time instructions:instructions quantity:quantityLeft];
    [newReminder saveInBackground];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
