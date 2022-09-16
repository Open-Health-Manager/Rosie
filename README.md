# Rosie

![Rosie, the Rosie mascot](assets/pdm_comic_avatar.png)
Rosie health manager app for the Open Health Manager.

## Getting Started

Rosie is built using [Flutter](https://flutter.dev/). Rosie currently primarily
targets iOS but the Flutter project can be compiled to other platforms.

To build Rosie, first [install
Flutter](https://docs.flutter.dev/get-started/install).

### Building on macOS

Building the iOS version requires a few additional pieces of software to build
the various assets used within iOS:

- [Inkscape](https://inkscape.org/) needs to be installed with the `inkscape`
  command line utility on the `PATH`
- zopflipng (part of [zopfli](https://github.com/google/zopfli)) needs to be
  installed

Both of these can easily be installed via [Homebrew/Homebrew casks](https://brew.sh/):

```sh
brew install inkscape zopfli
```

Flutter itself can also be installed via Homebrew. However, they can also be
installed manually, as long as the command line utilities are placed within a
directory that's on the `PATH`.

## Running Rosie

Rosie requires an instance of the [Open Health
Manager](https://github.com/Open-Health-Manager/open-health-manager) running as
the backend. With that running, Rosie can be pointed to use it via the
configuration files within `assets/config`. A custom local configuration can be
created in `assets/config/config.local.json` based on
[`assets/config/config.json`](assets/config/config.json) to point to a given
Open Health Manager instance. The default configuration uses
`http://localhost:8080/` and does not include an API key for the [US
Preventative Services Task
Force](https://www.uspreventiveservicestaskforce.org/uspstf/) API.

Once configured, Rosie can be built and run using the `flutter` command:

```sh
flutter run
```

To run within the iOS Simulator, simply make sure the simulator is running
before using `flutter run`. Flutter will ask what device to use.

To use Rosie as a web app, please make sure to specify that it use port 57757,
as this is the localhost port that is CORS-whitelisted within the development
version of the Open Health Manager. This can be done via:

```sh
flutter run -d chrome --web-port 57757
```

## Generating Code

The easiest way to generate the required code is by simply triggering a build,
such as via `flutter run`. However, if you want to start developing prior to
running the app, and wish to ensure that all the necessary generated code
exists, you can run the following commands:

```sh
flutter gen-l10n
```