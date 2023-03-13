#import <IOBluetooth/IOBluetooth.h>

@interface DeviceNotificationRunLoopStopper : NSObject
@end
@implementation DeviceNotificationRunLoopStopper {
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
@property (readonly) IOReturn errorCode;
@property char *requestedPin;
@end
@implementation DevicePairDelegate
- (const char *)errorDescription {
    return "UNKNOWN ERROR";
}

- (void)devicePairingFinished:(__unused id)sender error:(IOReturn)error {
    _errorCode = error;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)devicePairingPINCodeRequest:(id)sender {
    BluetoothPINCode pinCode;
    // send '0000' (default PIN for magic keyboard)
    pinCode.data = "0000";
    [sender replyPINCode:pinCodeSize PINCode:&pinCode];
}

- (void)devicePairingUserConfirmationRequest:(id)sender numericValue:(BluetoothNumericValue)numericValue {
    // Always accept the pairing request
    [sender replyUserConfirmation:YES];
}

- (void)devicePairingUserPasskeyNotification:(id)sender passkey:(BluetoothPasskey)passkey {
    printf();
}
@end

IOBluetoothDevice* find_device(NSArray *devices ) {
    NSString *deviceName = @"Konrad’s Magic Keyboard";
    for (IOBluetoothDevice *device in devices) {
        if ([[device name] isEqualToString:deviceName]) {
            NSLog(@"Found device: %@", device);
            return device;
        }
    }
    return nil;
}

void disconnect_device(IOBluetoothDevice *device) {
    DeviceNotificationRunLoopStopper *stopper =
        [[[DeviceNotificationRunLoopStopper alloc] initWithExpectedDevice:device] autorelease];

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
    DevicePairDelegate *delegate = [[[DevicePairDelegate alloc] init] autorelease];
    IOBluetoothDevicePair *pairer = [IOBluetoothDevicePair pairWithDevice:device];
    pairer.delegate = delegate;
    delegate.requestedPin = "0000";
    if ([pairer start] != kIOReturnSuccess) {
        NSLog(@"Failed to start with: %@", device);
        return;
    }
    CFRunLoopRun();
    [pairer stop];

    if (![device isPaired]) {
        NSLog(@"Failed to pair: %@", device);
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