import 'dart:async';
import 'package:clarity/globals.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
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
  Map<String, AudioPlayer> _mixPlayers = {};
  final Map<String, double> _volumeMap = {};
  final ValueNotifier<List<String>> selectedTitlesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);

  List<String> get selectedSoundTitles => selectedTitlesNotifier.value;

  bool isSelected(String title) => selectedSoundTitles.contains(title);

  void saveVolume(String title, double volume) {
    _volumeMap[title] = volume;
  }

  Future<void> ensurePlayers(List<NewSoundModel> sounds) async {
    // Remove players that are no longer in the sounds list
    if (isPlayingMix) {
      debugPrint("🛑 Mix player active — clearing it before playing sounds");
      await clearMixPlayers();
    }
    final existingKeys = _players.keys.toList();
    for (final key in existingKeys) {
      if (!sounds.any((s) => s.title == key)) {
        try {
          await _players[key]?.dispose();
        } catch (_) {}
        _players.remove(key);
      }
    }

    // Create and prepare players for missing sounds
    final futures = <Future>[];
    for (final sound in sounds) {
      final key = sound.title;
      if (!_players.containsKey(key)) {
        futures.add(() async {
          try {
            final player = AudioPlayer();
            await player.setAudioSource(
              AudioSource.uri(Uri.parse(sound.musicUrl)),
            );
            await player.setLoopMode(LoopMode.one);
            await player.setVolume(1.0);
            _players[key] = player;
          } catch (e) {
            debugPrint("❌ Failed to initialize ${sound.title}: $e");
          }
        }());
      }
    }

    await Future.wait(futures);
  }

  Future<void> ensureMixPlayers(List<NewSoundModel> sounds) async {
    // Remove players that are no longer in the sounds list

    if (isSoundPlaying) {
      debugPrint("🛑 Sound player active — clearing it before playing mix");
      await clearSoundPlayers();
    }

    final existingKeys = _mixPlayers.keys.toList();
    for (final key in existingKeys) {
      if (!sounds.any((s) => s.title == key)) {
        try {
          await _mixPlayers[key]?.dispose();
        } catch (_) {}
        _mixPlayers.remove(key);
      }
    }

    // Create and prepare players for missing sounds
    final futures = <Future>[];
    for (final sound in sounds) {
      final key = sound.title;
      if (!_mixPlayers.containsKey(key)) {
        futures.add(() async {
          try {
            final player = AudioPlayer();
            await player.setAudioSource(
              AudioSource.uri(Uri.parse(sound.musicUrl)),
            );
            await player.setLoopMode(LoopMode.one);
            await player.setVolume(1.0);
            _mixPlayers[key] = player;
          } catch (e) {
            debugPrint("❌ Failed to initialize ${sound.title}: $e");
          }
        }());
      }
    }

    await Future.wait(futures);
  }

  /// Sync players with current selection
  Future<void> syncPlayers(List<NewSoundModel> selectedSounds) async {
    // Dispose removed players
    final keysToRemove = _players.keys
        .where((key) => !selectedSounds.any((s) => s.title == key))
        .toList();

    for (final key in keysToRemove) {
      final player = _players.remove(key);
      await player?.dispose();
    }

    // Add new players
    for (final sound in selectedSounds) {
      if (!_players.containsKey(sound.title)) {
        final player = AudioPlayer();
        _players[sound.title] = player;
        await player.setAudioSource(AudioSource.uri(Uri.parse(sound.musicUrl)));
        await player.setLoopMode(LoopMode.one);
      }
    }

    // Restore saved volumes
    for (final sound in selectedSounds) {
      final savedVolume = getSavedVolume(
        sound.title,
        defaultValue: sound.volume.toDouble(),
      );
      sound.volume = savedVolume; // ✅ update model
      _volumeMap[sound.title] = savedVolume;
      await _players[sound.title]?.setVolume(savedVolume);
    }

    _updateSelectedTitles(selectedSounds);
    await adjustVolumes(selectedSounds);
  }

  Future<void> toggleSoundSelection(
    List<NewSoundModel> allSounds,
    NewSoundModel targetSound,
    bool isTrial,
  ) async {
    try {
      await ensurePlayers(allSounds);
    } catch (e, st) {
      debugPrint("❌ ensurePlayers failed: $e\n$st");
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

  Future<void> playAll() async {
    isPlayingNotifier.value = true;
    isSoundPlaying = true;

    // Only play the selected sounds
    final selectedTitles = selectedTitlesNotifier.value;
    await Future.wait(
      selectedTitles.map((title) async {
        final player = _players[title];
        if (player != null && !player.playing) {
          await player.play();
        }
      }),
    );
  }

  Future<void> pauseAll() async {
    await Future.wait(
      _players.values.map((p) async {
        if (p.playing) await p.pause();
      }),
    );
    isPlayingNotifier.value = false;
    isSoundPlaying = false;
  }

  Future<void> playMixAll() async {
    // isPlayingNotifier.value = true;
    // isSoundPlaying = true;

    // Only play the selected sounds
    if (isSoundPlaying) {
      await clearSoundPlayers();
    }
    final selectedTitles = selectedTitlesNotifier.value;
    await Future.wait(
      selectedTitles.map((title) async {
        final player = _mixPlayers[title];
        if (player != null && !player.playing) {
          await player.play();
        }
      }),
    );
    isPlayingMix = true;
  }

  Future<void> pauseMixAll() async {
    await Future.wait(
      _mixPlayers.values.map((p) async {
        if (p.playing) await p.pause();
      }),
    );
    // isPlayingNotifier.value = false;
    // isSoundPlaying = false;
  }
  Future<void> clearSoundPlayers() async {
    for (final p in _players.values) {
      if (p.playing) await p.stop();
      await p.dispose();
    }
    _players.clear();
    isSoundPlaying = false;
  }

  Future<void> clearMixPlayers() async {
    for (final p in _mixPlayers.values) {
      if (p.playing) await p.stop();
      await p.dispose();
    }
    _mixPlayers.clear();
    isPlayingMix = false;
  }

  void setSoundPlaying(bool value) {
    isSoundPlaying = value;
    isPlayingNotifier.value = value;
  }

  void setMixPlaying(bool value) {
    isPlayingMix = value;
    // Optionally create another notifier if you want
  }


  /// Adjust volume based on number of playing sounds
  Future<void> adjustVolumes(List<NewSoundModel> selectedSounds) async {
    for (final s in selectedSounds) {
      final player = _players[s.title];
      if (player != null) {
        _volumeMap[s.title] = s.volume.toDouble();
        await player.setVolume(
          s.volume.toDouble(),
        ); // use the actual slider value
      }
    }
  }

  void _updateSelectedTitles(List<NewSoundModel> selectedSounds) {
    selectedTitlesNotifier.value = selectedSounds.map((s) => s.title).toList();

    debugPrint("Selected from sync: ${selectedTitlesNotifier.value}");
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    // selectedTitlesNotifier.dispose();
    // isPlayingNotifier.dispose();
  }

  bool isAnyPlayingInContext(List<String> filepath, {String? context}) {
    for (var fp in filepath) {
      final key = context != null ? '$context$fp' : fp;
      if (_players[key]?.playing == true) return true;
    }
    return false;
  }

    /// Play all sounds in a mix
  Future<void> playMix(List<String> filepaths, {String? context}) async {
    for (var fp in filepaths) {
      final key = context != null ? '$context$fp' : fp;
      var player = _players[key];

      if (player == null) {
        // If player doesn't exist, initialize
        player = AudioPlayer();
        try {
          await player.setAudioSource(AudioSource.uri(Uri.parse(fp)));
          await player.setLoopMode(LoopMode.one);
          await player.setVolume(1.0);
          _players[key] = player;
        } catch (e) {
          debugPrint("❌ Failed to load $fp: $e");
          continue;
        }
      }

      if (!player.playing) {
        await player.seek(Duration.zero);
        await player.play();
      }
    }

    isPlayingNotifier.value = true;
    isSoundPlaying = true;
  }

  /// Pause all sounds in a given list
  Future<void> pauseSounds(List<String> filepaths, {String? context}) async {
    for (var fp in filepaths) {
      final key = context != null ? '$context$fp' : fp;
      final player = _players[key];
      if (player != null && player.playing) {
        await player.pause();
      }
    }

    // If nothing else is playing → update notifiers
    final anyPlaying = _players.values.any((p) => p.playing);
    isPlayingNotifier.value = anyPlaying;
    isSoundPlaying = anyPlaying;
  }

}
