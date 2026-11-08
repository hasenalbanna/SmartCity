import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/social_service.dart';
import '../widgets/liquid_background.dart';
import '../widgets/app_top_utilities.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFB8C1D1)
        : const Color(0xFF6B7A93);

    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 120),
            children: [
              const AppTopUtilities(),
              Text(
                'Saved',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your favorite plans, places and bookings.',
                style: TextStyle(color: mutedColor),
              ),
              const SizedBox(height: 18),
              Consumer<SocialService>(
                builder: (context, social, _) {
                  final savedPosts = social.savedPosts;
                  final locations = savedPosts
                      .map((p) => p.placeName)
                      .toSet()
                      .toList(growable: false);

                  if (savedPosts.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.14)
                              : const Color(0xFFE6EEF7),
                        ),
                      ),
                      child: const Text(
                        'No saved items yet. Save posts from community feed to organize them here.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved Locations',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: locations
                            .map(
                              (loc) => Chip(
                                label: Text(loc),
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : const Color(0xFFEAF4FF),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Saved Images',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: savedPosts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final post = savedPosts[index];
                          final imageUrl = post.photoUrls.isEmpty
                              ? ''
                              : post.photoUrls.first;
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrl.isNotEmpty)
                                  Image.network(imageUrl, fit: BoxFit.cover)
                                else
                                  Container(color: const Color(0xFFEAF2F6)),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.65),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                  child: Text(
                                    post.placeName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
