//
//  POPredicateOptimiser.h
//  PO
//
//  Created by John Scott on 03/10/2012.
//  Copyright (c) 2012 jjrscott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
  POPredicateOptimisationTypeNone,
  POPredicateOptimisationTypeBest
} POPredicateOptimisationType;

@interface POPredicateOptimiser : NSObject

@property (assign) POPredicateOptimisationType optimisationType;

-(NSPredicate*)optimisedPredicateForPredicate:(NSPredicate*)predicate;

@end
