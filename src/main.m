#import <IOBluetooth/IOBluetooth.h>

@interface RunLoopStopper : NSObject
@end
@implementation RunLoopStopper {
    IOBluetoothDevice *expectedDevice;
}
- (id)initWithExpectedDevice:(IOBluetoothDevice *)device {
    expectedDevice = device;
    return self;
}
- (void)notification:(IOBluetoothUserNotification *)notification fromDevice:(IOBluetoothDevice *)device {
    if ([expectedDevice isEqual:device]) {
        [notification unregister];
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}
@end

@interface DevicePairDelegate : NSObject <IOBluetoothDevicePairDelegate>
@end
@implementation DevicePairDelegate
- (void)devicePairingFinished:(__unused id)sender error:(IOReturn)error {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)devicePairingUserConfirmationRequest:(id)sender numericValue:(BluetoothNumericValue)numericValue {
    // Always accept the pairing request
    [sender replyUserConfirmation:YES];
}
@end

IOBluetoothDevice* find_device(NSArray *devices ) {
    NSString *deviceName = @"Magic Keyboard";
    for (IOBluetoothDevice *device in devices) {
        if (!([[device name] rangeOfString:deviceName].location == NSNotFound)) {
            printf("Found device: %s\n", [[device name] UTF8String]);
            return device;
        }
    }
    return nil;
}

void disconnect_device(IOBluetoothDevice *device) {
    RunLoopStopper *stopper =
        [[[RunLoopStopper alloc] initWithExpectedDevice:device] autorelease];

    [device registerForDisconnectNotification:stopper selector:@selector(notification:fromDevice:)];

    if ([device closeConnection] != kIOReturnSuccess) {
        NSLog(@"Failed to close connection to device: %@", device);
    }
}

void unpair_device(IOBluetoothDevice *device) {
    if ([device respondsToSelector:@selector(remove)]) {
        [device performSelector:@selector(remove)];
    }
}

void pair_device(IOBluetoothDevice *device) {
    printf("Start pairing now? [yes, No] ");
    uint input_size = 3 + 2;
    char input[input_size];
    fgets(input, input_size, stdin);
    input[strcspn(input, "\n")] = 0;
    size_t length = strlen(input);
    if (length < 1) length = 1;

    if (strncasecmp("yes", input, length) != 0) {
        return;
    }

    printf("Pairing %s\n", [[device name] UTF8String]);

    @autoreleasepool {
        DevicePairDelegate *delegate = [[[DevicePairDelegate alloc] init] autorelease];
        IOBluetoothDevicePair *pairer = [IOBluetoothDevicePair pairWithDevice:device];
        pairer.delegate = delegate;

        if ([pairer start] != kIOReturnSuccess) {
            NSLog(@"Failed to start pairing with: %@", device);
            return;
        }
        CFRunLoopRun();
        [pairer stop];
    }
}

int main(int argc, const char * argv[]) {
    IOBluetoothDevice *device = find_device([IOBluetoothDevice pairedDevices]);
    if (device == nil) {
        NSLog(@"Device not found");
        return 1;
    }
    disconnect_device(device);
    unpair_device(device);
    pair_device(device);
    return 0;
}