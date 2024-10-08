import 'dart:io';

import 'package:fluttr/src/command_manager.dart';
import 'package:fluttr/src/commands/create/create_app_command.dart';
import 'package:fluttr/src/commands/make_model/make_model_command.dart';
import 'package:fluttr/src/commands/make_service/make_service_command.dart';
import 'package:fluttr/src/commands/make_view_model/make_view_model_command.dart';
import 'package:fluttr/src/commands/update/update_command.dart';
import 'package:fluttr/src/utils.dart';

class CommandService {
  List<String> excludesCommands = ['create', 'upgrade'];
  final Map<String, CommandManager> _commands = {
    "create": CreateAppCommand(),
    "upgrade": UpdateCommand(),
    "make:service": MakeServiceCommand(),
    "make:view_model": MakeViewModelCommand(),
    "make:model": MakeModelCommand()
  };

  List<String> get _versionCommands => ['-v', '--version', '--v'];

  void run(List<String> arguments) async {
    if (arguments.isEmpty) {
      print("-V, --version ---------- Display the CLI Version");
      _commands.forEach((name, command) {
        print("$name ---------- ${command.description}");
      });
      return;
    }
    var commandName = arguments[0].toString().toLowerCase();
    if (_versionCommands.contains(commandName)) {
      print('CLI Version: ${Utils.cliVersion}');
      return;
    }
    final CommandManager? command = _commands[commandName];
    if (command == null) {
      print("Invalid command");
      exit(0);
    }
    var directory = Directory("${Directory.current.path}/lib");
    if (!directory.existsSync() && !excludesCommands.contains(command.name)) {
      print(
          "Please run the command fluttr <${command.name}> in the project root directory");
      exit(0);
    }
    //  Ignoring the first argument e.g create, first argument regarded as the command
    command.execute(arguments.sublist(1));
  }
}
