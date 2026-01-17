// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BasicVideoPlayer extends StatefulWidget {
  const BasicVideoPlayer({super.key});

  @override
  _BasicVideoPlayerState createState() => _BasicVideoPlayerState();
}

class _BasicVideoPlayerState extends State<BasicVideoPlayer> {
  // ১. কন্ট্রোলার ডিক্লেয়ার করা
  late VideoPlayerController _controller;
  bool _isError = false;
  // ৭. প্লেব্যাক স্পিড ভেরিয়েবল
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();

    // ২. ভিডিও কন্ট্রোলার ইনিশিয়ালাইজ করা (Network URL দিয়ে)
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )
    
    ..setLooping(false) // ভিডিও লুপ করার জন্য
    ..initialize().then((_) {
        // ভিডিও লোড হয়ে গেলে UI আপডেট করার জন্য setState
        setState(() {});
      }).catchError((error) {
        setState(() {
          _isError = true;
        });
      }) // ভিডিও ইনিশিয়ালাইজ করার সময় এরর হ্যান্ডেল করার জন্য
      
      ;

    // ৩. লিসেনার অ্যাড করা (ভিডিওর পজিশন বা স্টেট চেঞ্জ ট্র্যাক করার জন্য)
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // ৪. মেমরি সেভ করতে কন্ট্রোলার অবশ্যই ডিসপোজ করতে হবে
    _controller.dispose();
    super.dispose();
  }

  // ভিডিওর বর্তমান সময় এবং টোটাল সময় ফরম্যাট করার ফাংশন
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn Video Player")),
      body: Column(
        children: [
          // ভিডিও স্ক্রিন এরিয়া
          Container(
            height: 250,
            color: Colors.black,
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Center(
                    child: _isError
                        ? const Text("Error loading video",
                            style: TextStyle(color: Colors.white))
                        : const CircularProgressIndicator(),
                  ),
          ),

          // ৫. কাস্টম স্লাইডার (ভিডিও টানার জন্য)
          if (_controller.value.isInitialized)
            Column(
              children: [
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing:
                      true, // এটি true থাকলে ইউজার টেনে ভিডিও আগে-পিছে নিতে পারবে
                  colors: const VideoProgressColors(
                    playedColor: Colors.green, // প্লে হওয়া অংশের রঙ
                    bufferedColor: Colors.grey, // বাফার হওয়া অংশের রঙ
                    backgroundColor: Colors.black12, // বাকি অংশের রঙ
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 0.0), // প্যাডিং
                  key: const Key(
                      'video_progress_indicator'), // কাস্টম কী (যদি প্রয়োজন হয়)
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // বর্তমান সময়
                      Text(_formatDuration(_controller.value.position)), 
                      // মোট ডিউরেশন
                      Text(_formatDuration(_controller.value.duration)),
                    ],
                  ),
                ),
              ],
            ),

          // ৬. কন্ট্রোল বাটনসমূহ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ১০ সেকেন্ড পিছনে যাওয়া
              IconButton(
                icon: const Icon(Icons.replay_10),
                onPressed: () {
                  _controller.seekTo(
                      _controller.value.position - const Duration(seconds: 10));
                },
              ),
              // প্লে এবং পজ বাটন
              IconButton(
                iconSize: 50,
                icon: Icon(_controller.value.isPlaying
                    ? Icons.pause_circle
                    : Icons.play_circle),
                onPressed: () {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                },
              ),
              // ১০ সেকেন্ড সামনে যাওয়া
              IconButton(
                icon: const Icon(Icons.forward_10),
                onPressed: () {
                  _controller.seekTo(
                      _controller.value.position + const Duration(seconds: 10));
                },
              ),
              // মিউট এবং আনমিউট
              IconButton(
                icon: Icon(_controller.value.volume == 0
                    ? Icons.volume_off
                    : Icons.volume_up),
                onPressed: () {
                  _controller.setVolume(_controller.value.volume == 0 ? 1 : 0);
                },
              ),

            // ৭. প্লেব্যাক স্পিড কন্ট্রোল
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Speed: "),
                DropdownButton<double>(
                  value: _playbackSpeed,
                  items: const [
                    
                    DropdownMenuItem(value: 0.5, child: Text("0.5x")),
                    DropdownMenuItem(value: 1.0, child: Text("1.0x")),
                    DropdownMenuItem(value: 1.5, child: Text("1.5x")),
                    DropdownMenuItem(value: 2.0, child: Text("2.0x")),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      
                      _playbackSpeed = value;
                      // ভিডিওর প্লেব্যাক স্পিড সেট করা
                      _controller.setPlaybackSpeed(value);
                    });
                  },
                ),
              ],
            ),
            ],
          ),
        ],
      ),
    );
  }
}
