//
//  AppDelegate.h
//  midi
//
//  Created by Aslan Kaan Yılmaz on 24/01/15.
//  Copyright (c) 2015 Aslan Kaan Yılmaz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

void MIDIInput (const MIDIPacketList *packets, void *source, void *connectSource);


@end

