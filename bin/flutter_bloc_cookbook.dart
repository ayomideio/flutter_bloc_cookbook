import 'package:args/args.dart';

import 'package:flutter_bloc_cookbook/app-generator.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addCommand('create', _createCommand);

  final args = parser.parse(arguments);
  final command = args.command;
  if (command?.name == 'create') {
    final blocName = command?.rest?.first;
    if (blocName == null) {
      print('Error: Please provide a Bloc name. Usage: flutter_bloc_cookbook create <bloc_name>');
      return;
    }
    await AppGenerator.generateSampleApp(blocName);
    print('Successfully created the Bloc: $blocName');
  } else {
    print('Invalid command. Usage: flutter_bloc_cookbook create <bloc_name>');
  }
}

final _createCommand = ArgParser()
  ..addOption('bloc_name', help: 'Name of the Bloc to create');
