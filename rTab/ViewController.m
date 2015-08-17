//
//  ViewController.m
//  rTab
//
//  Created by Zach Whelchel on 8/11/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "ViewController.h"
#import "PersonTableViewCell.h"
#import "ExpenseTableViewCell.h"
#import "DefaultsHelper.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Person.h"
#import "Debt.h"
#import "Expense.h"
#import "ExpenseViewController.h"
#import <MessageUI/MessageUI.h>

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate, ExpenseViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *endButton;
@property (strong, nonatomic) NSArray *people;
@property (strong, nonatomic) NSArray *expenses;

@end

@implementation ViewController

@synthesize people = _people;
@synthesize expenses = _expenses;

- (NSArray *)people
{
    if (_people == nil) {
        _people = [NSArray array];
    }
    return _people;
}

- (NSArray *)expenses
{
    if (_expenses == nil) {
        _expenses = [NSArray array];
    }
    return _expenses;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.navigationController.toolbar.clipsToBounds = YES;
    
    [self.segmentedControl setSelectedSegmentIndex:0];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.people = [DefaultsHelper peopleArray];
    self.expenses = [DefaultsHelper expensesArray];

    [self.tableView reloadData];
}

- (IBAction)segmentedControlDidChangeValue:(id)sender
{
    [self.tableView reloadData];
}

- (IBAction)addButtonSelected:(id)sender
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        ABPeoplePickerNavigationController *personPicker = [ABPeoplePickerNavigationController new];
        personPicker.peoplePickerDelegate = self;
        [self presentViewController:personPicker animated:YES completion:nil];
    }
    else {
        [self performSegueWithIdentifier:@"NewExpense" sender:self];
    }

    /*
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:nil
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *personAction = [UIAlertAction
                                   actionWithTitle:@"Person"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       // TODO: Do we need to ask permission for this?
                                       
                                       ABPeoplePickerNavigationController *personPicker = [ABPeoplePickerNavigationController new];
                                       personPicker.peoplePickerDelegate = self;
                                       [self presentViewController:personPicker animated:YES completion:nil];

                                   }];
    
    [alertController addAction:personAction];

    UIAlertAction *expenseAction = [UIAlertAction
                                   actionWithTitle:@"Expense"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self performSegueWithIdentifier:@"NewExpense" sender:self];
                                   }];
    
    [alertController addAction:expenseAction];

    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    */
}

- (IBAction)endButtonSelected:(id)sender
{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Delete All Data"
                                          message:@"Ready to restart? This will delete all people and expenses."
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *restartAction = [UIAlertAction
                                   actionWithTitle:@"Delete"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
                                   {
                                       [DefaultsHelper setPeopleArray:nil];
                                       [DefaultsHelper setExpensesArray:nil];
                                       
                                       self.people = [NSArray array];
                                       self.expenses = [NSArray array];

                                       [self.tableView reloadData];
                                   }];
    
    [alertController addAction:restartAction];

    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Not Now"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       
                                   }];
    
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (IBAction)settleUpSelected:(id)sender
{
    if (self.expenses.count == 0) {
        
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"No Expenses" message:@"No need to settle up until you have entered expenses." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        
    }
    else {
        NSMutableArray *mutableArray = [NSMutableArray array];
        
        for (Person *person in self.people) {
            if (person.number.length > 0) {
                [mutableArray addObject:person.number];
            }
        }
        
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        NSArray *recipents = mutableArray;
        NSMutableArray *debts = [NSMutableArray array];

        NSMutableArray *peopleOwed = [NSMutableArray array];
        NSMutableArray *peopleWhoOwe = [NSMutableArray array];

        for (Person *person in self.people) {
            float amountBack = [[self moneyPaidByPerson:person] floatValue] - ([[self moneySpentByGroup] floatValue] / self.people.count);
            if (amountBack > 0.0) {
                [peopleOwed addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:person, @"person", [NSNumber numberWithFloat:amountBack], @"amount", nil]];
            }
            else if (amountBack < 0.0) {
                [peopleWhoOwe addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:person, @"person", [NSNumber numberWithFloat:-amountBack], @"amount", nil]];
            }
        }
        
        for (NSMutableDictionary *person in peopleWhoOwe) {
            
            float amountLeftToPay = [[person valueForKey:@"amount"] floatValue];
            
            while (amountLeftToPay > 0.001) {
                
                NSMutableDictionary *idealPersonToPayBack = nil;
                
                for (NSMutableDictionary *personToPay in peopleOwed) {
                    float amountOwed = [[person valueForKey:@"amount"] floatValue];
                    if (amountLeftToPay < amountOwed) {
                        idealPersonToPayBack = personToPay;
                    }
                }
                
                if (!idealPersonToPayBack) {
                    idealPersonToPayBack = [peopleOwed firstObject];
                }
                
                float amountPersonOwedIsOwed = [[idealPersonToPayBack valueForKey:@"amount"] floatValue];
                
                if (amountLeftToPay > amountPersonOwedIsOwed) {
                    amountLeftToPay = amountLeftToPay - amountPersonOwedIsOwed;
                    [peopleOwed removeObject:idealPersonToPayBack];
                    
                    [debts addObject:[NSString stringWithFormat:@"%@ -> %@ $%.2f", [[person valueForKey:@"person"] name], [[idealPersonToPayBack valueForKey:@"person"] name], amountPersonOwedIsOwed]];
                    
                }
                else {
                    [idealPersonToPayBack setValue:[NSNumber numberWithFloat:amountPersonOwedIsOwed - amountLeftToPay] forKey:@"amount"];
                    
                    [debts addObject:[NSString stringWithFormat:@"%@ -> %@ $%.2f", [[person valueForKey:@"person"] name], [[idealPersonToPayBack valueForKey:@"person"] name], amountLeftToPay]];
                    
                    amountLeftToPay = 0;
                }
            }
        }
        
        NSString *message = [NSString stringWithFormat:@"Time to settle up!\n%@", [debts componentsJoinedByString:@"\n"]];
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"NewExpense"]) {
        UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
        ExpenseViewController *expenseViewController = navigationController.viewControllers.firstObject;
        expenseViewController.delegate = self;
    }
}

- (void)expenseViewControllerDidAddExpense:(ExpenseViewController *)expenseViewController
{
    [self.segmentedControl setSelectedSegmentIndex:1];
    self.expenses = [DefaultsHelper expensesArray];
    [self.tableView reloadData];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    NSString *firstName;
    NSString *lastName;
    NSString *phoneNumber;
    NSString *retrievedName;
    UIImage *retrievedImage;
    
    firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    phoneNumber = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     kABPersonPhoneProperty);
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)
        ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        phoneNumber = phone;
    } else {
        phone = @"[None]";
    }
    CFRelease(phoneNumbers);
    
    if (person != nil && ABPersonHasImageData(person)) {
        retrievedImage = [UIImage imageWithData:(__bridge_transfer NSData*)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail)];
    }
    else {
        retrievedImage = nil;
    }
    
    retrievedName = [[NSString alloc] initWithFormat:@"%@ %@",firstName,lastName];
    
    NSLog(@"-------");
    NSLog(@"%@", retrievedName);
    NSLog(@"%@", phoneNumber);
    NSLog(@"-------");

    [self dismissViewControllerAnimated:YES completion:^(){
        Person *person = [[Person alloc] init];
        person.name = retrievedName;
        person.number = phoneNumber;
        person.picture = retrievedImage;
        person.uid = [self uuid];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[DefaultsHelper peopleArray]];
        [array addObject:person];
        
        [DefaultsHelper setPeopleArray:[array copy]];
        self.people = [array copy];
        
        [self.segmentedControl setSelectedSegmentIndex:0];
        
        [self.tableView reloadData];
    }];
}

- (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSNumber *)moneySpentByGroup
{
    float total = 0.0;
    for (Expense *expense in self.expenses) {
        total = total + [expense.amount floatValue];
    }
    return [NSNumber numberWithFloat:total];
}

- (NSNumber *)moneyPaidByPerson:(Person *)person
{
    float total = 0.0;
    for (Expense *expense in self.expenses) {
        if ([expense.personUID isEqualToString:person.uid]) {
            total = total + [expense.amount floatValue];
        }
    }
    return [NSNumber numberWithFloat:total];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return [self.people count];
    }
    else {
        return [self.expenses count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        PersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PersonTableViewCell"];
        
        cell.pictureImageView.layer.cornerRadius = cell.pictureImageView.frame.size.width / 2;
        cell.pictureImageView.clipsToBounds = YES;
        
        Person *person = [self.people objectAtIndex:indexPath.row];
        cell.nameLabel.text = person.name;
        
        float amountBack = [[self moneyPaidByPerson:person] floatValue] - ([[self moneySpentByGroup] floatValue] / self.people.count);
        if (amountBack > 0.0) {
            cell.summaryLabel.text = [NSString stringWithFormat:@"Gets Back: $%.2f", amountBack];
        }
        else if (amountBack < 0.0) {
            cell.summaryLabel.text = [NSString stringWithFormat:@"Owes: $%.2f", -amountBack];
        }
        else {
            cell.summaryLabel.text = @"Even";
        }
        
        [cell.pictureImageView setImage:person.picture];
        
        return cell;
    }
    else {
        ExpenseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpenseTableViewCell"];
        
        Expense *expense = [self.expenses objectAtIndex:indexPath.row];
        
        Person *person;
        
        for (Person *aPerson in self.people) {
            if ([expense.personUID isEqualToString:aPerson.uid]) {
                person = aPerson;
            }
        }

        cell.expenseLabel.text = [NSString stringWithFormat:@"%@ paid %.2f for %@.", person.name, [expense.amount floatValue], expense.name];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        return 100;
    }
    else {
        return 82;
    }
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (self.segmentedControl.selectedSegmentIndex == 0) {

            // Cant remove a person if they have expenses...
            
            
            NSMutableArray *editedPeopleArray = [NSMutableArray arrayWithArray:self.people];

            Person *person = [editedPeopleArray objectAtIndex:indexPath.row];
            
            BOOL personHasExpenses = NO;
            
            for (Expense *expense in self.expenses) {
                if ([expense.personUID isEqualToString:person.uid]) {
                    personHasExpenses = YES;
                }
            }
            
            if (personHasExpenses == NO) {
                [editedPeopleArray removeObjectAtIndex:indexPath.row];
                
                self.people = [editedPeopleArray copy];
                [DefaultsHelper setPeopleArray:[editedPeopleArray copy]];
                
                [self.tableView reloadData];
            }
            else {
                
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Can't Delete"
                                                      message:@"This person has expenses they have paid for. Remove those expenses to remove this person."
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
        else {
            
            NSMutableArray *editedExpensesArray = [NSMutableArray arrayWithArray:self.expenses];
            [editedExpensesArray removeObjectAtIndex:indexPath.row];
            
            self.expenses = [editedExpensesArray copy];
            [DefaultsHelper setExpensesArray:[editedExpensesArray copy]];
            
            [self.tableView reloadData];

        }
    }
}

@end
