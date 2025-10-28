import 'dart:async';
import 'dart:io';
import 'package:Sleephoria/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../../model/model.dart';

bool isSoundPlaying = false;

class AudioManager {
  // Singleton
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  String? currentMix;
  bool isPlaying = false;

  Map<String, AudioPlayer> _players = {};
  Map<String, AudioPlayer> _favPlayers = {};
  final Map<String, double> _volumeMap = {};
  final ValueNotifier<List<String>> selectedTitlesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  List<String> get selectedSoundTitles => selectedTitlesNotifier.value;

  bool isSelected(String title) => selectedSoundTitles.contains(title);

  void saveVolume(String title, double volume) {
    _volumeMap[title] = volume;

    print("🔊 Current Volume Map:");
    _volumeMap.forEach((key, value) {
      print("Title: $key, Volume: $value");
    });
  }

  // for :  when the trial is false

  Future<void> toggleSoundSelection(List<NewSoundModel> allSounds, NewSoundModel targetSound, bool isTrial,) async {
    try {
      await playSoundNew(targetSound.filepath, allSounds);
      await playAllNew();
    } catch (e, st) {
      debugPrint("❌ Players failed: $e\n$st");
      return;
    }

    final key = targetSound.title;
    final player = _players[key];
    if (player == null) {
      debugPrint("⚠️ Player not found for $key");
      return;
    }

    try {
      if (targetSound.isSelected) {
        targetSound.isSelected = false;

        final selectedTitles = allSounds
            .where((s) => s.isSelected)
            .map((s) => s.title)
            .toList();
        selectedTitlesNotifier.value = selectedTitles;

        final anyPlaying = selectedTitles.isNotEmpty;
        isPlayingNotifier.value = anyPlaying;
        isSoundPlaying = anyPlaying;
        await player.stop();
      } else {
        if (!isTrial) {
          for (final other in allSounds) {
            if (other.title != key && other.isSelected) {
              final otherPlayer = _players[other.title];
              if (otherPlayer != null) {
                try {
                  await otherPlayer.stop();
                } catch (e, st) {
                  debugPrint("❌ Error stopping ${other.title}: $e\n$st");
                }
              }
              other.isSelected = false;
            }
          }
        }

        targetSound.isSelected = true;

        final selectedTitles = allSounds
            .where((s) => s.isSelected)
            .map((s) => s.title)
            .toList();
        selectedTitlesNotifier.value = selectedTitles;

        // Update playing state
        final anyPlaying = selectedTitles.isNotEmpty;
        isPlayingNotifier.value = anyPlaying;
        isSoundPlaying = anyPlaying;

        await player.seek(Duration.zero);
        await player.play();
      }
    } catch (e, st) {
      debugPrint("❌ Error in main toggle logic for ${targetSound.title}: $e\n$st");
      targetSound.isSelected = false;
      return;
    }
  }

  double getSavedVolume(String title, {double defaultValue = 1.0}) {
    return _volumeMap[title] ?? defaultValue;
  }

  Future<void> playSound(String title) async {
    final player = _players[title];

    if (player != null && !player.playing) {
      await player.play();
    }
    isPlayingNotifier.value = true;
    isSoundPlaying = true;
  }

  Future<void> pauseSound(String title) async {
    final player = _players[title];
    if (player != null && player.playing) {
      await player.pause();
    }
  }

  Future<void> clearSound(String title) async {
    final player = _players[title];

    if (player != null) {
      if (player.playing) {
        debugPrint('🧹 Clearing and removing "$title" (was playing)');
      } else {
        debugPrint('🧹 Clearing and removing "$title" (was NOT playing)');
      }

      _players.remove(title);
      await player.dispose();
      debugPrint('✅ "$title" removed and disposed successfully');
    } else {
      debugPrint('⚠️ No player found for "$title" — nothing to clear');
    }
  }

  /// Adjust volume based on number of playing sounds
  Future<void> adjustVolumes(List<NewSoundModel> selectedSounds) async {
    for (final s in selectedSounds) {
      final player = _players[s.title.toLowerCase()];
      debugPrint(":headphones: Adjusting volume for ${s.title.toLowerCase()}");
      if (player == null) {
        debugPrint(":x: No player found for ${s.title.toLowerCase()}");
        continue;
      }
      debugPrint(":arrow_right: Setting volume to ${s.volume}");
      try {
        await player.setVolume(s.volume.toDouble());
        debugPrint(":white_check_mark: Volume set for ${s.title.toLowerCase()}");
      } catch (e, st) {
        debugPrint(":x: Failed to set volume for ${s.title.toLowerCase()}: $e\n$st");
      }
    }
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    // selectedTitlesNotifier.dispose();
    // isPlayingNotifier.dispose();
  }

  final Map<String, String> _downloadedFilePaths = {}; // title -> local file path
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> downloadAllNewSounds(List<NewSoundModel> sounds) async {
    final dir = await getApplicationDocumentsDirectory();
    for (var sound in sounds) {
      if (sound.musicUrl != null && sound.musicUrl!.isNotEmpty) {
        final fileName = sound.title.replaceAll(' ', '_') + '.mp3';
        final lowerCaseFileName = fileName.toLowerCase();
        final filePath = '${dir.path}/$lowerCaseFileName';
        final file = File(filePath);

        try {
          if (!await file.exists()) {
            final response = await http.get(Uri.parse(sound.musicUrl!));

            if (response.statusCode == 200) {
              await file.writeAsBytes(response.bodyBytes);
              debugPrint('✅ Downloaded "${sound.title}" successfully!');
            } else {
              debugPrint('❌ Failed to download "${sound.title}" (HTTP ${response.statusCode})');
            }
          } else {
            debugPrint('ℹ️ "${sound.title}" already exists locally.');
          }

          // Save local path
          _downloadedFilePaths[sound.title.toLowerCase()] = filePath;
        } catch (e) {
          debugPrint('❌ Error downloading "${sound.title}": $e');
        }
      }
    }
  }

  Future<void> playSoundNew(String title, List<NewSoundModel> sounds) async {

    if (isPlayingMix) {
      debugPrint("🛑 Mix player active — clearing it before playing sounds");
      await pauseAllFav();
    }

    final existingKeys = _players.keys.toList();
    for (final key in existingKeys) {
      if (!sounds.any((s) => s.filepath == key)) {
        try {
          await _players[key]?.dispose();
        } catch (_) {}
        _players.remove(key);
      }
    }

    final localPath = _downloadedFilePaths[title.toLowerCase()];
    if (localPath == null || !File(localPath).existsSync()) {
      debugPrint("⚠️ File not found for $title");
      isPlayingNotifier.value = false;
      return;
    }

    AudioPlayer player;

    // ✅ Reuse player if it exists, otherwise create one
    if (_players.containsKey(title)) {
      player = _players[title]!;
      if (player.playing) {
        debugPrint("⚠️ Player is already playing.");
        return;
      }
    } else {
      player = AudioPlayer();
      try {
        await player.setFilePath(localPath);
        await player.setLoopMode(LoopMode.one);
        await player.setVolume(1.0);
        _players[title] = player;
      } catch (e) {
        debugPrint("❌ Failed to initialize player for $title: $e");
        return;
      }
    }

    try {
      isPlayingNotifier.value = true;
      debugPrint('🎧 Playing "$title" in loop.');
      await player.seek(Duration.zero);
      // await player.play();
      // await playAllNew();
    } catch (e) {
      debugPrint('❌ Error playing "$title": $e');
    }
  }

  Future<void> stop() async {
    try {
      isPlayingNotifier.value = false;
      await _audioPlayer.stop();

      debugPrint('⏹️ Stopped playback.');
    } catch (e) {
      debugPrint('❌ Error stopping playback: $e');
    }
  }

  Future<void> pause() async {
    try {
      if (_audioPlayer.playing) {
        isPlayingNotifier.value = false;

        await _audioPlayer.pause();
        debugPrint('⏸️ Paused playback.');
      } else {
        debugPrint('⚠️ Cannot pause, player is not playing.');
      }
    } catch (e) {
      debugPrint('❌ Error pausing playback: $e');
    }
  }

  Future<void> resume() async {
    try {
      if (!_audioPlayer.playing) {
        isPlayingNotifier.value = true;
        debugPrint('▶️ Resumed playback.');
        await _audioPlayer.play();

      } else {
        debugPrint('⚠️ Player is already playing.');
      }
    } catch (e) {
      debugPrint('❌ Error resuming playback: $e');
    }
  }

  Future<void> playAllNew() async {
    if (isPlayingMix) {
      debugPrint("🛑 Mix player active — clearing it before playing sounds");
      await pauseAllFav();
    }
    isPlayingNotifier.value = true;
    Future.wait(
      _players.values.map((p) async {
        await p.play();
      }),
    );
  }

  Future<void> pauseAllNew() async {
    isPlayingNotifier.value = false;
    Future.wait(
      _players.values.map((p) async {
        if (p.playing) await p.pause();
      }),
    );
  }

  Future<void> stopAll() async {
    for (final player in _players.values) {
      if (player.playing) await stop();
    }
  }

  Future<void> playFavSounds(List<NewSoundModel> allSounds, List<Map<String, dynamic>> selectedTitles) async {

    if (isPlayingNotifier.value) {
      debugPrint("🛑 Sound player active — clearing it before playing mix");
      await pauseAllNew();
      await clearAllPlayer(_players);
    }
    await clearAllPlayer(_favPlayers);

    final titles = selectedTitles
        .map((e) => e['title']?.toString())
        .where((t) => t != null && t.isNotEmpty)
        .toList();

    // 1. Remove players that are no longer in selected titles
    final existingKeys = _favPlayers.keys.toList();
    for (final key in existingKeys) {
      if (!selectedTitles.contains(key)) {
        try {
          await _favPlayers[key]?.dispose();
        } catch (_) {}
        _favPlayers.remove(key);
      }
    }

    // 2. Loop through selected titles and ensure a player exists
    for (final title in titles) {
      final sound = allSounds.firstWhere(
            (s) => s.title == title,
        orElse: () => throw Exception("Sound not found: $title"),
      );

      final localPath = _downloadedFilePaths[sound.title.toLowerCase()];
      if (localPath == null || !File(localPath).existsSync()) {
        debugPrint("⚠️ File not found for ${sound.title.toLowerCase()}");
        continue;
      }

      if (!_favPlayers.containsKey(sound.title)) {
        final player = AudioPlayer();
        try {
          await player.setFilePath(localPath);
          await player.setLoopMode(LoopMode.one);
          // Find matching volume from selectedTitles
          final match = selectedTitles.firstWhere(
                (e) => e['title'] == sound.title,
            orElse: () => {'volume': 1.0},
          );

          final volume = (match['volume'] as num?)?.toDouble() ?? 1.0;
          await player.setVolume(volume);
          _favPlayers[sound.title] = player;
          debugPrint("✅ Player created for ${sound.title}");
        } catch (e) {
          debugPrint("❌ Failed to initialize ${sound.title}: $e");
        }
      } else {
        debugPrint("ℹ️ Reusing existing player for ${sound.title}");
      }
    }

    await Future.wait(
      selectedTitles.map((title) async {
        final player = _players[title];
        if (player != null && !player.playing) {
          await player.seek(Duration.zero);
          // await player.play();
          debugPrint('🎧 Playing "$title"');
        }
      }),
    );

    isPlayingMix = true;
  }

  Future<void> playAllFav() async {
    if (isPlayingNotifier.value) {
      debugPrint("🛑 Sound player active — clearing it before playing mix");
      await pauseAllNew();
    }
    isPlayingMix = true;
    Future.wait(
      _favPlayers.values.map((p) async {
        await p.play();
      }),
    );
  }

  Future<void> pauseAllFav() async {
    isPlayingMix = false;
    Future.wait(
      _favPlayers.values.map((p) async {
        if (p.playing) await p.pause();
      }),
    );
  }

  Future<void> clearAllPlayer(Map<String, AudioPlayer> players) async {
    for (final player in players.values) {
      try {
        await player.stop();
        await player.dispose();
      } catch (_) {
        // ignore errors during disposal
      }
    }
    players.clear();
  }

}

