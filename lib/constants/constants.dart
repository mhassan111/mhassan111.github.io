import 'package:x51/models/user_model.dart';

class Constants {
  static const String customersUrl =
      "https://jsonplaceholder.typicode.com/users";
  static const String productsUrl = "https://dummyjson.com/products";
  static const String localHost =
      "https://heroic-achievement-production.up.railway.app";

  static const String totalStock = "Total stock of products:";
  static const String valueOfStock = "Value of stock:";
  static const String productsCount = "Products count:";
  static const String customerCount = "Customer count:";

  static const String loginOk = "User logged in successfully!";
  static const String registerOk = "Account created successfully!";
  static const String customRegisterOk = "User created successfully!";
  static const String logoutOk = "Logged out successfully!";
  static const String logoutError = "Error during logout!";

  static const String cookieName = "jwt";

  // Preferences
  static const String prefUserAuthenticated = "prefUserAuthenticated";
  static const String prefRegisteredUserSet = "prefRegisteredUserSet";
  static const String prefFirstName = "prefFirstName";
  static const String prefLastName = "prefLastName";

  // Firebase Constants
  static const String usersCollection = "users";

  // static const String superAdminEmail = "bode@reapsunllc.com";
  static const String superAdminEmail = "bode@gmail.com";

  // Static Constants
  static UserModel userModel = UserModel.emptyUser();
}
