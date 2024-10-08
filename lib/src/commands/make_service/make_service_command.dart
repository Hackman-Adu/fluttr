import 'dart:io';

import 'package:fluttr/src/command_manager.dart';
import 'package:fluttr/src/commands/make_service/service_file_content.dart';
import 'package:fluttr/src/utils.dart';

class MakeServiceCommand extends CommandManager {
  @override
  String get description => "Command to create a service folder e.g auth";

  @override
  void execute(List<String> arguments) async {
    if (arguments.isEmpty) {
      print("Please specify service name e.g auth");
      return;
    }
    if (arguments.length > 1) {
      print("Invalid option or command");
      return;
    }
    this.arguments = arguments;
    await Future.forEach(arguments.first.split(','), (e) async {
      if (e.isEmpty) return;
      e = e.toLowerCase().replaceAll("_", "").replaceAll("service", "");
      await _createServiceFolder(e);
    });
    exit(0);
  }

  List<({String? folder, ServiceParts? part})> _serviceFiles(String? folder) {
    var files = ServiceParts.values.toList();
    return files.map((part) => (folder: folder, part: part)).toList();
  }

  Future<void> _createFilesContent(Directory dir, String? folder) async {
    var serviceFiles = _serviceFiles(folder);
    await Future.forEach(serviceFiles, (target) async {
      var file = File("${dir.path}/${target.folder}_${target.part?.name}.dart");
      if (!await file.exists()) await file.create();
    });
    await Future.forEach(serviceFiles, (target) async {
      var file = File("${dir.path}/${target.folder}_${target.part?.name}.dart");
      String? content = await ServiceFileContent.get(target.part, folder);
      if (content != null) await file.writeAsString(content);
    });
  }

  Future<void> _createServiceFolder(String? folder) async {
    Utils.showLoader("Creating Service");
    var serviceDir = Directory("${Directory.current.path}/lib/services");
    if (!await serviceDir.exists()) return;
    var httpFolder = Directory("${serviceDir.path}/app_http_request");
    if (!await httpFolder.exists()) return;
    var directory = Directory("${serviceDir.path}/$folder");
    if (await directory.exists()) {
      print("$folder Service Already Exists");
      return;
    }
    await directory.create();
    await _createFilesContent(directory, folder);
    print("✅️✅️✅️$folder Service Created Successfully");
  }

  @override
  String get name => "make:service";
}
