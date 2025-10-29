import 'dart:convert';

class FavSoundModel {
  final List<Map<String, dynamic>> soundTitles;
  final String favSoundTitle;
  final String userId;

  FavSoundModel({
    required this.soundTitles,
    required this.favSoundTitle,
    required this.userId,
  });

  factory FavSoundModel.fromJson(Map<String, dynamic> json) {
    return FavSoundModel(
      soundTitles: (json['soundTitles'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      favSoundTitle: json['favSoundTitle'] ?? '',
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundTitles': soundTitles,
      'favSoundTitle': favSoundTitle,
      'userId': userId,
    };
  }

  static String encode(List<FavSoundModel> mixes) => jsonEncode(
    mixes.map<Map<String, dynamic>>((mix) => mix.toJson()).toList(),
  );

  static List<FavSoundModel> decode(String mixes) =>
      (jsonDecode(mixes) as List<dynamic>)
          .map<FavSoundModel>((item) => FavSoundModel.fromJson(item))
          .toList();
}
