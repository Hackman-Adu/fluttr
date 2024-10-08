class FileContent {
  static String get env => '''
API_LIVE_URL=

API_UAT_URL=

LIVE_API_KEY=

UAT_API_KEY=

TIMED_OUT_DURATION=30

PRODUCTION=false

''';

  static String get appEnvironment => '''
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static bool inProduction = dotenv.get('PRODUCTION') == 'true';

  static num get dataLimit => 100;

  static String baseUrl =
      inProduction ? dotenv.get('API_LIVE_URL') : dotenv.get('API_UAT_URL');

  static String get apiKey =>
      inProduction ? dotenv.get('LIVE_API_KEY') : dotenv.get('UAT_API_KEY');

  static Duration timedOutDuration =
      Duration(seconds: int.parse(dotenv.get('TIMED_OUT_DURATION')));

  static dynamic noAuthHeader = {
    "Content-type": "application/json",
    "Accept": "application/json"
  };

  dynamic get authHeader => {
        "Content-type": "application/json",
        "Accept": "application/json",
        //Insert bearer token here
        "Authorization": "Bearer token here"
      };

  //Add other env stuff
}


''';

  static String httpRequestType(String? app) => '''

import 'package:http/http.dart' as client;
import 'package:$app/core/environment.dart';
enum RequestType { get, post, patch, delete, put }

extension RequestTypeExtension on RequestType {
  Future<client.Response?>? getResponse(String urlString, dynamic header,
      {Object? body}) async {
    var url = Uri.parse(urlString);
    return switch (this) {
      RequestType.get => await client
          .get(url, headers: header)
          .timeout(AppEnvironment.timedOutDuration),
      RequestType.post => await client
          .post(url, body: body, headers: header)
          .timeout(AppEnvironment.timedOutDuration),
      RequestType.put => await client
          .put(url, body: body, headers: header)
          .timeout(AppEnvironment.timedOutDuration),
      RequestType.patch => await client
          .patch(url, body: body, headers: header)
          .timeout(AppEnvironment.timedOutDuration),
      RequestType.delete => await client
          .delete(url, body: body, headers: header)
          .timeout(AppEnvironment.timedOutDuration)
    };
  }
}



''';

  static String get httpResponse => '''class ApiResponse<T extends Object?> {
  ({Failure? failure, Success<T>? success})? response;
  ApiResponse({this.response});

  factory ApiResponse.failure(Failure? failure) {
    return ApiResponse(response: (failure: failure, success: null));
  }

  factory ApiResponse.failureFromResponse(Object? erroMessage) {
    return ApiResponse(response: (
      failure: Failure(message: erroMessage?.toString()),
      success: null
    ));
  }

  bool get isSuccess => response?.failure == null;

  T? get data => response?.success?.data;

  Failure? get failure => response?.failure;
}

class Success<T extends Object?> {
  T? data;
  Success({this.data});
}

class Failure {
  String? message;
  num? statusCode;
  Failure({this.statusCode, this.message});

  factory Failure.timedOut() {
    return Failure(
        message:
            "Your request has timed out due network error. Kindly try again");
  }

  factory Failure.updateRequired() => Failure(message: "out_of_date");

  factory Failure.unKnownError() {
    return Failure(
        message:
            "Oops! Something went wrong on our end. Please try again later");
  }

  factory Failure.networkError() {
    return Failure(
        message:
            "It looks like you're offline. Please check your connection and try again");
  }

  factory Failure.serverError() {
    return Failure(
        message:
            "Oops! Something went wrong on our end. Please try again later");
  }
}

''';

  static String appHttpRequest(String? app) => '''import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:$app/services/app_http_request/request_response.dart';
import 'package:$app/services/app_http_request/request_type.dart';
import 'package:http/http.dart' as client;

class AppHttpRequest {
  RequestType? type;
  String? body;
  String url;
  Map<String, dynamic>? header;
  AppHttpRequest(this.type, this.url, this.header, {this.body});

  void _printRequest({client.Response? response, String? error}) {
    var map = {
      "request": type?.name.toUpperCase(),
      "url": url,
      "header": header,
      "status Code": response?.statusCode,
      if (body != null) "body": json.decode(body ?? "{}"),
      if (response != null) "response": _decodeResponse(response),
      "response_raw": response?.body,
      if (error != null) "error": error
    };
    if (kDebugMode) {
    print(
          "✨✨✨✨✨✨✨✨✨✨ {type?.name.toUpperCase()} REQUEST ✨✨✨✨✨✨✨✨✨✨ {json.encode(map)}");
    }
  }

  dynamic _decodeResponse(client.Response? response) {
    try {
      return json.decode(response?.body ?? "{}");
    } catch (e) {
      return null;
    }
  }

  ApiResponse<Map<String, dynamic>>? _getReturnBody(client.Response? response) {
    _printRequest(response: response);
    if (response?.statusCode == 200) {
      return ApiResponse(response: (
        failure: null,
        success: Success(data: _decodeResponse(response) ?? {})
      ));
    }
    if (response?.statusCode == 502) {
      return ApiResponse.failure(Failure.serverError());
    }
    return ApiResponse.failureFromResponse(response?.body);
  }

  Future<ApiResponse<Map<String, dynamic>>?>? run() async {
    try {
      var response = await type?.getResponse(url, header, body: body);
      return _getReturnBody(response);
    } on HttpException catch (e) {
      _printRequest(error: e.toString());
      return ApiResponse.failure(Failure.networkError());
    } on SocketException catch (e) {
      _printRequest(error: e.toString());
      return ApiResponse.failure(Failure.networkError());
    } on FormatException catch (e) {
      _printRequest(error: e.toString());
      return ApiResponse.failure(Failure.unKnownError());
    } on TimeoutException catch (e) {
      _printRequest(error: e.toString());
      return ApiResponse.failure(Failure.timedOut());
    } catch (e) {
      _printRequest(error: e.toString());
      return ApiResponse.failure(Failure.unKnownError());
    }
  }
}

''';

  static String main(String? displayName, String? app) =>
      '''import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:$app/core/providers.dart';
import 'package:$app/core/shared_pref.dart';
import 'package:$app/core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  AppSharedPref.sharePref = await SharedPreferences.getInstance();
   runApp(MultiProvider(
      providers: AppProviders.providers, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '$displayName',
        navigatorKey: AppRouter.navigator,
        home: Scaffold(body: Center(child: Text("Created with fluttr CLI"))));
  }
}
''';

  static String get baseViewModel => '''
import 'package:flutter/material.dart';
class BaseViewModel extends ChangeNotifier{
  // Content goes here
}


''';

  static String get appProvider => '''
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
class AppProviders {
  static List<SingleChildWidget> get providers => [
      ];
}''';

  static String get router => '''import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();

  static BuildContext get context => navigator.currentContext!;

  static Future<dynamic> navigate(Widget destination) async {
    return await Navigator.of(context).push(Platform.isIOS
        ? CupertinoPageRoute(builder: (context) => destination)
        : MaterialPageRoute(builder: (context) => destination));
  }

  static Future navigateAndPopAll(Widget destination) async {
    return await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => destination), (route) => false);
  }

  static Future openPageAsModal(Widget destination) async {
    return await Navigator.of(context).push(
        CustomCupertinoModalPopupRoute(builder: (context) => destination));
  }
}

class CustomCupertinoModalPopupRoute extends CupertinoModalPopupRoute {
  CustomCupertinoModalPopupRoute({required super.builder});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 650);
}
''';

  static String get enumContent => '''
// Define other keys here
enum SharePrefKey {user}

''';

  static String sharePref(String? app) => '''
import 'package:$app/core/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPref {
  static late SharedPreferences sharePref;

  static Future setValueString(SharePrefKey key, String value) async {
    await sharePref.setString(key.name, value);
  }

  static Future setValueBool(SharePrefKey key, bool value) async {
    await sharePref.setBool(key.name, value);
  }

  static Future<String?> getValueString(SharePrefKey key) async {
    return sharePref.getString(key.name);
  }

  static Future<bool?> getValueBool(SharePrefKey key) async {
    return sharePref.getBool(key.name);
  }

  static Future clearKey(SharePrefKey key) async {
    await sharePref.remove(key.name);
  }

  static Future clear() async {
    await sharePref.clear();
  }
}

''';
}
