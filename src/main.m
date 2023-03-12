#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

void list_paired_devices() {
  for (IOBluetoothDevice *device in [IOBluetoothDevice pairedDevices]) {
    printf(", name: \"%s\"", [device name] ? [[device name] UTF8String] : "-");
  }
}

int main(int argc, char** argv)
{
  list_paired_devices();
  return 0;
}
