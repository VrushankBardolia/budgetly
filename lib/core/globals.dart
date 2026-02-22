import 'package:get/get.dart';

class Globals extends GetxController {
  // USER DATA
  RxString userID = "".obs;
  RxString userName = "".obs;
  RxString userEmail = "".obs;
  RxString userPhone = "".obs;
  RxString FCMToken = "".obs;

  // USER AUTH
  RxBool isGoogleUser = false.obs;

  // IMP CONSTANTS
  RxString selectedCountryCode = "+91".obs;
  RxString selectedCurrency = "₹".obs;

  // USER PREFERENCES
  RxBool isEnabledBiometric = false.obs;

  RxInt currentBudget = 0.obs;
}
