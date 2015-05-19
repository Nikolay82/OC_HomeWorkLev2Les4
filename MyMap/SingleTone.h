//
//  SingleTone.h
//  MyMap
//
//  Created by Nikolay on 19.05.15.
//  Copyright (c) 2015 gng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleTone : NSObject

+ (SingleTone *)sharedSingleTone;

@property (nonatomic, weak) NSString * someString;

@property (nonatomic, strong) NSMutableArray * someMArray;

- (void)makeMutableArray;

- (void)addObjectToMArray: (id (^) (void))block;


@end
