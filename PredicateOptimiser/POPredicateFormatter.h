//
//  POPredicateFormatter.h
//  PO
//
//  Created by John Scott on 03/10/2012.
//  Copyright (c) 2012 jjrscott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
  POPredicateDisplayTypeString,
  POPredicateDisplayTypeCocoa
} POPredicateDisplayType;

@interface POPredicateFormatter : NSObject

@property (assign) POPredicateDisplayType displayType;

-(NSString*)stringFromPredicate:(NSPredicate*)predicate;

@end
