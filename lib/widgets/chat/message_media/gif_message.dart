import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import '../../../models/chat_model.dart';
import '../../../utils/theme_extensions.dart';

/// Widget to display a GIF message with loop control
class GifMessage extends StatefulWidget {
  final MessageModel message;

  const GifMessage({
    super.key,
    required this.message,
  });

  @override
  State<GifMessage> createState() => _GifMessageState();
}

class _GifMessageState extends State<GifMessage> {
  late GifController _gifController;
  int _loopCount = 0;

  @override
  void initState() {
    super.initState();
    _gifController = GifController();
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  void _onGifFinish() {
    if (mounted) {
      setState(() {
        _loopCount++;
      });
      if (_loopCount < 3) {
        _gifController.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.gifUrl == null || widget.message.gifUrl!.isEmpty) {
      return _buildErrorPlaceholder(context);
    }

    // Check if it's a network URL (starts with http/https) or local asset
    final isNetwork = widget.message.gifUrl!.startsWith('http');

    return Container(
      width: 220,
      height: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isNetwork
                ? GifView.network(
                    widget.message.gifUrl!,
                    controller: _gifController,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    autoPlay: true,
                    loop: false,
                    onFinish: _onGifFinish,
                    progressBuilder: (context) => Center(
                      child: CircularProgressIndicator(
                        color: context.themeColors.colorPrimary,
                      ),
                    ),
                    errorBuilder: (ctx, err, stack) =>
                        _buildErrorPlaceholder(context),
                  )
                : GifView.asset(
                    widget.message.gifUrl!,
                    controller: _gifController,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    autoPlay: true,
                    loop: false,
                    onFinish: _onGifFinish,
                    errorBuilder: (ctx, err, stack) =>
                        _buildErrorPlaceholder(context),
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.themeColors.bgSurface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'GIF',
                style: TextStyle(
                  color: context.themeColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Replay button if stopped
          if (_loopCount >= 3)
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow,
                      color: Colors.white, size: 40),
                  onPressed: () {
                    setState(() {
                      _loopCount = 0;
                    });
                    _gifController.seek(0);
                    _gifController.play();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'GIF',
            style: TextStyle(
              color: context.themeColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.message.text,
            style: TextStyle(
              color: context.themeColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
