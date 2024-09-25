import '../service/products_service.dart';
import 'package:get/get.dart';
import '../models/product.dart';

class ProductsController extends GetxController {
  var products = <Product>[].obs;
  var isLoading = true.obs;

  void fetchProducts() async {
    try {
      var products = await ProductsService().fetchProducts();
      isLoading(true);
      if (products.isNotEmpty) {
        this.products.assignAll(products);
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
    } finally {
      isLoading(false);
    }
  }
}
