//
//  Person.m
//  rTab
//
//  Created by Zach Whelchel on 8/14/15.
//  Copyright (c) 2015 Napkn Apps. All rights reserved.
//

#import "Person.h"

@implementation Person

@synthesize name = _name;
@synthesize number = _number;
@synthesize picture = _picture;
@synthesize uid = _uid;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [decoder decodeObjectForKey:@"name"];
    self.number = [decoder decodeObjectForKey:@"number"];
    self.picture = [decoder decodeObjectForKey:@"picture"];
    self.uid = [decoder decodeObjectForKey:@"uid"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.number forKey:@"number"];
    [encoder encodeObject:self.picture forKey:@"picture"];
    [encoder encodeObject:self.uid forKey:@"uid"];
}

@end
