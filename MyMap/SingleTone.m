//
//  SingleTone.m
//  MyMap
//
//  Created by Nikolay on 19.05.15.
//  Copyright (c) 2015 gng. All rights reserved.
//

#import "SingleTone.h"

@implementation SingleTone

+ (SingleTone *)sharedSingleTone {
    
    static SingleTone * singleToneObject = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^ {
    
        singleToneObject = [[self alloc] init];
        
    });
    
    return singleToneObject;
    
}

- (void)makeMutableArray {
    
    self.someMArray = [[NSMutableArray alloc] init];
}

- (void)addObjectToMArray: (id (^) (void))block {
    
    if (self.someMArray == nil) {
        self.someMArray = [[NSMutableArray alloc] init];
    }
    
    [self.someMArray addObject:block()];
    
}

@end
