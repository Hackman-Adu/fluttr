import 'dart:convert';
import 'dart:io';

import 'package:fluttr/src/command_manager.dart';

class UpdateCommand extends CommandManager {
  @override
  String get description => "Update the CLI to the latest version";

  @override
  void execute(List<String> arguments) async {
    if (arguments.isNotEmpty) {
      print("Invalid option or command");
      return;
    }
    final process = await Process.start(
        'dart', ['pub', 'global', 'activate', 'itc_flutter']);
    process.stdout.transform(utf8.decoder).listen((data) {
      List lines = data.split("\n");
      for (String line in lines) {
        if (line.isNotEmpty) {
          stdout.writeln(line);
        }
      }
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      List lines = data.split("\n");
      for (String line in lines) {
        if (line.isNotEmpty) {
          stdout.writeln(line);
        }
      }
    });
  }

  @override
  String get name => "upgrade";
}
