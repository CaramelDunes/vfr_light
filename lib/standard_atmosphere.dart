import 'dart:math';

// https://fr.wikipedia.org/wiki/Atmosph%C3%A8re_normalis%C3%A9e

// Pressures in millibar/hPA

class StandardAtmosphere {
  static double altitude({required double pressure, required double qnh}) {
    return (1 - pow(pressure / qnh, 1 / 5.255)) * 288.15 / 0.0065;
  }

  static double qnh({required double pressure, required double altitude}) {
    return pressure / pow(1 - 0.0065 * altitude / 288.15, 5.255);
  }

  static double feetFromMeters(double meters) {
    return meters * 3.2808;
  }

  // Not exactly flight level as it is not rounded to nearest multiple of 5.
  static int? flightLevel({required double pressure}) {
    final double flightLevelInFeet = StandardAtmosphere.feetFromMeters(
        StandardAtmosphere.altitude(qnh: 1013.25, pressure: pressure));

    if (flightLevelInFeet >= 0) {
      return (flightLevelInFeet / 100.0).floor();
    }
  }
}
