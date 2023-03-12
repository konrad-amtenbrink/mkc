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


void list_devices(NSArray *devices ) {
    for (IOBluetoothDevice *device in devices) {
        NSLog(@"Device: %@", device);
    }
}

void disconnect_device(IOBluetoothDevice *device) {
    DeviceNotificationRunLoopStopper *stopper =
        [[[DeviceNotificationRunLoopStopper alloc] initWithExpectedDevice:device] autorelease];

    [device registerForDisconnectNotification:stopper selector:@selector(notification:fromDevice:)];

    if ([device closeConnection] != kIOReturnSuccess) {
        NSLog(@"Failed to close connection to device: %@", device);
    }
}

int main(int argc, const char * argv[]) {
    list_devices([IOBluetoothDevice pairedDevices]);
    return 0;
}