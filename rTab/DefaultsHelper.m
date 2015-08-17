//
//  DefaultsHelper.m
//  NoMoJo
//
//  Created by Zach Whelchel on 7/16/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "DefaultsHelper.h"
#import "Person.h"
#import "Expense.h"

#define kIntroShown @"kIntroShown"
#define kPeopleArray @"kPeopleArray"
#define kExpensesArray @"kExpensesArray"

@implementation DefaultsHelper

+ (BOOL)introShown
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIntroShown];
}

+ (void)setIntroShown
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIntroShown];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)peopleArray
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kPeopleArray]) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *archivedArray = [[NSUserDefaults standardUserDefaults] objectForKey:kPeopleArray];
        for (NSData *personEncoded in archivedArray) {
            Person *person = [NSKeyedUnarchiver unarchiveObjectWithData:personEncoded];
            [array addObject:person];
        }
        return [array copy];
    }
    else {
        return [NSArray array];
    }
}

+ (void)setPeopleArray:(NSArray *)peopleArray
{
    NSMutableArray *archiveArray = [NSMutableArray array];
    for (Person *person in peopleArray) {
        NSData *personEncoded = [NSKeyedArchiver archivedDataWithRootObject:person];
        [archiveArray addObject:personEncoded];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[archiveArray copy] forKey:kPeopleArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)expensesArray
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kExpensesArray]) {
        NSMutableArray *array = [NSMutableArray array];
        NSArray *archivedArray = [[NSUserDefaults standardUserDefaults] objectForKey:kExpensesArray];
        for (NSData *expenseEncoded in archivedArray) {
            Expense *expense = [NSKeyedUnarchiver unarchiveObjectWithData:expenseEncoded];
            [array addObject:expense];
        }
        return [array copy];
    }
    else {
        return [NSArray array];
    }
}

+ (void)setExpensesArray:(NSArray *)expensesArray
{
    NSMutableArray *archiveArray = [NSMutableArray array];
    for (Expense *expense in expensesArray) {
        NSData *expenseEncoded = [NSKeyedArchiver archivedDataWithRootObject:expense];
        [archiveArray addObject:expenseEncoded];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[archiveArray copy] forKey:kExpensesArray];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
