import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../app/theme.dart';
import 'app_network_image.dart';

/// Detal sahifalar uchun rasm karuseli + full-screen ko'rish.
class ImageGallery extends StatefulWidget {
  const ImageGallery({super.key, required this.images, this.aspectRatio = 4 / 3});
  final List<String> images;
  final double aspectRatio;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images.isEmpty ? [''] : widget.images;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          CarouselSlider.builder(
            itemCount: imgs.length,
            options: CarouselOptions(
              viewportFraction: 1,
              enableInfiniteScroll: imgs.length > 1,
              onPageChanged: (i, _) => setState(() => _index = i),
            ),
            itemBuilder: (_, i, __) => GestureDetector(
              onTap: () => _openFull(context, imgs, i),
              child: AppNetworkImage(raw: imgs[i], fit: BoxFit.cover),
            ),
          ),
          if (imgs.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedSmoothIndicator(
                  activeIndex: _index,
                  count: imgs.length,
                  effect: const WormEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white54,
                  ),
                ),
              ),
            ),
          if (imgs.length > 1)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${_index + 1}/${imgs.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  void _openFull(BuildContext context, List<String> imgs, int start) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullScreenGallery(images: imgs, initial: start),
      fullscreenDialog: true,
    ));
  }
}

class _FullScreenGallery extends StatelessWidget {
  const _FullScreenGallery({required this.images, required this.initial});
  final List<String> images;
  final int initial;

  @override
  Widget build(BuildContext context) {
    final controller = PageController(initialPage: initial);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: controller,
        itemCount: images.length,
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Center(
            child: AppNetworkImage(raw: images[i], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

/// Yordamchi: to'liq kenglikdagi rasm bloki (radius bilan).
class RoundedImage extends StatelessWidget {
  const RoundedImage({super.key, required this.raw, this.height = 180});
  final String raw;
  final double height;

  @override
  Widget build(BuildContext context) => AppNetworkImage(
        raw: raw,
        height: height,
        radius: AppTheme.radius,
        fit: BoxFit.cover,
      );
}
