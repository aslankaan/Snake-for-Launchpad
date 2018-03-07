//
//  AppDelegate.m
//  midi
//
//  Created by Aslan Kaan Yılmaz on 24/01/15.
//  Copyright (c) 2015 Aslan Kaan Yılmaz. All rights reserved.
//

#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>
#import <CoreMIDI/CoreMIDI.h>



@interface AppDelegate ()

@end

int a, b, c;
MIDIClientRef client;
MIDIPortRef iPort, oPort;
MIDIEndpointRef entity;
MIDIEndpointRef source;
MIDIEndpointRef destination;
MIDIPacketList *packets;
MIDIPacket *packet;
char buffer[1024];
Byte data[3];
int snake[64];
int size;
int direction; // 0: UP, 1: DOWN, 2: LEFT, 3:RIGHT
int stime;
int bait;
bool sem;

void MIDIInput (const MIDIPacketList *packets1, void *source, void *connectSource) {
    
    
   
    
    
    a = (int)packets1->packet[0].data[0];
    b = (int)packets1->packet[0].data[1];
    c = (int)packets1->packet[0].data[2];
    
    NSLog(@"%x, %x, %x", a, b, c);
    
    
    
    
    
    
    
    //MOVE UP
    if(a==0x90 && b==0x66 && c==0x7F){
        if(direction != 1 && !sem){
            sem = true;
            direction = 0;
        }
    }
    
    
    //MOVE DOWN
    if(a==0x90 && b==0x76 && c==0x7F){
        if(direction != 0 && !sem){
            sem = true;
            direction = 1;
        }
    }
    
    
    //MOVE LEFT
    if(a==0x90 && b==0x75 && c==0x7F){
        if(direction != 3 && !sem){
            sem = true;
            direction = 2;
        }
        
    }
    
    
    //MOVE RIGHT
    if(a==0x90 && b==0x77 && c==0x7F){
        if(direction != 2 && !sem){
            sem = true;
            direction = 3;
        }
        
    }
    
    
    
    
    
    
    //TURN OFF
    if(a==0xB0 && b==0x6F && c==0){
        data[0] = 0xB0;
        data[1] = 0;
        data[2] = 0;
        
        packets = (MIDIPacketList *)buffer;
        packet = MIDIPacketListInit(packets);
        MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
        
        
        MIDISend(oPort, destination, packets);
        direction = -1;
        exit(0);
    }
    
    if(a==0xB0 && b==0x68 && c==0){
        if(stime > 50000){
            stime -= 10000;
        }
    }
    
    if(a==0xB0 && b==0x69 && c==0){
        stime += 10000;
    }
    
    
};


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"START");
    
    MIDIClientCreate(CFSTR("client"), NULL, NULL, &client);
    
    
    MIDIInputPortCreate(client, CFSTR("iPort"), MIDIInput, (__bridge void *)(self), &iPort);
    MIDIOutputPortCreate(client, CFSTR("oPort"), &oPort);
    
    NSString *myDeviceName = @"Launchpad S";
    MIDIDeviceRef myDevice = 0;
    
    int numberOfDevices = (int)MIDIGetNumberOfDevices();
    
    for (int i = 0; i < numberOfDevices; i++) {
        MIDIDeviceRef device = MIDIGetDevice(i);
        
        if (device) {
            CFStringRef name;
            
            if (MIDIObjectGetStringProperty(device, kMIDIPropertyName, &name) == noErr) {
                NSString *deviceName = (__bridge NSString *)name;
                
                if ([myDeviceName isEqualToString:deviceName]) {
                    myDevice = device;
                    
                    CFRelease(name);
                    
                    break;
                }
            }
            
            CFRelease(name);
        }
    }
    
    entity = MIDIDeviceGetEntity(myDevice, 0);
    source = MIDIEntityGetSource(entity, 0);
    
    MIDIPortConnectSource(iPort, source, NULL);
        
    
while(1){
    
    
    int i = 0;
    
    
    snake[i++] = 0x33;
    snake[i++] = 0x32;
    snake[i++] = 0x31;
    
    size = i;
    
    for(i = size; i < 64; i++){
        snake[i] = -1;
    }
    
    
    
    data[0] = 0xB0;
    data[1] = 0x00;
    data[2] = 0x00;
    
    //Byte data[3] = {0xB0, 0x00, 0x00}; //Reset all
    
    
    //0xB0, 0x00, 0x7D-7F  TURN THE LIGHTS ON
    //0x90, 0x00, 0x30
    //to , Key, Velocity
    
    
    NSLog(@"%x, %x, %x", data[0], data[1], data[2]);
    
    packets = (MIDIPacketList *)buffer;
    packet = MIDIPacketListInit(packets);
    MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
    
    
    
    
    destination = MIDIEntityGetDestination(entity, 0);
    MIDISend(oPort, destination, packets);
    
    //START
    data[0] = 0x90;
    data[2] = 0x30;
    for(i = 0; i < size ; i++){
        if(snake[i] != -1){
            
            data[1] = snake[i];
            
            
            packets = (MIDIPacketList *)buffer;
            packet = MIDIPacketListInit(packets);
            MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
            
            
            MIDISend(oPort, destination, packets);
        }else{
            break;
        }
    }
    
    bait = 0x10* arc4random_uniform(8);
    bait = bait + arc4random_uniform(8);
    
    data[0] = 0x90;
    data[1] = bait;
    data[2] = 0x03;
    
    
    packets = (MIDIPacketList *)buffer;
    packet = MIDIPacketListInit(packets);
    MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
    
    
    MIDISend(oPort, destination, packets);

    
    
    
    
    
    
    Boolean quit = false;
    sem = false;
    stime = 150000;
    direction = 3;
    while(!quit){
        switch (direction){
            
            case 0: // MOVE UP
                //TURN OFF THE LIGHT
                data[0] = 0x90;
                data[1] = snake[size-1];
                data[2] = 0x00;
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);
                
                for(i = size-1; i > 0 ; i--){
                    snake[i] = snake[i-1];
                }
                
                if(snake[0] <= 0x07){
                    int temp;
                    temp = snake[0] % 0x10;
                    snake[0] = 0x70 + temp;
                }
                else{
                    snake[0] = snake[0] - 0x10;
                }
                
                
                
                
                
                
                //UPDATE LOCATION
                data[0] = 0x90;
                data[1] = snake[0];
                data[2] = 0x30;
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);

                
                break;
                
            case 1: //MOVE DOWN
                
                data[0] = 0x90;
                data[1] = snake[size - 1];
                data[2] = 0x00;
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);
                
                
                for(i = size-1; i > 0 ; i--){
                    snake[i] = snake[i-1];
                }
                
                
                if(snake[0] >= 0x70){
                    int temp;
                    temp = snake[0] % 0x10;
                    snake[0] = temp;
                }
                else{
                    snake[0] = snake[0] + 0x10;
                }
                
                
                //UPDATE LOCATION
                data[0] = 0x90;
                data[1] = snake[i];
                data[2] = 0x30;
                
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);
                
                break;
            
            case 2: //MOVE LEFT
                
                data[0] = 0x90;
                data[1] = snake[size - 1];
                data[2] = 0x00;
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);
                
                for(i = size-1; i > 0 ; i--){
                    snake[i] = snake[i-1];
                }
                
                
                int temp;
                temp = snake[0] % 0x10;
                
                
                if(temp <= 0){
                    snake[0] = snake[0] / 0x10;
                    snake[0] = snake[0]*0x10 + 0x7;
                }
                else{
                    snake[0] = snake[0] - 0x1;
                }
                
                //UPDATE LOCATION
                data[0] = 0x90;
                data[1] = snake[0];
                data[2] = 0x30;
                
                
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);
                
                
                
                break;
                
            case 3: //MOVE RIGHT
                
                data[0] = 0x90;
                data[1] = snake[size - 1];
                data[2] = 0x00;
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);
                
                
                for(i = size-1; i > 0 ; i--){
                    snake[i] = snake[i-1];
                }
                
               // int temp;
                temp = snake[0] % 0x10;
                
                
                if(temp >= 7){
                    snake[0] = snake[0] / 0x10;
                    snake[0] = snake[0]*0x10;
                }
                else{
                    snake[0] = snake[0] + 0x1;
                }
                
                //UPDATE LOCATION
                data[0] = 0x90;
                data[1] = snake[0];
                data[2] = 0x30;
                
                
                
                packets = (MIDIPacketList *)buffer;
                packet = MIDIPacketListInit(packets);
                MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
                
                
                MIDISend(oPort, destination, packets);
                
                
                break;
                
            default: //EXIT
                quit = true;
                
                break;
                
        }
        
        if(snake[0] == bait){
            /*
             Basso
             Blow
             Bottle
             Frog
             Funk
             Glass
             Hero
             Morse
             Ping
             Pop
             Purr
             Sosumi
             Submarine
             Tink
             
            */
            
            
            NSBeep();
            
            //CLEAR BAIT
            data[0] = 0x90;
            data[1] = bait;
            data[2] = 0x30;
            
            
            packets = (MIDIPacketList *)buffer;
            packet = MIDIPacketListInit(packets);
            MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
            
            
            MIDISend(oPort, destination, packets);

            
            
            //PUT NEW BAIT
            bait = 0x10* arc4random_uniform(7);
            bait = bait + arc4random_uniform(7);
            
            Boolean check = false;
            while(!check){
                check = true;
                for(i=0; i < size; i++){
                    if(bait == snake[i]){
                        bait = 0x10* arc4random_uniform(7);
                        bait = bait + arc4random_uniform(7);
                        check = false;
                    }
                }
            
            }
            
            
            data[0] = 0x90;
            data[1] = bait;
            data[2] = 0x03;
            
            
            packets = (MIDIPacketList *)buffer;
            packet = MIDIPacketListInit(packets);
            MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
            
            
            MIDISend(oPort, destination, packets);
            size++;
            
        }
        
        Boolean crash = false;
        
        
        for(i=1; i < size ; i++){
            if(snake[0] == snake[i]){
                crash = true;
            }
        }
        
        if(crash){
            
            crash = false;
            break;
        }
        
        
        sem = false;
        usleep(stime);
    
    }
    
    sleep(3);
}
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
