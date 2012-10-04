//
//  POAppDelegate.h
//  PO
//
//  Created by John Scott on 21/07/2012.
//  Copyright (c) 2012 jjrscott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface POAppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (assign) IBOutlet NSTextView *inputTextView;

@property (assign) IBOutlet NSTextView *outputTextView;

-(IBAction)updateOutput:(id)sender;

@property (assign) IBOutlet NSPopUpButton *optimisationPopUpButton;
@property (assign) IBOutlet NSPopUpButton *displayPopUpButton;

@end
