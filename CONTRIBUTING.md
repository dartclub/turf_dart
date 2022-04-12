# Contributiung to Turf.dart

Welcome and thank you for deciding to contribute to the project!

Here is how cooperation works perfectly at [Turf Dart](https://github.com/dartclub/turf_dart)
#### Table of Contents
  - [Code of Conduct](#code-of-conduct)
  - [Get started](#get-started)
  - [Implementation Process](#implementation-process)
  - [Documentation](#documentation)

## Code of conduct
By participating, you are expected to uphold international human rights and fundamental freedoms!
To put it simply, be kind to each other. 

## Get started
- Get the [tools](https://dart.dev/tools)
- Clone the repository: ```git clone git@github.com:dartclub/turf_dart.git```
- Navigate to project's folder in terminal & get its dependencies:  ```Dart pub get```
- Go through [Implementation Process](#implementation-process)

## Implementation process
- Check the Backlog/Issues for similar issues
- Create a new branch _feature-_ from _main_
- Create a _draft Pull request_, mention in it the associated issues
- **Implement**
  - Document everything [properly](#documentation)
  - **Write [tests](https://dart.dev/guides/testing)**―Keep an eye on [Turfjs'](https://github.com/Turfjs/turf) implementation
    - run the the test: ```dart test test/components/XXX.dart```
  - **Write [benchmarks](https://pub.dev/packages/benchmark)**―have a look at our [implementation](https://github.com/dartclub/turf_dart/tree/main/benchmark)
    - run the benchmark: ```pub run benchmark```
- Commit
- Convert to real Pull request _ready for review_
- Code review / mention a reviewer from [contributors list](https://github.com/dartclub/turf_dart/graphs/contributors) 


## Documentation
We follow [Effective Dart](https://dart.dev/guides/language/effective-dart/documentation) guidelines for documentation.

After going through the [Implementation Process](#implementation-process), please mention the made changes in [README.md](https://github.com/dartclub/turf_dart/blob/main/README.md)

In order to add to this very documentation, please develop CONTRIBUTING.md in [documentation branch](https://github.com/dartclub/turf_dart/tree/documentation)
