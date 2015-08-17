//
//  ExpenseViewController.h
//  rTab
//
//  Created by Zach Whelchel on 8/16/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExpenseViewController;

@protocol ExpenseViewControllerDelegate

@required

- (void)expenseViewControllerDidAddExpense:(ExpenseViewController *)expenseViewController;

@end

@interface ExpenseViewController : UIViewController

@property (nonatomic, weak) id <ExpenseViewControllerDelegate> delegate;

@end
