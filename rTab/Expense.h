//
//  Expense.h
//  rTab
//
//  Created by Zach Whelchel on 8/14/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Expense : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic, retain) NSString *personUID;

@end
