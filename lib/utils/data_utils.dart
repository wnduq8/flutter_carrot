import 'package:intl/intl.dart';

class DataUtils {
  static final oCcy = new NumberFormat("#,###", "ko_KR");
  static String calcStringToWon(String priceString) {
    if (priceString.toString() == "무료나눔") return priceString.toString();
    return "${oCcy.format(int.parse(priceString.toString()))}원";
  }
}
