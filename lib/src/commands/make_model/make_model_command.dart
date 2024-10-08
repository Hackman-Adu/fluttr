import 'dart:io';

import 'package:fluttr/src/command_manager.dart';
import 'package:fluttr/src/utils.dart';

class MakeModelCommand extends CommandManager {
  @override
  String get description => "Command to create a model e.g auth";

  String get currentPath => Directory.current.path;

  @override
  void execute(List<String> arguments) async {
    if (arguments.isEmpty) {
      print("Please specify model name e.g auth");
      return;
    }
    if (arguments.length > 1) {
      print("Invalid option or command");
      return;
    }
    this.arguments = arguments;
    await Future.forEach(this.arguments.first.split(','), (e) async {
      if (e.isEmpty) return;
      await _createModel("${e}_model.dart");
    });
    exit(0);
  }

  Future<void> _createModel(String fileName) async {
    var dir = Directory("$currentPath/lib/models");
    if (!await dir.exists()) await dir.create();
    var file = File("${dir.path}/$fileName");
    if (await file.exists()) {
      print("${Utils.classFromFile(fileName)} Already Exists");
      exit(0);
    }
    await file.create();
    await file.writeAsString('''class ${Utils.classFromFile(fileName)}{}''');
    print("✅️✅️✅️${Utils.classFromFile(fileName)} Created Successfully");
  }

  @override
  String get name => "make:model";
}
