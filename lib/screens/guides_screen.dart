import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/guide.dart';
import 'guide_profile_screen.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  static const Color _bg = Color(0xFFF4F7FB);
  static const Color _card = Colors.white;
  static const Color _primary = Color(0xFF0D8AA8);
  static const Color _text = Color(0xFF10233D);
  static const Color _muted = Color(0xFF7788A3);

  int _selectedFilter = 0;
  final List<String> _filters = [
    'All Guides',
    'Cultural',
    'Wildlife',
    'Adventure',
  ];

  List<Guide> get _filtered {
    if (_selectedFilter == 0) return mockGuides;
    final keyword = _filters[_selectedFilter].toLowerCase();
    return mockGuides
        .where((g) => g.expertise.toLowerCase().contains(keyword))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: _buildSearch(),
            ),
            SizedBox(
              height: 42,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => _buildFilterChip(i),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: _filters.length,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                itemBuilder: (_, i) => _buildGuideCard(_filtered[i]),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: _filtered.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _circleButton(
            Icons.arrow_back_ios_new,
            onTap: () => Navigator.maybePop(context),
          ),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Our Professional Guides',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: _text,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Smart City Verified',
                  style: TextStyle(color: _primary, fontSize: 11),
                ),
              ],
            ),
          ),
          _circleButton(
            Icons.tune,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Filter options coming soon')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: _text),
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4E9F2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: _primary, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search by name, language or region',
              style: TextStyle(color: _muted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index) {
    final selected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? _primary : const Color(0xFFE5EFF2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          _filters[index],
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF537288),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(Guide guide) {
    final langs = guide.languages
        .split(',')
        .map((e) => e.trim())
        .take(3)
        .toList();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE1EEF2),
                backgroundImage: guide.photoUrl != null
                    ? NetworkImage(guide.photoUrl!)
                    : null,
                child: guide.photoUrl == null
                    ? Text(
                        guide.name.split(' ').map((p) => p[0]).take(2).join(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _text,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 1,
                right: 0,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1FC66A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        guide.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _text,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.star_outline, color: _primary, size: 14),
                    Text(
                      ' ${guide.rating.toStringAsFixed(1)} ',
                      style: const TextStyle(
                        color: _primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '(${guide.reviewCount})',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  '${guide.yearsOfExperience} Years Experience',
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: langs
                      .map(
                        (l) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9EEF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            l.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: _text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'STARTING FROM',
                      style: TextStyle(
                        fontSize: 9,
                        color: _muted,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GuideProfileScreen(guide: guide),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '\$${guide.dailyRate.toInt()}',
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: _primary,
                      ),
                    ),
                    const Text('/day', style: TextStyle(color: _muted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
