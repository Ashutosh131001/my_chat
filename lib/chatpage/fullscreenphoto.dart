import 'package:cached_network_image/cached_network_image.dart'; // 🟢 Import Cache Package
import 'package:flutter/material.dart';

class FullScreenImageView extends StatelessWidget {
  final List imageUrls;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              panEnabled: true, // Allow moving around when zoomed in
              minScale: 0.5,
              maxScale: 4.0,
              child: CachedNetworkImage( // 🟢 USES DISK CACHE
                imageUrl: imageUrls[index],
                fit: BoxFit.contain,
                
                // Show spinner while loading from disk or internet
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                
                // Show broken image icon if download fails AND not in cache
                errorWidget: (context, url, error) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                    const SizedBox(height: 10),
                    const Text(
                      "Image not available offline",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}