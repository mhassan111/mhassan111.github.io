import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:x51/models/user_model.dart';

import '../service/products_service.dart';

class UsersController extends GetxController {

  var products = <UserModel>[].obs;
  var isLoading = true.obs;

  void fetchProducts() async {
    try {
      var products = await ProductsService().fetchProducts();
      isLoading(true);
      if (products.isNotEmpty) {
        this.products.assignAll(products as Iterable<UserModel>);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      isLoading(false);
    }
  }
}
