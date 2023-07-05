import 'package:args/args.dart';
import 'package:flutter_bloc_cookbook/app-generator.dart';


void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('name',
      abbr: 'n', help: 'The name of the Flutter app to create.');

  final argResults = parser.parse(arguments);

  final appName = argResults['name'] as String?;
  if (appName == null) {
    print(
        'Error: The name of the app is required. Usage: create_flutter_app -n <app_name>');
    return;
  }

  await AppGenerator.generateSampleApp(appName);
}
