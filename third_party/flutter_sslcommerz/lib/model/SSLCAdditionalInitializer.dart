import 'package:json_annotation/json_annotation.dart';
part 'SSLCAdditionalInitializer.g.dart';

@JsonSerializable()
class SSLCAdditionalInitializer {
  String? valueA;
  String? valueB;
  String? valueC;
  String? valueD;
  String? campaign_code;
  String? invoice_id;
  int? no_offer;
  String? bill_number;
  String? user_refer;
  Map<String, dynamic>? extras;

  SSLCAdditionalInitializer({
    this.valueA,
    this.valueB,
    this.valueC,
    this.valueD,
    this.bill_number,
    this.campaign_code,
    this.invoice_id,
    this.no_offer,
    this.user_refer,
    this.extras,
  });

  Map<String, dynamic> toJson() => _$SSLCAdditionalInitializerToJson(this);
  factory SSLCAdditionalInitializer.fromJson(Map<String, dynamic> json) =>
      _$SSLCAdditionalInitializerFromJson(json);

  String? getValueA() {
    return this.valueA;
  }

  void setValueA(String valueA) {
    this.valueA = valueA;
  }

  String? getValueB() {
    return this.valueB;
  }

  void setValueB(String valueB) {
    this.valueB = valueB;
  }

  String? getValueC() {
    return this.valueC;
  }

  void setValueC(String valueC) {
    this.valueC = valueC;
  }

  String? getValueD() {
    return this.valueD;
  }

  void setValueD(String valueD) {
    this.valueD = valueD;
  }

  String? getCampaignCode() {
    return campaign_code;
  }

  void setCampaignCode(String campainCode) {
    this.campaign_code = campainCode;
  }

  String? getInvoiceId() {
    return invoice_id;
  }

  void setInvoiceId(String invoiceId) {
    this.invoice_id = invoiceId;
  }

  int? getNoOffer() {
    return no_offer;
  }

  void setNoOffer(int noOffer) {
    this.no_offer = noOffer;
  }

  String? getBillNumber() {
    return bill_number;
  }

  void setBillNumber(String billnumber) {
    this.bill_number = billnumber;
  }

  String? getUserPrefer() {
    return user_refer;
  }

  void setUserPrefer(String userPrefer) {
    this.user_refer = userPrefer;
  }

  Map<String, dynamic>? getExtras() {
    return extras;
  }

  void setExtras(Map<String, dynamic> extras) {
    this.extras = extras;
  }
}
