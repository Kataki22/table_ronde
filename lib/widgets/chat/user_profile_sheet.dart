import 'dart:io';

import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/theme_extensions.dart';

class UserProfileSheet extends StatelessWidget {
  final ChatModel chat;

  const UserProfileSheet({super.key, required this.chat});

  ImageProvider? _getImageProvider(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('assets/')) return AssetImage(url);
    if (url.startsWith('http')) return NetworkImage(url);
    if (url.startsWith('/')) return FileImage(File(url));
    return AssetImage(url);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Banner Color
    const bannerColor =
        AppTheme.primaryBlue; // Or custom purple/blue from image

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.themeColors.bgSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // ── Banner ────────────────────────────────────────────────
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: bannerColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),

              // ── Body ──────────────────────────────────────────────────
              Expanded(
                child: Container(
                  color: context.themeColors.bgSurface, // Dark background
                  padding: const EdgeInsets.fromLTRB(
                      16, 60, 16, 16), // Top padding for avatar
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Handle
                        Text(
                          chat.name,
                          style: TextStyle(
                            color: context.themeColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (chat.username != null)
                          Text(
                            chat.username!,
                            style: TextStyle(
                              color: context.themeColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        const SizedBox(height: 16),

                        // "Voir le profil complet" Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to full profile
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  context.themeColors.bgSurfaceDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Voir le profil complet',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── "À PROPOS DE MOI" Section ─────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.themeColors.bgSurfaceDark,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'À PROPOS DE MOI',
                                style: TextStyle(
                                  color: context.themeColors.textPrimary
                                      .withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                chat.bio ?? 'Description de bio vide',
                                style: TextStyle(
                                  color: context.themeColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'CRÉÉ LE',
                                style: TextStyle(
                                  color: context.themeColors.textPrimary
                                      .withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(chat.createdAt),
                                style: TextStyle(
                                  color: context.themeColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── "ACTIVITÉ ACTUELLE" Section ───────────────
                        if (chat.currentActivity != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.themeColors.bgSurfaceDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ACTIVITÉ ACTUELLE',
                                  style: TextStyle(
                                    color: context.themeColors.textPrimary
                                        .withOpacity(0.7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.gamepad,
                                        color: context.themeColors.textPrimary,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        chat.currentActivity!,
                                        style: TextStyle(
                                          color:
                                              context.themeColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Floating Avatar ───────────────────────────────────────────
          Positioned(
            top: 70, // 120 (banner) - 50 (radius) + shift down
            left: 20,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(6), // Border thickness
                  decoration: BoxDecoration(
                    color: context.themeColors.bgSurface, // Match background
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: _getImageProvider(chat.avatarUrl),
                    child: chat.avatarUrl == null || chat.avatarUrl!.isEmpty
                        ? Text(chat.name[0],
                            style: TextStyle(
                                fontSize: 32,
                                color: context.themeColors.textPrimary))
                        : null,
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: context.themeColors.bgSurface, // Border
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.themeColors.colorSuccess,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
