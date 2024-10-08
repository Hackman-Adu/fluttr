import 'package:args/args.dart';

abstract class CommandManager {
  ArgParser parser = ArgParser();

  String get description;

  String get name;

  List<String> arguments = [];

  void execute(List<String> arguments);
}
