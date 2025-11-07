# Picotracker Client

Remote client UI over USB for picoTrackers built with Flutter.

![app screenshot](docs/Screenshot2.png)]

The webapp [is available here](https://xiphonics.github.io/picotracker_client/).

## Getting Started

Connect picotracker to a usb port.

Run the Flutter web app using: 
`flutter run -d web lib/main.dart`

In VSCode, with Flutter extension installed just press `F5` to run udner a debugger.

The production application is deployed to: https://ui.xiphonics.com/ via GitHub Actions.

## Supported Platforms

- [X] Web
- [X] Linux (for dev/debugging only)


## TODO

- [X] display fg/bg colours
- [X] webapp version
- [X] use custom colours sent from picotracker ([once supported by remoteui protocol](https://github.com/xiphonics/picoTracker/issues/263))
- [X] implement notes blank *background* display of Song screen
- [ ] reconnect port on picotracker reset (on load new project)
- [ ] set initial window size
- [ ] show usb port connection status
- [X] app setting for USB port device name
- [X] request refresh on connect ([once supported by remoteui protocol](https://github.com/xiphonics/picoTracker/issues/263))
