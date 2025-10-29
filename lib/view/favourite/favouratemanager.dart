import 'package:Sleephoria/model/favSoundModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Sleephoria/model/model.dart';
import '../../new_firebase_service.dart';

class FavoriteManager {
  FavoriteManager._privateConstructor();
  static final FavoriteManager instance = FavoriteManager._privateConstructor();
  final service = DatabaseService();

  List<NewSoundModel> favoriteSounds = [];

  String _mixesKey(String userId) => "SavedFavorites_$userId";

  Future<void> addFavorite(
    String mixName,
    List<Map<String, dynamic>> soundTitles,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final mix = FavSoundModel(
      soundTitles: soundTitles,
      favSoundTitle: mixName,
      userId: userId.toString(),
    );

    await service.addOrUpdateMix(mix);
  }
}
