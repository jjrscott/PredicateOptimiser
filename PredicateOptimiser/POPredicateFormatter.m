//
//  POPredicateFormatter.m
//  PO
//
//  Created by John Scott on 03/10/2012.
//  Copyright (c) 2012 jjrscott. All rights reserved.
//

#import "POPredicateFormatter.h"

#import "POPrivate.h"

@interface POPredicateFormatter ()
-(NSString*)stringFromPredicateWithDisplayTypeCocoa:(NSPredicate*)predicate;
@end

@implementation POPredicateFormatter


-(NSString*)stringFromPredicate:(NSPredicate*)predicate
{
    switch (self.displayType) {
        case POPredicateDisplayTypeString:
            return [predicate description];
            break;
        case POPredicateDisplayTypeCocoa:
            return [self stringFromPredicateWithDisplayTypeCocoa:predicate];
        default:
            break;
    }
    
}

-(NSString*)stringFromPredicateWithDisplayTypeCocoa:(__kindof NSPredicate*)predicate
{
    NSMutableString *buffer = [NSMutableString string];
    if ([predicate isKindOfClass:NSCompoundPredicate.class])
    {
        [buffer appendString:@"[NSCompoundPredicate "];
        NSCompoundPredicate *compoundPredicate = predicate;
        
        NSCompoundPredicateType compoundPredicateType = [compoundPredicate compoundPredicateType];
        
        if (NSNotPredicateType == compoundPredicateType)
        {
            [buffer appendString:@"notPredicateWithSubpredicate:"];
            [buffer appendString:[self stringFromPredicate:[compoundPredicate.subpredicates lastObject]]];
        }
        else
        {
            if (NSAndPredicateType == compoundPredicateType)
            {
                [buffer appendString:@"andPredicateWithSubpredicates:"];
            }
            else if (NSOrPredicateType == compoundPredicateType)
            {
                [buffer appendString:@"orPredicateWithSubpredicates:"];
            }
            
            for (NSPredicate* subpredicate in [compoundPredicate subpredicates])
            {
                [buffer appendString:[self stringFromPredicate:subpredicate]];
                [buffer appendString:@", "];
            }
            
            [buffer appendString:@"nil"];
        }
    }
    else if ([predicate isKindOfClass:NSComparisonPredicate.class])
    {
        [buffer appendString:@"[NSComparisonPredicate "];
        NSComparisonPredicate *comparisonPredicate = predicate;
        
        [buffer appendFormat:@"predicateWithLeftExpression:[NSExpression expressionWithFormat:@\"%@\" /* %@ */", comparisonPredicate.leftExpression, [comparisonPredicate.leftExpression className]];
        //[buffer appendString:[subpredicate decomposePredicate]];
        //decomposePredicate([comparisonPredicate leftExpression], buffer, indent);
        [buffer appendFormat:@"rightExpression:[NSExpression expressionWithFormat:@\"%@\" /* %@ */", comparisonPredicate.rightExpression, [comparisonPredicate.rightExpression className]];
        
        //[buffer appendString:[subpredicate decomposePredicate]];
        
        //decomposePredicate([comparisonPredicate rightExpression], buffer, indent);
        [buffer appendString:@" modifier:"];
        switch ([comparisonPredicate comparisonPredicateModifier]) {
            case NSDirectPredicateModifier:
                [buffer appendString:@"NSDirectPredicateModifier"];
                break;
            case NSAllPredicateModifier:
                [buffer appendString:@"NSAllPredicateModifier"];
                break;
            case NSAnyPredicateModifier:
                [buffer appendString:@"NSAnyPredicateModifier"];
                break;
        }
        [buffer appendString:@" type:"];
        switch ([comparisonPredicate predicateOperatorType]) {
            case NSLessThanPredicateOperatorType:
                [buffer appendString:@"NSLessThanPredicateOperatorType"];
                break;
            case NSLessThanOrEqualToPredicateOperatorType:
                [buffer appendString:@"NSLessThanOrEqualToPredicateOperatorType"];
                break;
            case NSGreaterThanPredicateOperatorType:
                [buffer appendString:@"NSGreaterThanPredicateOperatorType"];
                break;
            case NSGreaterThanOrEqualToPredicateOperatorType:
                [buffer appendString:@"NSGreaterThanOrEqualToPredicateOperatorType"];
                break;
            case NSEqualToPredicateOperatorType:
                [buffer appendString:@"NSEqualToPredicateOperatorType"];
                break;
            case NSNotEqualToPredicateOperatorType:
                [buffer appendString:@"NSNotEqualToPredicateOperatorType"];
                break;
            case NSMatchesPredicateOperatorType:
                [buffer appendString:@"NSMatchesPredicateOperatorType"];
                break;
            case NSLikePredicateOperatorType:
                [buffer appendString:@"NSLikePredicateOperatorType"];
                break;
            case NSBeginsWithPredicateOperatorType:
                [buffer appendString:@"NSBeginsWithPredicateOperatorType"];
                break;
            case NSEndsWithPredicateOperatorType:
                [buffer appendString:@"NSEndsWithPredicateOperatorType"];
                break;
            case NSInPredicateOperatorType:
                [buffer appendString:@"NSInPredicateOperatorType"];
                break;
            case NSCustomSelectorPredicateOperatorType:
                [buffer appendString:@"NSCustomSelectorPredicateOperatorType"];
                break;
            case NSContainsPredicateOperatorType:
                [buffer appendString:@"NSContainsPredicateOperatorType"];
                break;
            case NSBetweenPredicateOperatorType:
                [buffer appendString:@"NSBetweenPredicateOperatorType"];
                break;
        }
        [buffer appendString:@" options:"];
        
        BOOL barNeeded = NO;
        
        NSUInteger options = [comparisonPredicate options];
        if (options & NSCaseInsensitivePredicateOption)
        {
            barNeeded = YES;
            [buffer appendString:@"NSCaseInsensitivePredicateOption"];
        }
        if (options & NSDiacriticInsensitivePredicateOption)
        {
            if (barNeeded)
                [buffer appendString:@" | "];
            barNeeded = YES;
            [buffer appendString:@"NSDiacriticInsensitivePredicateOption"];
        }
        
        if (options & NSNormalizedPredicateOption)
        {
            if (barNeeded)
                [buffer appendString:@" | "];
            barNeeded = YES;
            [buffer appendString:@"NSNormalizedPredicateOption"];
        }
#if 0
        if (options & NSLocaleSensitivePredicateOption)
        {
            if (barNeeded)
                [buffer appendString:@" | "];
            barNeeded = YES;
            [buffer appendString:@"NSLocaleSensitivePredicateOption"];
        }
#endif
        options = options & ~(NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption | NSNormalizedPredicateOption);
        if (options != 0)
        {
            if (barNeeded)
                [buffer appendString:@" | "];
            [buffer appendFormat:@"%ld", options];
        }
        
        
        if (!barNeeded)
            [buffer appendString:@"0"];
    }
    else if ([predicate isKindOfClass:NSTruePredicate.class])
    {
        [buffer appendString:@"[NSPredicate predicateWithValue:TRUE"] ;
    }
    else if ([predicate isKindOfClass:NSFalsePredicate.class])
    {
        [buffer appendString:@"[NSPredicate predicateWithValue:FALSE"] ;
    }
    else
    {
        [buffer appendFormat:@"[NSPredicate preciateWithFormat:@\"%@\" /* %@ */", predicate, [predicate className]];
    }
    [buffer appendString:@"]"];
    return buffer;
}

@end
