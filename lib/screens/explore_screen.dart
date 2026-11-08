import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import 'community_feed_screen.dart';
import 'guides_screen.dart';
import '../widgets/liquid_background.dart';
import '../widgets/app_top_utilities.dart';
import '../widgets/water_glow_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ProvinceMeta {
  final String name;
  final String coverImagePath;
  final String heroImagePath;
  final List<String> galleryImages;
  final int annualVisitors;
  final int satisfactionRate;
  final String hotspot;

  const _ProvinceMeta({
    required this.name,
    required this.coverImagePath,
    required this.heroImagePath,
    required this.galleryImages,
    required this.annualVisitors,
    required this.satisfactionRate,
    required this.hotspot,
  });
}

class _MustSeePlace {
  final String name;
  final String tag;
  final String imagePath;
  final double rating;
  final String summary;
  final String history;

  const _MustSeePlace({
    required this.name,
    required this.tag,
    required this.imagePath,
    required this.rating,
    required this.summary,
    required this.history,
  });
}

class _ProvinceComment {
  final String author;
  final String text;
  int likes;
  bool likedByMe = false;
  final DateTime createdAt;

  _ProvinceComment({
    required this.author,
    required this.text,
    required this.likes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _selectedBookingTab = 0;
  final List<String> _bookingTabs = ['All', 'Hotels', 'Resorts', 'Villas'];
  final List<_MustSeePlace> _mustSeePlaces = const [
    _MustSeePlace(
      name: 'Sigiriya',
      tag: 'Lion Rock',
      imagePath: 'assets/images/sigiriya.jpg',
      rating: 4.9,
      summary:
          'Ancient sky fortress with frescoes, mirror wall, and 360-degree jungle views.',
      history:
          'Sigiriya was transformed into a royal citadel by King Kasyapa in the 5th century. The site includes advanced hydraulic gardens and defensive walls, reflecting one of South Asia\'s most sophisticated early urban plans.',
    ),
    _MustSeePlace(
      name: 'Galle Fort',
      tag: 'Historic',
      imagePath: 'assets/images/galle_fort.jpg',
      rating: 4.8,
      summary:
          'A UNESCO-listed coastal fort city with colonial streets, cafes, and sunset ramparts.',
      history:
          'First built by the Portuguese in the 16th century and fortified by the Dutch in the 17th century, Galle Fort became a key maritime defense point. Its preserved grid layout and bastions remain a living heritage district today.',
    ),
    _MustSeePlace(
      name: 'Temple of Tooth',
      tag: 'Sacred',
      imagePath: 'assets/central province/temple of tooth.jpg',
      rating: 4.7,
      summary:
          'Sri Lanka\'s most revered Buddhist temple complex in the heart of Kandy.',
      history:
          'The temple houses the sacred tooth relic of Buddha, which historically symbolized royal legitimacy in Sri Lanka. The shrine has long served as a political and spiritual center, especially during the Kandyan Kingdom era.',
    ),
  ];

  final List<_ProvinceMeta> _provinces = const [
    _ProvinceMeta(
      name: 'Central',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/CENTRAL.png',
      heroImagePath: 'assets/central province/knuckles.jpg',
      galleryImages: [
        'assets/central province/knuckles.jpg',
        'assets/central province/nuwara eliya tea country.jpg',
        'assets/central province/sigiriya.jpg',
        'assets/central province/temple of tooth.jpg',
      ],
      annualVisitors: 1850000,
      satisfactionRate: 96,
      hotspot: 'Sigiriya & Kandy cultural route',
    ),
    _ProvinceMeta(
      name: 'Western',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/WESTERN.png',
      heroImagePath: 'assets/western province/galle-face.jpg',
      galleryImages: [
        'assets/western province/duch hospital shopping precinct.jpg',
        'assets/western province/galle-face.jpg',
        'assets/western province/Gangaramaya-Temple.jpg',
        'assets/western province/mount lavinia beach.jpg',
        'assets/western province/museum.jpg',
      ],
      annualVisitors: 2120000,
      satisfactionRate: 94,
      hotspot: 'Colombo city waterfront',
    ),
    _ProvinceMeta(
      name: 'Southern',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/SOTHERN.png',
      heroImagePath: 'assets/southern province/mirissa beach.jpg',
      galleryImages: [
        'assets/southern province/coral garden.jpg',
        'assets/southern province/galle fort.jpg',
        'assets/southern province/mirissa beach.jpg',
        'assets/southern province/Yala.avif',
      ],
      annualVisitors: 1730000,
      satisfactionRate: 95,
      hotspot: 'Galle Fort and Mirissa coast',
    ),
    _ProvinceMeta(
      name: 'Eastern',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/EASTERN.png',
      heroImagePath: 'assets/eastern province/arugam bay.jpg',
      galleryImages: [
        'assets/eastern province/arugam bay.jpg',
        'assets/eastern province/batticaloa fort.jpg',
        'assets/eastern province/kumana national park.jpg',
        'assets/eastern province/pasikuda beach.jpg',
      ],
      annualVisitors: 920000,
      satisfactionRate: 93,
      hotspot: 'Arugam Bay surf belt',
    ),
    _ProvinceMeta(
      name: 'Uva',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/UVA.png',
      heroImagePath: 'assets/uva province/ella rock.webp',
      galleryImages: [
        'assets/uva province/dambana.jpg',
        'assets/uva province/ella rock.webp',
        'assets/uva province/ravana falls.jpg',
      ],
      annualVisitors: 840000,
      satisfactionRate: 92,
      hotspot: 'Ella trails and waterfalls',
    ),
    _ProvinceMeta(
      name: 'North Central',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/NORTHCENTRAL.png',
      heroImagePath:
          'assets/north central province/minneriya national park.jpg',
      galleryImages: [
        'assets/north central province/encient city of plonnaruwa.jpg',
        'assets/north central province/kala wewa.jpg',
        'assets/north central province/minneriya national park.jpg',
      ],
      annualVisitors: 780000,
      satisfactionRate: 91,
      hotspot: 'Ancient city circuit',
    ),
    _ProvinceMeta(
      name: 'North Western',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/NORTHWESTERN.png',
      heroImagePath: 'assets/north western province/puttalam lagoon.jpg',
      galleryImages: [
        'assets/north western province/puttalam lagoon.jpg',
        'assets/north western province/ridi viharaya.jpg',
        'assets/north western province/yapahuwa.jpg',
      ],
      annualVisitors: 610000,
      satisfactionRate: 90,
      hotspot: 'Lagoon escapes and heritage',
    ),
    _ProvinceMeta(
      name: 'Northern',
      coverImagePath: 'assets/nothern province/nallur kovil.jpg',
      heroImagePath: 'assets/nothern province/jaffna fort.avif',
      galleryImages: [
        'assets/nothern province/casuarina beach.webp',
        'assets/nothern province/delft island.jpg',
        'assets/nothern province/jaffna fort.avif',
        'assets/nothern province/keerimalai hot springs.jpg',
        'assets/nothern province/nallur kovil.jpg',
      ],
      annualVisitors: 560000,
      satisfactionRate: 89,
      hotspot: 'Jaffna peninsula cultural trail',
    ),
    _ProvinceMeta(
      name: 'Sabaragamuwa',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/SABARAGAMUWA.png',
      heroImagePath: 'assets/sabaragamuwa province/sinharaja.jpg',
      galleryImages: [
        'assets/sabaragamuwa province/bopath ella.jpg',
        'assets/sabaragamuwa province/Ratnapura gem mines.jpg',
        'assets/sabaragamuwa province/sinharaja.jpg',
      ],
      annualVisitors: 730000,
      satisfactionRate: 94,
      hotspot: 'Sinharaja rain forest belt',
    ),
  ];

  final Map<String, List<_ProvinceComment>> _commentsByProvince = {};
  final Map<String, int> _liveVisitorsByProvince = {};
  final TextEditingController _commentController = TextEditingController();
  Timer? _liveTicker;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    for (final province in _provinces) {
      _liveVisitorsByProvince[province.name] =
          (province.annualVisitors / 365).round() + 120;
      _commentsByProvince[province.name] = [
        _ProvinceComment(
          author: 'Nadeesha',
          text: 'Loved the vibe here. Great for a 2-day trip with family.',
          likes: 18,
        ),
        _ProvinceComment(
          author: 'Alex',
          text: 'Transport was smooth and locals were very welcoming.',
          likes: 11,
        ),
      ];
    }
    _startLiveTicker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<WeatherService>().refreshNow();
    });
  }

  @override
  void dispose() {
    _liveTicker?.cancel();
    _commentController.dispose();
    super.dispose();
  }

  void _startLiveTicker() {
    _liveTicker = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        for (final province in _provinces) {
          final current = _liveVisitorsByProvince[province.name] ?? 100;
          final delta = _random.nextInt(31) - 15;
          _liveVisitorsByProvince[province.name] = max(80, current + delta);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionTitleColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF1F2937);
    final accentColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTopUtilities(),
                _animatedSection(
                  delayMs: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: _openAllProvincesSheet,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.14)
                                        : Colors.black.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Icon(
                                  Icons.menu,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const GuidesScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.14,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.nightlight_round,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CommunityFeedScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.14,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'Explore.',
                          style: TextStyle(
                            fontSize: 58,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2.2,
                            height: 0.95,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.14)
                                  : Colors.black.withValues(alpha: 0.10),
                            ),
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Where to next?',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.65)
                                    : Colors.black.withValues(alpha: 0.50),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTopWeatherPreviewCard(isDark),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _animatedSection(
                  delayMs: 180,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CommunityFeedScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.auto_awesome_mosaic),
                        label: const Text('Align Traveler Uploads (AI Order)'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Must-See Today Section
                _animatedSection(
                  delayMs: 220,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Must-See Today',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: sectionTitleColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _mustSeePlaces.length,
                    itemBuilder: (context, index) {
                      return _buildMustSeeCard(_mustSeePlaces[index]);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildProvinceSection(
                  isDark: isDark,
                  sectionTitleColor: sectionTitleColor,
                ),
                const SizedBox(height: 24),

                // Booking Hub Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Booking Hub',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: sectionTitleColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _bookingTabs.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedBookingTab == index;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedBookingTab = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? accentColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              _bookingTabs[index],
                              style: TextStyle(
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : isDark
                                    ? const Color(0xFFA9B7CE)
                                    : Colors.grey[600],
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildBookingCard(
                        'Ella Jungle Resort',
                        'Ella, Hill Country',
                        '\$89/night',
                        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&q=80&w=400',
                        4.8,
                      ),
                      _buildBookingCard(
                        'Galle Heritage Villa',
                        'Galle Fort',
                        '\$120/night',
                        'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&q=80&w=400',
                        4.9,
                      ),
                      _buildBookingCard(
                        'Sigiriya Royal Resort',
                        'Near Lion Rock',
                        '\$150/night',
                        'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&q=80&w=400',
                        4.7,
                      ),
                      _buildBookingCard(
                        'Kandy Lake Villa',
                        'Kandy Lake View',
                        '\$95/night',
                        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&q=80&w=400',
                        4.6,
                      ),
                      _buildBookingCard(
                        'Mirissa Beach Resort',
                        'Mirissa Beach',
                        '\$110/night',
                        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&q=80&w=400',
                        4.8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Local Events Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Local Events',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: sectionTitleColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildEventCard(
                  'Kandy Perahera',
                  'Aug 24 - Sep 02',
                  'Traditional Buddhist festival',
                ),
                _buildEventCard(
                  'Colombo Food Festival',
                  'Mar 15 - Mar 18',
                  'Taste the best of Sri Lankan cuisine',
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMustSeeCard(_MustSeePlace place) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: WaterGlowCard(
        onTap: () => _openMustSeeDetails(place),
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildAdaptiveImage(place.imagePath),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      place.tag,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMustSeeDetails(_MustSeePlace place) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.65,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: _buildAdaptiveImage(
                      place.imagePath,
                      height: 220,
                      width: double.infinity,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    place.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? const Color(0xFFEAF1FF)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${place.rating}  •  ${place.tag}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    place.summary,
                    style: TextStyle(
                      height: 1.5,
                      color: isDark
                          ? const Color(0xFFD7E0F0)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Historical Background',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? const Color(0xFFEAF1FF)
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    place.history,
                    style: TextStyle(
                      height: 1.6,
                      color: isDark
                          ? const Color(0xFFD7E0F0)
                          : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProvinceSection({
    required bool isDark,
    required Color sectionTitleColor,
  }) {
    return _animatedSection(
      delayMs: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explore Provinces',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: sectionTitleColor,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openAllProvincesSheet,
                  icon: const Icon(Icons.grid_view_rounded, size: 16),
                  label: const Text('See More'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 232,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _provinces.length,
              itemBuilder: (context, index) {
                final province = _provinces[index];
                return _buildProvinceCard(
                  province,
                  isDark: isDark,
                  margin: const EdgeInsets.only(right: 14),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceCard(
    _ProvinceMeta province, {
    required bool isDark,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    final liveNow = _liveVisitorsByProvince[province.name] ?? 100;
    final point = context.watch<WeatherService>().provinceWeatherOf(
      province.name,
    );
    return Container(
      width: 236,
      margin: margin,
      child: WaterGlowCard(
        onTap: () => _openProvinceDetails(province),
        borderRadius: BorderRadius.circular(22),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                province.coverImagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAdaptiveImage(province.heroImagePath);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        WeatherService.weatherIcon(point?.weatherCode ?? 0),
                        size: 13,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        point == null
                            ? '--'
                            : '${point.temperatureC.toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_alt_outlined,
                        size: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$liveNow live',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      province.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 21,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      province.hotspot,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAllProvincesSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          maxChildSize: 0.95,
          minChildSize: 0.6,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141923)
                    : const Color(0xFFF1F3F6),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'All Provinces',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.95,
                          ),
                      itemCount: _provinces.length,
                      itemBuilder: (context, index) {
                        final province = _provinces[index];
                        return _buildProvinceCard(province, isDark: isDark);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openProvinceDetails(_ProvinceMeta province) {
    _commentController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, localSetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final comments =
                _commentsByProvince[province.name] ?? <_ProvinceComment>[];
            final liveNow = _liveVisitorsByProvince[province.name] ?? 0;

            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.7,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF101622) : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 190,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _buildAdaptiveImage(province.heroImagePath),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.72),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 14,
                                bottom: 14,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      province.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 27,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      province.hotspot,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (province.galleryImages.isNotEmpty) ...[
                        Text(
                          'Related Places in ${province.name}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? const Color(0xFFEAF1FF)
                                : const Color(0xFF122033),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 94,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: province.galleryImages.length,
                            itemBuilder: (context, index) {
                              final image = province.galleryImages[index];
                              return Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildAdaptiveImage(image),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatTile(
                              'Annual Tourists',
                              _formatCompact(province.annualVisitors),
                              Icons.flight_takeoff_rounded,
                              isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatTile(
                              'Live Visitors',
                              '$liveNow',
                              Icons.people_alt_rounded,
                              isDark
                                  ? Colors.white.withValues(alpha: 0.85)
                                  : Colors.black.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatTile(
                              'Satisfaction',
                              '${province.satisfactionRate}%',
                              Icons.thumb_up_alt_rounded,
                              isDark
                                  ? Colors.white.withValues(alpha: 0.70)
                                  : Colors.black.withValues(alpha: 0.70),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Traveler Comments',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isDark
                              ? const Color(0xFFEAF1FF)
                              : const Color(0xFF122033),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : const Color(0xFFF2F4F6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : const Color(0xFFDADDE3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                decoration: const InputDecoration(
                                  hintText: 'Share your experience...',
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                final text = _commentController.text.trim();
                                if (text.isEmpty) return;
                                localSetState(() {
                                  comments.insert(
                                    0,
                                    _ProvinceComment(
                                      author: 'You',
                                      text: text,
                                      likes: 0,
                                    ),
                                  );
                                  _commentController.clear();
                                });
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.white
                                    : Colors.black,
                                foregroundColor: isDark
                                    ? Colors.black
                                    : Colors.white,
                              ),
                              child: const Text('Post'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...comments.map((comment) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : const Color(0xFFF9FBFF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: isDark
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.12),
                                child: Text(
                                  comment.author[0],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.author,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(comment.text),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            localSetState(() {
                                              if (comment.likedByMe) {
                                                comment.likedByMe = false;
                                                comment.likes = max(
                                                  0,
                                                  comment.likes - 1,
                                                );
                                              } else {
                                                comment.likedByMe = true;
                                                comment.likes += 1;
                                              }
                                            });
                                            setState(() {});
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                comment.likedByMe
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                          .favorite_border_rounded,
                                                size: 17,
                                                color: comment.likedByMe
                                                    ? const Color(0xFFFF5A7A)
                                                    : Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${comment.likes}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          _relativeTime(comment.createdAt),
                                          style: TextStyle(
                                            color: Colors.grey.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color tone) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF2F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: tone),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final d = DateTime.now().difference(time);
    if (d.inMinutes < 1) return 'now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  String _formatCompact(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return '$number';
  }

  Widget _buildAdaptiveImage(
    String imagePath, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Color? fallbackColor,
  }) {
    final fallback = Container(
      width: width,
      height: height,
      color: fallbackColor ?? Colors.grey[300],
      child: const Center(
        child: Icon(Icons.landscape, size: 40, color: Colors.grey),
      ),
    );

    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (c, e, s) => fallback,
      );
    }

    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (c, e, s) => fallback,
    );
  }

  Widget _buildTopWeatherPreviewCard(bool isDark) {
    return Consumer<WeatherService>(
      builder: (context, weather, _) {
        final point = weather.currentWeather;
        final code = point?.weatherCode ?? -1;
        final image = _weatherPreviewImage(code);
        final title = point == null
            ? 'Current Location'
            : weather.currentLabel == 'Current Location'
            ? 'Current Location'
            : weather.currentLabel;
        final subtitle = point == null
            ? 'Weather unavailable'
            : WeatherService.weatherLabel(point.weatherCode);

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 122,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(child: _buildAdaptiveImage(image)),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0.52),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        point == null
                            ? '--'
                            : '${point.temperatureC.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 40,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _weatherPreviewImage(int code) {
    if (code == 0) {
      return 'assets/western province/galle-face.jpg';
    }
    if (code == 1 || code == 2) {
      return 'assets/southern province/mirissa beach.jpg';
    }
    if (code == 3 || code == 45 || code == 48) {
      return 'assets/central province/nuwara eliya tea country.jpg';
    }
    if (code == 61 ||
        code == 63 ||
        code == 65 ||
        code == 80 ||
        code == 81 ||
        code == 82) {
      return 'assets/uva province/ravana falls.jpg';
    }
    if (code == 95 || code == 96 || code == 99) {
      return 'assets/eastern province/kumana national park.jpg';
    }
    return 'assets/cover.png';
  }

  Widget _buildBookingCard(
    String name,
    String location,
    String price,
    String imageUrl,
    double rating,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  imageUrl,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 110,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.hotel,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.55)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFFEAF1FF)
                        : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFFB5C3D8)
                            : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // Removed SizedBox(height: 4) to fix BOTTOM OVERFLOWED
                Text(
                  price,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String date, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.32)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A3345) : const Color(0xFFE9EDF2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.event,
              color: isDark ? Colors.white : Colors.black,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? const Color(0xFFEAF1FF)
                        : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFB7C2D9) : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: isDark ? const Color(0xFFA9B7CE) : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _animatedSection({required int delayMs, required Widget child}) {
    final duration = Duration(milliseconds: 440 + delayMs);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, section) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: section,
          ),
        );
      },
      child: child,
    );
  }
}
