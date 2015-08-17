//
//  Person.h
//  rTab
//
//  Created by Zach Whelchel on 8/14/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Person : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *number;
@property (nonatomic, retain) UIImage *picture;
@property (nonatomic, retain) NSString *uid;

@end
