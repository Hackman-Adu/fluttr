import 'dart:io';

import 'package:args/args.dart';
import 'package:fluttr/src/command_manager.dart';
import 'package:fluttr/src/commands/create/file_content.dart';
import 'package:fluttr/src/utils.dart';

class CreateAppCommand extends CommandManager {
  Directory get projectlibFolder => Directory("$projectName/lib");

  Directory get servicesDir => Directory("${projectlibFolder.path}/services");

  String get appName => argResults?['name'] ?? projectName;

  String? get projectName => argResults?.arguments.firstOrNull;

  List<String> get folders => argResults?['folders'];

  List<String> get platforms => argResults?['platforms'];

  ArgResults? argResults;

  @override
  void execute(List<String> arguments) async {
    this.arguments = arguments;
    parser = ArgParser()
      ..addOption('org',
          mandatory: true, abbr: 'o', help: 'The organization (package) name')
      ..addMultiOption('platforms',
          abbr: 'p',
          allowed: Utils.allowedPlatforms,
          help: 'Target platforms for the app',
          defaultsTo: Utils.projectDefaultPlatforms)
      ..addMultiOption('folders',
          defaultsTo: Utils.projectFolders,
          abbr: 'f',
          help: 'List of folders to create in lib/')
      ..addOption('name',
          abbr: 'd', help: 'Name for the app', defaultsTo: projectName)
      ..addFlag('help', abbr: 'h', negatable: false, help: 'Displays help');
    argResults = parser.parse(this.arguments);
    if (arguments.isEmpty || argResults?['help'] as bool) {
      print('Basic Tips\n${parser.usage}');
      return;
    }
    await _run();
  }

  List<Future Function()> get _processes => [
        _checkIfFlutterSDKInstalled,
        _checkIfProjectAlreadyExists,
        _runFlutterCreate,
        _createProjectStructure,
        _createEnvFile,
        _createFilesInCoreFolder,
        _createFilesInServices,
        _createMainFileContent,
        _createBaseViewModelFile,
        _runDefaultProcesses,
        _installDefaultPackages
      ];

  Future<void> _run() async {
    await Future.forEach(_processes, (process) async => await process.call());
    print("✅️✅️✅️Set Up Completed Successfully✅️✅️✅️");
    exit(0);
  }

  Future<void> _createFilesInServices() async {
    var main = Directory('${projectlibFolder.path}/services');
    if (!await main.exists()) return;
    var target = Directory("${main.path}/app_http_request");
    await target.create();
    await Future.forEach(Utils.filesInServicesFolder(projectName), (f) async {
      var file = File("${target.path}/${f.name}.dart");
      if (!await file.exists()) await file.create();
      if (f.content != null) await file.writeAsString(f.content!);
    });
  }

  Future<void> _createFilesInCoreFolder() async {
    var coreFolder = Directory('${projectlibFolder.path}/core');
    if (!await coreFolder.exists()) return;
    await Future.forEach(Utils.filesInCoreFolder(projectName), (f) async {
      var file = File("${coreFolder.path}/${f.name}.dart");
      if (!await file.exists()) await file.create();
      if (f.content != null) await file.writeAsString(f.content!);
    });
  }

  Future<void> _runProcess(String arg) async {
    await Process.run('fluttr', [arg, 'auth'], workingDirectory: projectName);
  }

  Future<void> _runDefaultProcesses() async {
    List<Future Function()> processes = [
      () async => await _runProcess("make:view_model"),
      () async => await _runProcess("make:service"),
      () async => await _runProcess("make:model")
    ];
    await Future.forEach(processes, (process) async => await process.call());
  }

  Future<bool> _checkIfFlutterSDKInstalled() async {
    try {
      Utils.showLoader("Checking Flutter SDK");
      var result = await Process.run('flutter', ['--version']);
      if (result.exitCode != 0) {
        print(
            "Flutter SDK is not installed. Kindy install the SDK and try again");
        exit(0);
      }
      print("✅️Flutter SDK Found!");
      return true;
    } catch (e) {
      print("Error Occured: ${e.toString()}");
      exit(0);
    }
  }

  Future<void> _createEnvFile() async {
    try {
      var root = Directory("$projectName");
      File envFile = File("${root.path}/.env");
      if (!await envFile.exists()) envFile.create();
      await envFile.writeAsString(FileContent.env);
    } catch (e) {
      print("Failed to create env file ${e.toString()}");
    }
  }

  Future<void> _createMainFileContent() async {
    try {
      var file = File("${projectlibFolder.path}/main.dart");
      await file.writeAsString(FileContent.main(appName, projectName));
    } catch (e) {
      print("Failed to create main.dart file content ${e.toString()}");
    }
  }

  Future<void> _createBaseViewModelFile() async {
    try {
      var dir = Directory("${projectlibFolder.path}/view_models");
      if (!await dir.exists()) return;
      var file = File("${dir.path}/base_view_model.dart");
      await file.create();
      await file.writeAsString(FileContent.baseViewModel);
    } catch (e) {
      print("Failed to create file content ${e.toString()}");
    }
  }

  Future<bool> _createProjectStructure() async {
    Utils.showLoader("Creating structure");
    await Future.forEach(folders, (folder) async {
      var dir = Directory('${projectlibFolder.path}/$folder');
      if (!await dir.exists()) {
        try {
          await dir.create(recursive: true);
        } catch (e) {
          print(
              'Failed to create project structure --- ${dir.path}: ${e.toString()}');
          exit(0);
        }
      }
    });
    return true;
  }

  List<String> get _flutterCreateArgs => [
        'create',
        projectName!,
        '--org',
        argResults?['org'],
        '--platforms',
        platforms.join(',')
      ];

  Future<bool> _runFlutterCreate() async {
    try {
      Utils.showLoader("Creating project $projectName");
      var results = await Process.run('flutter', _flutterCreateArgs);
      if (results.exitCode != 0) {
        print("Failed to create project: ${results.stderr}");
        exit(0);
      }
      return true;
    } catch (e) {
      print("Failed to create project: ${e.toString()}");
      exit(0);
    }
  }

  Future<bool> _checkIfProjectAlreadyExists() async {
    var directory = Directory("$projectName");
    var projectExists = await directory.exists();
    if (projectExists) {
      print("Project already exists");
      exit(0);
    }
    return true;
  }

  Future<void> _installDefaultPackages() async {
    var results = await Process.run(
        'flutter', ['pub', 'add', ...Utils.defaultPackages],
        workingDirectory: '$projectName');
    if (results.exitCode != 0) {
      print("Failed to install dependencies ${results.stderr}");
      exit(0);
    }
  }

  @override
  String get description =>
      "Create a new Flutter project using defined structure";

  @override
  String get name => "create";
}
