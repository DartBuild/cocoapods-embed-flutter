# cocoapods-embed-flutter

[![Gem Version](https://badge.fury.io/rb/cocoapods-embed-flutter.svg)](http://badge.fury.io/rb/cocoapods-embed-flutter)
<!--- [![Code Climate](https://codeclimate.com/github/DartBuild/cocoapods-embed-flutter.png)](https://codeclimate.com/github/DartBuild/cocoapods-embed-flutter) -->

Straight forward way of declaring flutter modules as dependency for targets, just like cocoapods does with pods.

## Installation

```bash
$ [sudo] gem install cocoapods-embed-flutter
```

## Usage

In your host project `Podfile`, write the below line before any target definition
```rb
plugin 'cocoapods-embed-flutter'
```

### Embedding module from a local path.

```rb
pub 'flutter_module', :path => '../'
```

*`:path` can be path pointing to `pubspec.yaml` or to the directory containing `pubspec.yaml` or to the directory containg flutter module.*

### Embedding module from a repository.

```rb
pub 'flutter_module', :git => 'https://github.com/gowalla/flutter_module.git', :branch => 'dev'
pub 'flutter_module', :git => 'https://github.com/gowalla/flutter_module.git', :tag => '0.7.0'
pub 'flutter_module', :git => 'https://github.com/gowalla/flutter_module.git', :commit => '082f8319af'
```
