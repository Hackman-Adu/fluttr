import 'dart:async';
import 'dart:io';

import 'package:fluttr/src/commands/create/file_content.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class Utils {
  //Manually update this version when changes in pubspec.yaml
  ///[TODO] Use pubspec_parse to get the version
  static String get cliVersion => "1.0.0";

  static List<String> get projectFolders => [
        'core',
        'models',
        'view_models',
        'services',
        'extensions',
        'widgets',
        'views',
        'utils'
      ];

  static List<({String? name, String? content})> filesInCoreFolder(
          String? app) =>
      [
        (name: "router", content: FileContent.router),
        (name: "environment", content: FileContent.appEnvironment),
        (name: "enums", content: FileContent.enumContent),
        (name: "providers", content: FileContent.appProvider),
        (name: "shared_pref", content: FileContent.sharePref(app)),
      ];

  static List<({String? name, String? content})> filesInServicesFolder(
          String? app) =>
      [
        (name: "http_request", content: FileContent.appHttpRequest(app)),
        (name: "request_response", content: FileContent.httpResponse),
        (name: "request_status_codes", content: null),
        (name: "request_type", content: FileContent.httpRequestType(app))
      ];

  static void showLoader(String message) {
    final spinner = ['⠋', '⠙', '⠚', '⠉'];
    int i = 0;
    print(message);
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (i < spinner.length) {
        stdout.write('\r${spinner[i]} ');
        i++;
      } else {
        i = 0;
      }
    });
  }

  static String? classFromFile(String? fileName) {
    var parts =
        fileName?.replaceAll(' ', '').replaceAll(".dart", '').split("_");
    var formatted = parts?.map((e) => "${e[0].toUpperCase()}${e.substring(1)}");
    return formatted?.join("");
  }

  static Future<String> get getApp async {
    final pubspec =
        await File('${Directory.current.path}/pubspec.yaml').readAsString();
    final parsed = Pubspec.parse(pubspec);
    return parsed.name;
  }

  static List<String> get projectDefaultPlatforms => ['android', 'ios'];

  static List<String> get allowedPlatforms =>
      ['ios', 'android', 'windows', 'web', 'macos', 'linux'];

  static List<String> get defaultPackages =>
      ['http', 'flutter_dotenv', 'provider', 'shared_preferences'];
}

enum ServiceParts { manager, service, url, provider }

extension ServicePartsExtension on ServiceParts {
  String get name {
    return switch (this) {
      ServiceParts.manager => "service_manager",
      ServiceParts.service => "service",
      ServiceParts.provider => "service_provider",
      ServiceParts.url => "service_url"
    };
  }
}
