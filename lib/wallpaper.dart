import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'fullscreen.dart';

class Wallpaper extends StatefulWidget {
  @override
  _WallpaperState createState() => _WallpaperState();
}

class _WallpaperState extends State<Wallpaper> {
  List images = [];
  int page = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchApi();
  }

  Future<void> fetchApi() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=800&page=$page'),
        headers: {
          'Authorization': '3sp1CT2UZO9iqMzZdk72jnYKZ7bxcivInT88drkjyJsQgIhB2LZaSx9e'},
      );

      if (response.statusCode == 200) {
        final Map result = jsonDecode(response.body);
        setState(() {
          images = result['photos'];
        });
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> loadMore() async {
    setState(() {
      page++;
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.pexels.com/v1/curated?per_page=80&page=$page'),
        headers: {'Authorization': 'YOUR_API_KEY'},
      );

      if (response.statusCode == 200) {
        final Map result = jsonDecode(response.body);
        setState(() {
          images.addAll(result['photos']);
        });
      } else {
        debugPrint("Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: isLoading && images.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
              itemCount: images.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 2,
                crossAxisCount: 3,
                childAspectRatio: 2 / 3,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreen(
                          imageurl: images[index]['src']['large2x'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    color: Colors.white,
                    child: Image.network(
                      images[index]['src']['tiny'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 1),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          // Replace your InkWell -> Container with this
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blueAccent, // Modern color
                  foregroundColor: Colors.white,
                ),
                onPressed: isLoading ? null : loadMore,
                child: isLoading
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Loading...",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                )
                    : const Text(
                  "Load More Wallpapers",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
