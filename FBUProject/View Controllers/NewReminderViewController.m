//
//  NewReminderViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/16/21.
//

#import "NewReminderViewController.h"
#import "Reminder.h"

@interface NewReminderViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *prescriptionField;
@property (weak, nonatomic) IBOutlet UITextField *instructionsField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UIButton *qualityButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (strong, nonatomic) NSArray *prescriptions;

@end

@implementation NewReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.prescriptionField.delegate = self;
    // Do any additional setup after loading the view.
}
/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}

-(BOOL) autocomplete:(UITextField*) textField usingString:(NSString*) string withArray:(NSArray*) prescriptionNames {
    if (string.length != 0) {
        UITextRange *selectedTextRange = textField.selectedTextRange;
        if (selectedTextRange.end == textField.endOfDocument) {
            
        }
    }
    
}
*/
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)didTapSave:(id)sender {
    Reminder *newReminder = [[Reminder alloc] init];
    self.prescriptionField.showsMenuAsPrimaryAction = YES;
}


@end
