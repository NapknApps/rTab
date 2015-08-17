//
//  Expense.m
//  rTab
//
//  Created by Zach Whelchel on 8/14/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "Expense.h"

@implementation Expense

@synthesize name = _name;
@synthesize amount = _amount;
@synthesize personUID = _personUID;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [decoder decodeObjectForKey:@"name"];
    self.amount = [decoder decodeObjectForKey:@"amount"];
    self.personUID = [decoder decodeObjectForKey:@"personUID"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.amount forKey:@"amount"];
    [encoder encodeObject:self.personUID forKey:@"personUID"];
}

@end