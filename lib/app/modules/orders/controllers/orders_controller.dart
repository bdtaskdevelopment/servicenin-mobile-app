import 'package:get/get.dart';

import '../../../data/models/response/home_response.dart';
import '../../../data/repositories/home.repo.dart';

class OrdersController extends GetxController {
  HomeRepository get _repo => Get.find<HomeRepository>();

  HomeOrdersData? data;
  bool loading = false;

  List<HomeOrder> get orders => data?.orders ?? [];
  int get total => data?.total ?? 0;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    loading = true;
    update();
    try {
      data = await _repo.fetchMyOrders(days: 60);
    } catch (_) {
    } finally {
      loading = false;
      update();
    }
  }
}
