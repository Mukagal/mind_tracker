import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mob_edu/config.dart';

class BackgroundMusicPage extends StatefulWidget {
  const BackgroundMusicPage({Key? key}) : super(key: key);

  @override
  State<BackgroundMusicPage> createState() => _BackgroundMusicPageState();
}

class _BackgroundMusicPageState extends State<BackgroundMusicPage> {
  List<Music> musicList = [];
  bool isLoading = true;
  String? errorMessage;
  String? selectedMusicId;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String? currentPlayingId;

  static const String _selectedMusicKey = 'selected_background_music';

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadSelectedMusic();
    await fetchMusicList();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchMusicList() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse('$baseUrl/api/music/list'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        debugPrint('API Response: $data');

        if (data['music'] != null && data['music'] is List) {
          setState(() {
            musicList = (data['music'] as List)
                .map((item) => Music.fromJson(item))
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Invalid response format from server';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage =
              'Failed to load music files (Status: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error connecting to server: $e';
        isLoading = false;
      });
      debugPrint('Error details: $e');
    }
  }

  Future<void> _loadSelectedMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMusicId = prefs.getString(_selectedMusicKey);

      if (savedMusicId != null) {
        setState(() {
          selectedMusicId = savedMusicId;
        });
      }
    } catch (e) {
      debugPrint('Error loading selected music: $e');
    }
  }

  Future<void> _saveSelectedMusic(String musicId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedMusicKey, musicId);

      setState(() {
        selectedMusicId = musicId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Background music set successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving selection: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _clearSelectedMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_selectedMusicKey);

      setState(() {
        selectedMusicId = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Background music cleared'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing selection: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _previewMusic(Music music) async {
    try {
      if (currentPlayingId == music.id && isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        // Stop current playback if any
        await _audioPlayer.stop();

        // Play new music
        await _audioPlayer.play(UrlSource(music.url));

        setState(() {
          isPlaying = true;
          currentPlayingId = music.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing music: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Music Settings'),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (selectedMusicId != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear selection',
              onPressed: _clearSelectedMusic,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh list',
            onPressed: fetchMusicList,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: fetchMusicList,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : musicList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No music files found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add music files to the server directory',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (selectedMusicId != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.green.withOpacity(0.1),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Current: ${musicList.firstWhere(
                              (m) => m.id == selectedMusicId,
                              orElse: () => Music(id: '', name: 'Unknown', filename: '', path: '', size: 0),
                            ).name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: musicList.length,
                    itemBuilder: (context, index) {
                      final music = musicList[index];
                      final isSelected = selectedMusicId == music.id;
                      final isCurrentPlaying =
                          currentPlayingId == music.id && isPlaying;

                      return Card(
                        elevation: isSelected ? 4 : 1,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isSelected
                            ? Colors.deepPurple.withOpacity(0.1)
                            : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? Colors.deepPurple
                                : Colors.grey[300],
                            child: Icon(
                              isSelected ? Icons.check : Icons.music_note,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                          title: Text(
                            music.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            _formatFileSize(music.size),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isCurrentPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: Colors.deepPurple,
                                  size: 32,
                                ),
                                onPressed: () => _previewMusic(music),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _saveSelectedMusic(music.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Colors.green
                                      : Colors.deepPurple,
                                ),
                                child: Text(isSelected ? 'Selected' : 'Select'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class Music {
  final String id;
  final String name;
  final String filename;
  final String path;
  final int size;

  Music({
    required this.id,
    required this.name,
    required this.filename,
    required this.path,
    required this.size,
  });

  String get url => '$baseUrl$path';

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      filename: json['filename'] as String? ?? '',
      path: json['path'] as String? ?? '',
      size: json['size'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filename': filename,
      'path': path,
      'size': size,
    };
  }
}
