import 'dart:io';

import 'package:fluttr/src/command_manager.dart';
import 'package:fluttr/src/utils.dart';

class MakeViewModelCommand extends CommandManager {
  @override
  String get description => "Command to create a view_model e.g auth";

  String get currentPath => Directory.current.path;

  Future<void> _addViewModelToAppProviders(String fileName) async {
    var providerFile =
        File("${Directory.current.path}/lib/core/providers.dart");
    var content = await providerFile.readAsString();
    var importStatement =
        '''import 'package:${await Utils.getApp}/view_models/$fileName';''';
    if (!content.contains(importStatement)) {
      int importIndex = content.lastIndexOf("import");
      if (importIndex != -1) {
        int endOfImports = content.indexOf(";", importIndex) + 1;
        content =
            "${content.substring(0, endOfImports)}\n$importStatement${content.substring(endOfImports)}";
      } else {
        content = "$importStatement\n$content";
      }
    }
    String providerItem =
        '''ChangeNotifierProvider<${Utils.classFromFile(fileName)}>(
            create: (context) => ${Utils.classFromFile(fileName)}()),''';
    if (!content.contains(providerItem)) {
      int providersIndex = content.indexOf("providers => [");
      if (providersIndex != -1) {
        int listEndIndex = content.indexOf("];", providersIndex);
        if (listEndIndex != -1) {
          content =
              "${content.substring(0, listEndIndex)}  $providerItem\n${content.substring(listEndIndex)}";
        }
      }
      await providerFile.writeAsString(content);
    }
  }

  @override
  void execute(List<String> arguments) async {
    if (arguments.isEmpty) {
      print("Please specify view model name e.g auth");
      return;
    }
    if (arguments.length > 1) {
      print("Invalid option or command");
      return;
    }
    this.arguments = arguments;
    await Future.forEach(this.arguments.first.split(','),
        (e) async => await _createViewModel("${e}_view_model.dart"));
    exit(0);
  }

  Future<void> _createViewModel(String fileName) async {
    var dir = Directory("$currentPath/lib/view_models");
    if (!await dir.exists()) await dir.create();
    var file = File("${dir.path}/$fileName");
    if (await file.exists()) {
      print("${fileName.replaceAll('.dart', '')} already exists");
      return;
    }
    await file.create();
    await file.writeAsString(
        '''import 'package:${await Utils.getApp}/view_models/base_view_model.dart';
    class ${Utils.classFromFile(fileName)} extends BaseViewModel{}''');
    await _addViewModelToAppProviders(fileName);
    print("✅️✅️✅️${Utils.classFromFile(fileName)} Created Successfully");
  }

  @override
  String get name => "make:view_model";
}
