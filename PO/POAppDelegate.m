//
//  POAppDelegate.m
//  PO
//
//  Created by John Scott on 21/07/2012.
//  Copyright (c) 2012 jjrscott. All rights reserved.
//

#import "POAppDelegate.h"

#import "POPredicateFormatter.h"
#import "POPredicateOptimiser.h"

@implementation POAppDelegate

@synthesize window = _window;
@synthesize inputTextView = _inputTextView;
@synthesize outputTextView = _outputTextView;

@synthesize optimisationPopUpButton = _optimisationPopUpButton;
@synthesize displayPopUpButton = _displayPopUpButton;

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  // Insert code here to initialize your application
  NSFont *font = [NSFont fontWithName:@"Menlo" size:11];
  
  [self.inputTextView setFont:font];
  [self.outputTextView setFont:font];
}

- (void)textDidChange:(NSNotification *)aNotification
{
  [self updateString];
}

-(void)updateString
{
  //self.inputTextView.string = self.inputTextView.string;
  
  if ([self.inputTextView.string length] == 0)
  {
    self.outputTextView.string = @"";
    return;
  }
  
  NSFont *font = [NSFont fontWithName:@"Menlo" size:11];
  
  [self.inputTextView setFont:font];
  //[self.inputTextView setTextColor: [NSColor blackColor] range: NSMakeRange(0, [self.inputTextView.string length])]; 

  NSRange textRange =[self.inputTextView.string rangeOfString:@"%@"];
  
  if(textRange.location != NSNotFound)
  {
    self.outputTextView.string = @"Remove %@'s";
    [self.outputTextView setTextColor: [NSColor redColor] range: NSMakeRange(0, [self.outputTextView.string length])]; 

    return;
  }
       
  @try
  {
    NSPredicate * inputPredicate = [NSPredicate predicateWithFormat:self.inputTextView.string argumentArray:[NSArray arrayWithObject:@"1"]];
  
    NSPredicate * outputPredicate = inputPredicate;
    
    NSString *optimisationTypeString = self.optimisationPopUpButton.selectedItem.title;
    
    POPredicateOptimiser *predicateOptimiser = [[POPredicateOptimiser alloc] init];
    if ([optimisationTypeString isEqualToString:@"Best"])
    {
      predicateOptimiser.optimisationType = POPredicateOptimisationTypeBest;
    }
    else
    {
      predicateOptimiser.optimisationType = POPredicateOptimisationTypeNone;
    }

    outputPredicate = [predicateOptimiser optimisedPredicateForPredicate:inputPredicate];
    
    POPredicateFormatter *predicateFormatter = [[POPredicateFormatter alloc] init];
    NSString *displayTypeString = self.displayPopUpButton.selectedItem.title;
    if ([displayTypeString isEqualToString:@"Code"])
    {
      predicateFormatter.displayType = POPredicateDisplayTypeCocoa;
    }
    else
    {
      predicateFormatter.displayType = POPredicateDisplayTypeString;
    }
    self.outputTextView.string = [predicateFormatter stringFromPredicate:outputPredicate];    
  
    [self.outputTextView setTextColor: [NSColor blackColor] range: NSMakeRange(0, [self.outputTextView.string length])]; 
  }
  @catch (NSException *exception)
  {
    self.outputTextView.string = [exception description];
    [self.outputTextView setTextColor: [NSColor redColor] range: NSMakeRange(0, [self.outputTextView.string length])]; 
  }
}

-(IBAction)updateOutput:(id)sender
{
  [self updateString];
}

@end
