import 'package:Sleephoria/model/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserViewModel {
  UserModel? userInfo;

  UserViewModel() {
    fetchUserInfo();
  }

  void fetchUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    userInfo = UserModel.fromFirebaseUser(user);
  }

  String getFormattedCreatedDate() {
    return userInfo?.formatDate(userInfo?.creationDate) ?? "Unknown";
  }
}
