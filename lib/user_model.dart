import 'package:flutter/foundation.dart'; //  ต้องมีสำหรับ ChangeNotifier

class UserModel with ChangeNotifier {
  late String userid;
  late String firstname;
  late String lastname;
  late String address;
  late String telno;
  late String office_name;

  void setUser({
    required String id,
    required String first,
    required String last,
    required String add,
    required String tel,
    required String office,
  }) {
    userid = id;
    firstname = first;
    lastname = last;
    address = add;
    telno = tel;
    office_name = office;

    notifyListeners();
  }
}