# cocoapods-embed-flutter

[![CI/CD](https://github.com/DartBuild/cocoapods-embed-flutter/actions/workflows/main.yml/badge.svg?branch=main&event=push)](https://github.com/DartBuild/cocoapods-embed-flutter/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/cocoapods-embed-flutter.svg)](http://badge.fury.io/rb/cocoapods-embed-flutter)
[![Code Climate](https://codeclimate.com/github/DartBuild/cocoapods-embed-flutter.png)](https://codeclimate.com/github/DartBuild/cocoapods-embed-flutter)

Straight forward way of declaring flutter modules as dependency for targets, just like cocoapods does with pods.

## Installation

### Install using command line.
```bash
$ [sudo] gem install cocoapods-embed-flutter
```

### Or add this to your `Gemfile`.
```rb
gem 'cocoapods-embed-flutter'
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

## Links

| Link | Description |
| :----- | :------ |
[Gem page](https://rubygems.org/gems/cocoapods-embed-flutter) | Official Ruby Gems page.
[Code docs](https://www.rubydoc.info/gems/cocoapods-embed-flutter) | Generated code documentation.
[Changelog](https://github.com/DartBuild/cocoapods-embed-flutter/blob/main/CHANGELOG.md) | See the changes introduced in each version.
[Code of Conduct](CODE_OF_CONDUCT.md) | Find out the standards we hold ourselves to.
