import 'package:fluttr/src/utils.dart';

class ServiceFileContent {
  static Future<String?> get(ServiceParts? target, String? folder) async {
    var instance = ServiceFileContent();
    return switch (target) {
      ServiceParts.manager => await instance.manager(target?.name, folder),
      ServiceParts.provider => await instance.provider(target?.name, folder),
      ServiceParts.service => await instance.mainService(target?.name, folder),
      ServiceParts.url => await instance.url(target?.name, folder),
      _ => null
    };
  }

  Future<String> get _app async => await Utils.getApp;

  Future<String> manager(String? file, String? folder) async => '''
import 'package:${await _app}/services/app_http_request/request_response.dart';
abstract class ${Utils.classFromFile("${folder}_$file.dart")} {
  Future<ApiResponse<dynamic>> functionName(dynamic params);
}''';

  Future<String> provider(String? file, String? folder) async {
    var app = await _app;
    return '''
import 'package:$app/services/app_http_request/request_response.dart';
import 'package:$app/services/$folder/${folder}_${ServiceParts.manager.name}.dart';
import 'package:$app/services/$folder/${folder}_${ServiceParts.url.name}.dart';

class ${Utils.classFromFile("${folder}_$file")} extends ${Utils.classFromFile("${folder}_${ServiceParts.manager.name}")} with ${Utils.classFromFile("${folder}_${ServiceParts.url.name}")} {
  ///Change return type from [dynamic] in [${Utils.classFromFile("${folder}_${ServiceParts.manager.name}")}]
  @override
  Future<ApiResponse<dynamic>> functionName(dynamic params) {
    // TODO: implement functionName
    throw UnimplementedError();
  }
}

///Use [Mock${Utils.classFromFile("${folder}_$file")}] for testing
class Mock${Utils.classFromFile("${folder}_$file")} extends ${Utils.classFromFile("${folder}_${ServiceParts.manager.name}")} {
  @override
  Future<ApiResponse<dynamic>> functionName(dynamic params) {
    // TODO: implement functionName
    throw UnimplementedError();
  }
}
''';
  }

  Future<String> url(String? file, String? folder) async => '''
import 'package:${await _app}/core/environment.dart';
mixin ${Utils.classFromFile("${folder}_$file")} {
  final String baseUrl = AppEnvironment.baseUrl;

  // Add routes here, base url defined
}
''';

  Future<String> mainService(String? file, String? folder) async {
    var app = await _app;
    return '''
import 'package:$app/services/app_http_request/request_response.dart';
import 'package:$app/services/$folder/${folder}_${ServiceParts.manager.name}.dart';
import 'package:$app/services/$folder/${folder}_${ServiceParts.provider.name}.dart';

class ${Utils.classFromFile("${folder}_$file")}<T extends ${Utils.classFromFile("${folder}_${ServiceParts.manager.name}.dart")}> extends ${Utils.classFromFile("${folder}_${ServiceParts.manager.name}")} {
  T provider;
  ${Utils.classFromFile("${folder}_$file.dart")}(this.provider);

  //use this in view model
  static ${Utils.classFromFile("${folder}_$file")} get instance => ${Utils.classFromFile("${folder}_$file")}(${Utils.classFromFile("${folder}_${ServiceParts.provider.name}")}());

  //For testing
  static ${Utils.classFromFile("${folder}_$file")} get mockInstance => ${Utils.classFromFile("${folder}_$file")}(Mock${Utils.classFromFile("${folder}_${ServiceParts.provider.name}")}());

  ///Change return type from [dynamic] in [${Utils.classFromFile("${folder}_${ServiceParts.manager.name}")}]
  @override
  Future<ApiResponse> functionName(dynamic params) {
    // TODO: implement functionName
    throw UnimplementedError();
  }
}
''';
  }
}
