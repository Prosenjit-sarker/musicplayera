import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MusicPlayScreen extends StatefulWidget {
  const MusicPlayScreen({super.key});

  @override
  State<MusicPlayScreen> createState() => _MusicPlayScreenState();
}

class _MusicPlayScreenState extends State<MusicPlayScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Song> _playlist = [
    Song(
      songName: '3-second synth melody',
      artistName: 'Sample MP3',
      songUrl: 'https://samplelib.com/lib/preview/mp3/sample-3s.mp3',
      durationSecond: 3,
    ),
    Song(
      songName: '6-second synth melody',
      artistName: 'Sample MP3',
      songUrl: 'https://samplelib.com/lib/preview/mp3/sample-6s.mp3',
      durationSecond: 6,
    ),
    Song(
      songName: '9-second',
      artistName: 'Sample MP3',
      songUrl: 'https://samplelib.com/lib/preview/mp3/sample-9s.mp3',
      durationSecond: 9,
    ),
    Song(
      songName: '19 seconds',
      artistName: 'Sample MP3',
      songUrl: 'https://samplelib.com/lib/preview/mp3/sample-12s.mp3',
      durationSecond: 12,
    ),
    Song(
      songName: 'Sample 5',
      artistName: 'No name',
      songUrl: 'https://samplelib.com/lib/preview/mp3/sample-15s.mp3',
      durationSecond: 15,
    ),
  ];
  int _currentIndex = 0;
  bool _isPlaying = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    _listenToPlayer();
    _playSong(_currentIndex);
    super.initState();
  }

  void _listenToPlayer() {
    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _audioPlayer.onPlayerComplete.listen((_) => _next());
  }

  Future<void> _playSong(int index) async {
    _currentIndex = index;
    final song = _playlist[index];
    setState(() {
      _position = Duration.zero;
      _duration = Duration(seconds: song.durationSecond);
    });
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(_playlist[index].songUrl));
  }

  Future<void> _next() async {
    final int next = (_currentIndex + 1) % _playlist.length;
    await _playSong(next);
  }

  Future<void> _previous() async {
    final int previous =
        (_currentIndex - 1 + _playlist.length) % _playlist.length;
    await _playSong(previous);
  }

  Future<void> _togglePlayer() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final Song song = _playlist[_currentIndex];
    final double maxSecond = max(_duration.inSeconds.toDouble(), 1);
    final double currentSecond = _position.inSeconds.toDouble().clamp(
      0,
      maxSecond,
    );
    return Scaffold(
      appBar: AppBar(title: const Text("Music Player")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(song.songName),
                    Text(song.artistName),
                    Slider(
                        min: 0,
                        max: maxSecond,
                        value: currentSecond,
                        onChanged: (value) {
                          final Duration position = Duration(seconds: value.toInt());
                          _audioPlayer.seek(position);
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position)),
                        Text(_formatDuration(_duration)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _previous,
                          icon: Icon(Icons.skip_previous),
                        ),
                        IconButton(onPressed: _togglePlayer, icon: Icon(_isPlaying? Icons.pause : Icons.play_arrow)),
                        IconButton(onPressed: _next, icon: Icon(Icons.skip_next)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _playlist.length,
                itemBuilder: (context, index) {
                  final Song song = _playlist[index];
                  final bool isCurrent = index == _currentIndex;
                  return ListTile(
                    title: Text(song.songName),
                    subtitle: Text(song.artistName),
                    trailing: Icon(isCurrent && _isPlaying ? Icons.pause : Icons.play_arrow),
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    onTap: () => _playSong(index),
                    selected: isCurrent,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Song {
  final String songName;
  final String artistName;
  final String songUrl;
  final int durationSecond;

  const Song({
    required this.songName,
    required this.artistName,
    required this.songUrl,
    required this.durationSecond,
  });
}
