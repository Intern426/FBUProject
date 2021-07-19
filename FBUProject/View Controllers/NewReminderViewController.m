//
//  NewReminderViewController.m
//  FBUProject
//
//  Created by Kalkidan Tamirat on 7/16/21.
//

#import "NewReminderViewController.h"

@interface NewReminderViewController ()
@property (weak, nonatomic) IBOutlet UITextField *prescriptionField;
@property (weak, nonatomic) IBOutlet UITextField *instructionsField;
@property (weak, nonatomic) IBOutlet UITextField *quantityField;
@property (weak, nonatomic) IBOutlet UIButton *qualityButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation NewReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
