# Counter-Strike 2 Server Blocker

Helps you in blocking Valve's Counter-Strike 2 matchmaking servers.

## How it works

At launch this app gets the Steam Datagram Relay config for Counter-Strike 2 and reads all the servers that Valve uses for their matchmaking, it then creates a firewall rule for each of the relays and allows you to toggle it On or Off.
Because this tool makes changes to your firewall it requires admin privileges in order to work.

## Compatibility

Tested only on Windows 10, should work on Windows 11 too.

## Download

[Click here for latest release.](https://github.com/Fyffe/cs2serverblocker/releases)

## Compiling the source code

This project is based on Flutter and utilizes Windows API to work with your system's firewall.

Requirements:
- [Visual Studio 2022](https://learn.microsoft.com/visualstudio/install/install-visual-studio?view=vs-2022) with *Desktop development with C++* workload.
- [Flutter 3.29.0](https://docs.flutter.dev/get-started/install/windows/desktop)

Just run the `flutter build windows` and then `flutter run -d windows` commands. Make sure you are launching these with admin permissions otherwise the application won't launch.

## Dependencies

This project uses the following packages:
- [country_coder](https://pub.dev/packages/country_coder) which is based on:
    - country-coder 5.2.1 by Quincy Morgan and Bryan Housel, ISC license.
    - which-polygon 2.2.0 by Vladimir Agafonkin, ISC license.
    - lineclip 1.1.5 by Vladimir Agafonkin, ISC license.
- [flag](https://pub.dev/packages/flag)
