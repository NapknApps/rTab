//
//  ExpenseViewController.m
//  rTab
//
//  Created by Zach Whelchel on 8/16/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "ExpenseViewController.h"
#import "TSCurrencyTextField.h"
#import "Expense.h"
#import "DefaultsHelper.h"
#import "Person.h"

@interface ExpenseViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet TSCurrencyTextField *currencyTextField;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *people;

@end

@implementation ExpenseViewController

@synthesize delegate = _delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.nameTextField becomeFirstResponder];
    
    self.people = [DefaultsHelper peopleArray];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveSelected:(id)sender
{
    if (self.people.count == 0) {

        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"No Person Selected"
                                              message:@"Add at least one person before you create an expense."
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:@"OK"
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction *action)
                                       {
                                           
                                       }];
        
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    
    }
    else {
        if (self.nameTextField.text.length > 0) {
            
            NSUInteger selectedRow = [self.pickerView selectedRowInComponent:0];
            Person *person = (Person *)[self.people objectAtIndex:selectedRow];
            
            Expense *expense = [[Expense alloc] init];
            expense.name = self.nameTextField.text;
            expense.amount = self.currencyTextField.amount;
            expense.personUID = person.uid;
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:[DefaultsHelper expensesArray]];
            [array insertObject:expense atIndex:0];
            
            [DefaultsHelper setExpensesArray:[array copy]];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [self.delegate expenseViewControllerDidAddExpense:self];
            }];
        }
        else {
            
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Invalid"
                                                  message:@"This expense needs a title. Enter a title and then save."
                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               
                                           }];
            
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
    }
}

- (IBAction)cancelSelected:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.people.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Person *person = (Person *)[self.people objectAtIndex:row];
    return person.name;
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
