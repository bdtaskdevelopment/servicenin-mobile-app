import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_sslcommerz/model/SSLCEMITransactionInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCShipmentInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/SSLCProductInitializer.dart';
import 'model/SSLCAdditionalInitializer.dart';
import 'model/SSLCCustomerInfoInitializer.dart';
part 'sslcommerz.g.dart';

@JsonSerializable()
class Sslcommerz {
  late SSLCommerzInitialization initializer;
  SSLCCustomerInfoInitializer? customerInfoInitializer;
  SSLCEMITransactionInitializer? sslcemiTransactionInitializer;
  SSLCShipmentInfoInitializer? sslcShipmentInfoInitializer;
  SSLCProductInitializer? sslcProductInitializer;
  SSLCAdditionalInitializer? sslcAdditionalInitializer;

  //for only IOS test Purpose
  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  //***********************/
  Sslcommerz({required SSLCommerzInitialization initializer}) {
    this.initializer = initializer;
  }

  static const MethodChannel _channel = const MethodChannel(
    'flutter_sslcommerz',
  );

  Map<String, dynamic> toJson() => _$SslcommerzToJson(this);

  factory Sslcommerz.fromJson(Map<String, dynamic> json) =>
      _$SslcommerzFromJson(json);

  Sslcommerz addCustomerInfoInitializer({
    required SSLCCustomerInfoInitializer customerInfoInitializer,
  }) {
    this.customerInfoInitializer = customerInfoInitializer;
    return this;
  }

  Sslcommerz addEMITransactionInitializer({
    required SSLCEMITransactionInitializer? sslcemiTransactionInitializer,
  }) {
    this.sslcemiTransactionInitializer = sslcemiTransactionInitializer;
    return this;
  }

  Sslcommerz addShipmentInfoInitializer({
    required SSLCShipmentInfoInitializer? sslcShipmentInfoInitializer,
  }) {
    this.sslcShipmentInfoInitializer = sslcShipmentInfoInitializer;
    return this;
  }

  Sslcommerz addProductInitializer({
    required SSLCProductInitializer? sslcProductInitializer,
  }) {
    this.sslcProductInitializer = sslcProductInitializer;
    return this;
  }

  Sslcommerz addAdditionalInitializer({
    required SSLCAdditionalInitializer? sslcAdditionalInitializer,
  }) {
    this.sslcAdditionalInitializer = sslcAdditionalInitializer;
    return this;
  }

  Future<SSLCTransactionInfoModel> payNow() async {
    try {
      var response = await _channel.invokeMethod(
        'initiateSSLCommerz',
        jsonEncode(this),
      );
      return SSLCTransactionInfoModel.fromJson(jsonDecode(response));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
