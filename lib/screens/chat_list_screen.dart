import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/traveler_profile.dart';
import '../services/social_service.dart';
import '../widgets/liquid_background.dart';
import 'real_time_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SocialService>().setLocationSharing(true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: Consumer<SocialService>(
            builder: (context, social, _) {
              final query = _searchController.text.trim();
              final allTravelers = social.searchTravelers(query);
              final travelers = allTravelers
                  .where((t) => t.uid != social.currentUserId)
                  .toList(growable: false);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(
                      children: [
                        _circleBtn(
                          Icons.arrow_back_ios_new,
                          () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Traveler Discovery',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  color: Color(0xFF10233D),
                                ),
                              ),
                              Text(
                                'Search by unique username and tap profile to chat',
                                style: TextStyle(color: Color(0xFF0D8AA8)),
                              ),
                            ],
                          ),
                        ),
                        _circleBtn(
                          social.locationSharingEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          () => social.setLocationSharing(
                            !social.locationSharingEnabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search travelers by username',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: travelers.isEmpty
                        ? const Center(
                            child: Text(
                              'No travelers found yet.\nInvite others or try a different username search.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                            itemCount: travelers.length,
                            itemBuilder: (context, index) {
                              final traveler = travelers[index];
                              return _travelerCard(context, social, traveler);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _travelerCard(
    BuildContext context,
    SocialService social,
    TravelerProfile traveler,
  ) {
    final isFollowing = social.isFollowing(traveler.uid);
    final meters = social.distanceToTraveler(traveler);
    final distanceText = meters == null
        ? (traveler.locationSharingEnabled
              ? 'Location available'
              : 'Location hidden')
        : '${(meters / 1000).toStringAsFixed(1)} km away';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RealTimeChatScreen(
              peerId: traveler.uid,
              name: traveler.displayName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8A7CFF).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE6F5FA),
              child: Text(
                traveler.displayName.isEmpty
                    ? '?'
                    : traveler.displayName[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10233D),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    traveler.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10233D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${traveler.username} • $distanceText',
                    style: TextStyle(color: Colors.blueGrey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => social.toggleFollow(traveler.uid),
              child: Text(isFollowing ? 'Following' : 'Follow'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF10233D)),
      ),
    );
  }
}
