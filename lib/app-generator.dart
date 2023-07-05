import 'dart:io';
import 'package:path/path.dart' as path;

class AppGenerator {
  static Future<void> generateSampleApp(String appName) async {
    final currentDir = Directory.current;
    final appDir = Directory(path.join(currentDir.path, appName));

    if (await appDir.exists()) {
      print('Error: The directory "$appName" already exists.');
      return;
    }

    await Process.run('flutter', ['create', appName]);

    final mainDartFile = File(path.join(appDir.path, 'lib', 'main.dart'));

    if (!await mainDartFile.exists()) {
      print('Error: The "main.dart" file in the newly created app does not exist.');
      return;
    }

    final mainDartContent = await mainDartFile.readAsString();

    if (!mainDartContent.contains('import \'package:flutter_bloc/flutter_bloc.dart\';')) {
      final updatedContent = mainDartContent.replaceFirst(
        'void main() {',
        'import \'package:flutter_bloc/flutter_bloc.dart\';\n\nvoid main() {',
      );

      final blocImplementation = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/counter_bloc.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: MaterialApp(
        home: SamplePage(),
      ),
    );
  }
}

class SamplePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sample Page')),
      body: BlocBuilder<CounterBloc, CounterState>(
        builder: (context, state) {
          return Center(
            child: Text('Count: \${state.count}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterBloc>().add(IncrementEvent()),
        child: Icon(Icons.add),
      ),
    );
  }
}
''';

      final blocDirectory = Directory(path.join(appDir.path, 'lib', 'bloc'));
      await blocDirectory.create(recursive: true);

      await Future.wait([
        mainDartFile.writeAsString(updatedContent + blocImplementation),
        _createBlocStateFile(blocDirectory),
        _createBlocEventFile(blocDirectory),
        _createBlocFile(blocDirectory),
      ]);
    }

    print('Successfully generated the sample app.');
  }

  static Future<void> _createBlocStateFile(Directory blocDirectory) async {
    final stateFile = File(path.join(blocDirectory.path, 'counter_state.dart'));
    if (await stateFile.exists()) return;

    final stateContent = '''
import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int count;

  const CounterState(this.count);

  @override
  List<Object> get props => [count];
}
''';

    await stateFile.writeAsString(stateContent);
  }

  static Future<void> _createBlocEventFile(Directory blocDirectory) async {
    final eventFile = File(path.join(blocDirectory.path, 'counter_event.dart'));
    if (await eventFile.exists()) return;

    final eventContent = '''
import 'package:equatable/equatable.dart';

abstract class CounterEvent extends Equatable {
import 'package:equatable/equatable.dart';

  @override
  List<Object> get props => [];
}

class IncrementEvent extends CounterEvent {}
''';

    await eventFile.writeAsString(eventContent);
  }

  static Future<void> _createBlocFile(Directory blocDirectory) async {
    final blocFile = File(path.join(blocDirectory.path, 'counter_bloc.dart'));
    if (await blocFile.exists()) return;

    final blocContent = '''
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterState(0));

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    if (event is IncrementEvent) {
      yield CounterState(state.count + 1);
    }
  }
}
''';

    await blocFile.writeAsString(blocContent);
  }
}
