//
//  POPredicateOptimiser.m
//  PO
//
//  Created by John Scott on 03/10/2012.
//  Copyright (c) 2012 jjrscott. All rights reserved.
//

#import "POPredicateOptimiser.h"

#import "POPrivate.h"

@interface POPredicateOptimiser ()

-(NSPredicate*)optimisedPredicateForPredicateWithOptimisationTypeBest:(NSPredicate*)predicate;


@end

@implementation POPredicateOptimiser

-(NSPredicate*)optimisedPredicateForPredicate:(NSPredicate*)predicate
{
    switch (self.optimisationType) {
        case POPredicateOptimisationTypeNone:
            return [predicate copy];
            break;
        case POPredicateOptimisationTypeBest:
            return [self optimisedPredicateForPredicateWithOptimisationTypeBest:predicate];
        default:
            break;
    }
    
    
}
-(NSPredicate*)optimisedPredicateForPredicateWithOptimisationTypeBest:(__kindof NSPredicate*)predicate
{
    if ([predicate isKindOfClass:NSComparisonPredicate.class])
    {
        NSComparisonPredicate *comparisonPredicate = predicate;
        NSExpression *leftExpression = [comparisonPredicate leftExpression];
        NSExpression *rightExpression = [comparisonPredicate rightExpression];
        if ([comparisonPredicate predicateOperatorType] == NSInPredicateOperatorType && [rightExpression expressionType] == NSAggregateExpressionType && [[rightExpression collection] count] == 1)
        {
            return [NSComparisonPredicate predicateWithLeftExpression:[comparisonPredicate leftExpression]
                                                      rightExpression:[NSExpression expressionForConstantValue:[[rightExpression collection] objectAtIndex:0]]
                                                             modifier:[comparisonPredicate comparisonPredicateModifier]
                                                                 type:NSEqualToPredicateOperatorType
                                                              options:[comparisonPredicate options]];
        }
        else if ([leftExpression expressionType] == NSConstantValueExpressionType && [rightExpression expressionType] == NSConstantValueExpressionType)
        {
            return [NSPredicate predicateWithValue:[comparisonPredicate evaluateWithObject:nil]];
        }
        
    }
    else if ([predicate isKindOfClass:NSCompoundPredicate.class])
    {
        NSCompoundPredicate *compoundPredicate = predicate;
        
        NSCompoundPredicateType compoundPredicateType = [compoundPredicate compoundPredicateType];
        if (NSNotPredicateType == compoundPredicateType)
        {
            NSPredicate *improvedSubPredicate = [self optimisedPredicateForPredicate:[[compoundPredicate subpredicates] lastObject]];
            
            if ([improvedSubPredicate isKindOfClass:NSTruePredicate.class] || [improvedSubPredicate isKindOfClass:NSFalsePredicate.class])
            {
                return [NSPredicate predicateWithValue:![improvedSubPredicate evaluateWithObject:nil]];
            }
            else if ([improvedSubPredicate isKindOfClass:NSComparisonPredicate.class])
            {
                NSComparisonPredicate *comparisonImprovedSubPredicate = (NSComparisonPredicate *)improvedSubPredicate;
                NSPredicateOperatorType operatorType;
                BOOL hasKnownOperatorType = YES;
                switch ([comparisonImprovedSubPredicate predicateOperatorType])
                {
                    case NSLessThanPredicateOperatorType:
                        operatorType = NSGreaterThanOrEqualToPredicateOperatorType;
                        break;
                    case NSLessThanOrEqualToPredicateOperatorType:
                        operatorType = NSGreaterThanPredicateOperatorType;
                        break;
                    case NSGreaterThanPredicateOperatorType:
                        operatorType = NSLessThanOrEqualToPredicateOperatorType;
                        break;
                    case NSGreaterThanOrEqualToPredicateOperatorType:
                        operatorType = NSLessThanPredicateOperatorType;
                        break;
                    case NSEqualToPredicateOperatorType:
                        operatorType = NSNotEqualToPredicateOperatorType;
                        break;
                    case NSNotEqualToPredicateOperatorType:
                        operatorType = NSEqualToPredicateOperatorType;
                        break;
                    default:
                        hasKnownOperatorType = NO;
                        break;
                }
                
                
                if (hasKnownOperatorType)
                {
                    return [NSComparisonPredicate predicateWithLeftExpression:[comparisonImprovedSubPredicate leftExpression]
                                                              rightExpression:[comparisonImprovedSubPredicate rightExpression]
                                                                     modifier:[comparisonImprovedSubPredicate comparisonPredicateModifier]
                                                                         type:operatorType
                                                                      options:[comparisonImprovedSubPredicate options]];
                    
                }
                
            }
            
            return [NSCompoundPredicate notPredicateWithSubpredicate:improvedSubPredicate];
        }
        else
        {
            NSMutableArray * subpredicates = [NSMutableArray array];
            for (NSPredicate* subpredicate in [compoundPredicate subpredicates])
            {
                NSPredicate *improvedSubPredicate = [self optimisedPredicateForPredicate:subpredicate];
                
                if ([improvedSubPredicate isKindOfClass:NSTruePredicate.class])
                {
                    switch (compoundPredicateType)
                    {
                        case NSNotPredicateType:
                            return [NSPredicate predicateWithValue:NO];
                        case NSOrPredicateType:
                            return [NSPredicate predicateWithValue:YES];
                            break;
                            
                        case NSAndPredicateType:
                            break;
                        default:
                            break;
                    }
                }
                else if ([improvedSubPredicate isKindOfClass:NSFalsePredicate.class])
                {
                    switch (compoundPredicateType)
                    {
                        case NSNotPredicateType:
                            return [NSPredicate predicateWithValue:YES];
                        case NSOrPredicateType:
                            break;
                            
                        case NSAndPredicateType:
                            return [NSPredicate predicateWithValue:NO];
                            break;
                        default:
                            break;
                    }
                }
                else
                {
                    [subpredicates addObject:improvedSubPredicate];
                }
            }
            
            if ([subpredicates count] == 1)
            {
                /*
                 If there's only one, don't bother with the wrapper
                 */
                return [subpredicates objectAtIndex:0];
            }
            else if ([subpredicates count] > 0)
            {
                if (compoundPredicateType == NSOrPredicateType)
                {
                    return [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
                }
                else if (NSAndPredicateType == compoundPredicateType)
                {
                    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
                }
            }
            else
            {
                /*
                 If we've got an empty list here it's because we skipped all the false ones. So the result must be false.
                 */
                return [predicate copy];
            }
        }
    }
    
    return predicate;
}

@end
