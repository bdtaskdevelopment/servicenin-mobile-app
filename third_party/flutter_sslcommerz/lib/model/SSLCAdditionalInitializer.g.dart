// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SSLCAdditionalInitializer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SSLCAdditionalInitializer _$SSLCAdditionalInitializerFromJson(
  Map<String, dynamic> json,
) => SSLCAdditionalInitializer(
  valueA: json['valueA'] as String?,
  valueB: json['valueB'] as String?,
  valueC: json['valueC'] as String?,
  valueD: json['valueD'] as String?,
  bill_number: json['bill_number'] as String?,
  campaign_code: json['campaign_code'] as String?,
  invoice_id: json['invoice_id'] as String?,
  no_offer: (json['no_offer'] as num?)?.toInt(),
  user_refer: json['user_refer'] as String?,
  extras: json['extras'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SSLCAdditionalInitializerToJson(
  SSLCAdditionalInitializer instance,
) => <String, dynamic>{
  'valueA': instance.valueA,
  'valueB': instance.valueB,
  'valueC': instance.valueC,
  'valueD': instance.valueD,
  'campaign_code': instance.campaign_code,
  'invoice_id': instance.invoice_id,
  'no_offer': instance.no_offer,
  'bill_number': instance.bill_number,
  'user_refer': instance.user_refer,
  'extras': instance.extras,
};
