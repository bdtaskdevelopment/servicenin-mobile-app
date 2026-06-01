import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart' as connectivity;
import 'package:servicenin/app/core/values/app_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import '../../../core/helpers/app_helper.dart';
import '../../../core/values/storage.dart';
import '../../../routes/app_pages.dart';
import '../../services/storage.service.dart';

bool _isHandling401 = false;

FutureOr<dynamic> responseInterceptor(
    Request request, Response response) async {
  printLog('Response received for 44 ${request.url.path}: ${response.statusCode} ::');
  printLog('Response received for ${ApiURL.login}: ${response.statusCode} ::');
  EasyLoading.dismiss();
  responseLogger(response);
  if (await checkInternetConnection()) {
    if (![200, 201, 204].contains(response.statusCode)) {
     if (response.statusCode == 401 &&
    !request.url.toString().contains(ApiURL.login)) {
        if (!_isHandling401) {
          _isHandling401 = true;
          StorageService.remove(StorageConstants.accessToken);
          Helpers.toastError("Session expired. Please log in again.");
          Get.offAllNamed(Routes.AUTH);
          Future.delayed(const Duration(seconds: 2), () => _isHandling401 = false);
        }
        throw Exception("Session expired. Please log in again.");
      }
      printWrapped( "Non-success status code ${response.statusCode} received. Handling error status.");
      // Silently ignore wallet/balance errors (e.g. new users without a wallet yet)
      handleErrorStatus(response);
      return response;
    }
    return response;
  } else {
    Helpers.toastSuccess("Internet connection failed !");
  }
}

Future<bool> checkInternetConnection() async {
  final results = await connectivity.Connectivity().checkConnectivity();

  return results.any((r) =>
  r == connectivity.ConnectivityResult.mobile ||
      r == connectivity.ConnectivityResult.wifi ||
      (!GetPlatform.isAndroid &&
          r == connectivity.ConnectivityResult.vpn));
}

void handleErrorStatus(Response response) {
  try {
    final body = response.body;

    printWrapped( "Handling error status ${response.statusCode} with body: $body");

    switch (response.statusCode) {

      case 400:
      case 402:
      case 401:
      case 422:
      case 429:
        {
          printWrapped( "Error status1231 ${response.statusCode} detected. Extracting message from body.");
          final message = Helpers.extractErrorMessage(body);
          Helpers.toastError(message);
          break;
        }

      case 403:
        {
          final message = body?["message"] ?? "Access denied";
          Helpers.toastError(message.toString());
          break;
        }

      case 404:
        {
          Helpers.toastError("Server not found");
          break;
        }
      case 500:
        {
          final message = Helpers.extractErrorMessage(body);
          Helpers.toastError(message);
          break;
        }

      default:
        {
          Helpers.toastError("Something went wrong!");
          break;
        }
    }
  } catch (e) {
    Helpers.toastError("Unexpected error occurred");
  }
}


// void handleErrorStatus(Response response) {
//   switch (response.statusCode) {
//     case 404:
//       Helpers.toastError("Server Error");
//       break;
//     case 400:
//       print(" ppppp---${response.body["status"]}");
//       final message = (response.body["message"]);
//       Helpers.extractErrorMessage(res.body)
//     case 402:
//     print(" ppppp---${response.body["status"]}");
//     final message = (response.body["message"]);
//     Helpers.toastError(message);
//     case 429:
//     print(" ppppp---${response.body["status"]}");
//     final message = (response.body["message"]);
//     Helpers.toastError(message);
//     case 422:
//       print(" ppppp---${response.body["status"]}");
//       final message = (response.body["message"]);
//       Helpers.toastError(message);
//       break;
//     case 403:
//       print(" ppppp---${response.body["status"]}");
//       final message = (response.body["message"]);
//       Helpers.toastError(message);
//       break;
//     case 500:
//       try {
//         final decoded = jsonDecode(response.body);
//
//         if (decoded is Map && decoded.containsKey("message")) {
//           Helpers.toastError(decoded["message"]);
//         } else {
//           Helpers.toastError("Server error");
//         }
//       } catch (e) {
//         final body = response.body;
//
//         if (body is Map<String, dynamic>) {
//           Helpers.toastError(
//             body["message"]?.toString() ?? "Server error",
//           );
//         } else if (body is String) {
//           Helpers.toastError(body); // already string error
//         } else {
//           Helpers.toastError("Server error");
//         }
//       }
//     default:
//       final message = ("Something went wrong!");
//     Helpers.toastError(message);
//   }
// }

void responseLogger(Response response) {
  debugPrint('Status Code: ${response.statusCode}\n');
  debugPrint('Data: ${response.bodyString?.toString() ?? ''}');
}
