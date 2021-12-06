dart --version
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze
dart run build_runner build --delete-conflicting-outputs
dart test --coverage=./coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage
brew install lcov
genhtml -o ./coverage/report ./coverage/lcov.info
brew install http-server
http-server coverage/report 8080