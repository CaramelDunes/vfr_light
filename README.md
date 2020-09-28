# VFR Light [![Build Status](https://api.cirrus-ci.com/github/CaramelDunes/vfr_light.svg)](https://cirrus-ci.com/github/CaramelDunes/vfr_light)

VFR Light is a lightweight assistant for pilots flying under VFR.

## Screenshots

<img src="https://github.com/CaramelDunes/vfr_light/raw/readme/screenshots/map.png" width="200" alt="Map"> <img src="https://github.com/CaramelDunes/vfr_light/raw/readme/screenshots/navigation.png" width="200" alt="Navigation"> 

## Features

 - Barometer-based altimeter
 - Flight trace recording
 - Primitive navigation aid
 
## Requirements

A device with a barometer and a GPS receiver.

## Building

Download the French VFR charts with

```
pub get
dart bin/download_oaci_vfr.dart
```

Build the apk with

```
flutter build apk
```

## License

Licensed under the GNU General Public License v3.0.

See [LICENSE](LICENSE) for more information.