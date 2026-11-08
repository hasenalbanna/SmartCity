import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/community_issue_service.dart';
import '../services/geocoding_service.dart';

class ReportCategory {
  final String title;
  final String localTitle;
  final IconData icon;

  const ReportCategory({
    required this.title,
    required this.localTitle,
    required this.icon,
  });
}

class ReportIssueWizardScreen extends StatefulWidget {
  const ReportIssueWizardScreen({super.key});

  @override
  State<ReportIssueWizardScreen> createState() => _ReportIssueWizardScreenState();
}

class _ReportIssueWizardScreenState extends State<ReportIssueWizardScreen> {
  int _currentStep = 0; // 0 = Category, 1 = Location, 2 = Details

  // Step 1: Category
  int _selectedCategoryIndex = 4; // Default to Street Lights as in screenshot
  final List<ReportCategory> _categories = const [
    ReportCategory(
      title: 'Drainage/Canal',
      localTitle: 'வடிகால்',
      icon: Icons.near_me_outlined,
    ),
    ReportCategory(
      title: 'Garbage Dump',
      localTitle: 'குப்பை',
      icon: Icons.warning_amber_rounded,
    ),
    ReportCategory(
      title: 'Road/Pothole',
      localTitle: 'வீதி',
      icon: Icons.location_on_outlined,
    ),
    ReportCategory(
      title: 'Coastal Erosion',
      localTitle: 'கடல் அரிப்பு',
      icon: Icons.shield_outlined,
    ),
    ReportCategory(
      title: 'Street Lights',
      localTitle: 'வீதி விளக்கு',
      icon: Icons.check_circle_outline,
    ),
    ReportCategory(
      title: 'Other Issues',
      localTitle: 'பிற பிரச்சினைகள்',
      icon: Icons.help_outline,
    ),
  ];

  // Step 2: Location
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(7.3486, 81.8494); // Nintavur
  final TextEditingController _searchRoadController = TextEditingController();
  String _addressText = 'Nintavur, Ampara District, Eastern Province, 32340, Sri Lanka';
  bool _isLocating = false;

  // Step 3: Details
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final GlobalKey<FormState> _detailsFormKey = GlobalKey<FormState>();
  String? _pickedImagePath;
  bool _hasAudio = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _searchRoadController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final userLatLng = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _selectedLocation = userLatLng;
          _addressText = 'Coordinates: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        });
        _mapController.move(userLatLng, 15.0);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission not granted. Tap map to select location.')),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _searchRoad() async {
    final query = _searchRoadController.text.trim();
    if (query.isEmpty) return;

    final geocoding = GeocodingService();
    final results = await geocoding.searchPlaces('$query, Sri Lanka');
    if (results.isNotEmpty && mounted) {
      final first = results.first;
      setState(() {
        _selectedLocation = first.location;
        _addressText = first.displayName;
      });
      _mapController.move(first.location, 15.0);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place not found. Tap on map to set marker.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (image != null && mounted) {
      setState(() {
        _pickedImagePath = image.path;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_detailsFormKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final category = _categories[_selectedCategoryIndex];
    final issueService = context.read<CommunityIssueService>();

    final desc = _descriptionController.text.trim();
    final title = desc.length > 40 ? '${desc.substring(0, 37)}...' : (desc.isEmpty ? '${category.title} Issue' : desc);

    await issueService.addIssue(
      category: category.title.toUpperCase(),
      categoryLocal: category.localTitle,
      title: title,
      description: desc,
      address: _addressText,
      location: _selectedLocation,
      contactNumber: _contactController.text.trim(),
      imagePath: _pickedImagePath,
      hasAudio: _hasAudio,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Community issue reported successfully!'),
        backgroundColor: Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101318) : Colors.white,
      appBar: _buildTopBar(isDark),
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(isDark),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildStepCategory(isDark),
                  _buildStepLocation(isDark),
                  _buildStepDetails(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Report Issue',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                'EN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? Colors.white : Colors.black)
                    : (isDark ? Colors.white24 : const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 1: CATEGORY SELECTION
  // -------------------------------------------------------------
  Widget _buildStepCategory(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Category',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.35,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategoryIndex == index;

              return InkWell(
                onTap: () {
                  setState(() => _selectedCategoryIndex = index);
                  // Automatically advance to Step 2
                  Future.delayed(const Duration(milliseconds: 180), () {
                    if (mounted) setState(() => _currentStep = 1);
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? (isSelected ? Colors.white10 : Colors.white.withValues(alpha: 0.04))
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat.icon,
                        size: 30,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        cat.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cat.localTitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // STEP 2: LOCATION
  // -------------------------------------------------------------
  Widget _buildStepLocation(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Mark Location',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),

              // Road search row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                        ),
                      ),
                      child: TextField(
                        controller: _searchRoadController,
                        onSubmitted: (_) => _searchRoad(),
                        decoration: const InputDecoration(
                          hintText: 'Search road name in Nintavur',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _searchRoad,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Use My Current Location Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: _isLocating ? null : _useCurrentLocation,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location, size: 18),
                  label: const Text(
                    'Use My Current Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // Vibrant blue
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Interactive Map
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedLocation,
                      initialZoom: 14.5,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                          _addressText = 'Pinned Location: ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.smartcity.app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: const [
                              LatLng(7.3780, 81.8385),
                              LatLng(7.3486, 81.8385),
                              LatLng(7.3180, 81.8385),
                            ],
                            strokeWidth: 2.5,
                            color: const Color(0xFFDC2626),
                          ),
                          Polyline(
                            points: const [
                              LatLng(7.3600, 81.8385),
                              LatLng(7.3600, 81.8650),
                            ],
                            strokeWidth: 2.5,
                            color: const Color(0xFFDC2626),
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_on,
                              size: 44,
                              color: Color(0xFFEF4444), // Vibrant Red
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Tap map to pin badge & Zoom Controls Top Left
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Tap map to pin',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => _mapController.move(
                                  _mapController.camera.center,
                                  _mapController.camera.zoom + 1,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.add, size: 18, color: Colors.black87),
                                ),
                              ),
                              const Divider(height: 1, thickness: 1),
                              InkWell(
                                onTap: () => _mapController.move(
                                  _mapController.camera.center,
                                  _mapController.camera.zoom - 1,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.remove, size: 18, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Crosshair / Center button bottom left
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, size: 18, color: Colors.black87),
                        onPressed: () => _mapController.move(_selectedLocation, 15.0),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // Leaflet | OpenStreetMap attribution bottom right
                  Positioned(
                    bottom: 6,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Leaflet | © OpenStreetMap contributors',
                        style: TextStyle(fontSize: 10, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Confirm Location Button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _currentStep = 2);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7280), // Slate gray as in screenshot
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Confirm Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // STEP 3: DETAILS
  // -------------------------------------------------------------
  Widget _buildStepDetails(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _detailsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // DESCRIPTION
            Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                ),
              ),
              child: Stack(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter a short description of the issue';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Describe the issue...',
                      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Icon(
                      Icons.format_size,
                      size: 14,
                      color: isDark ? Colors.white24 : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CONTACT NUMBER *
            RichText(
              text: TextSpan(
                text: 'CONTACT NUMBER ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                ),
                children: const [
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                ),
              ),
              child: TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a contact number';
                  }
                  if (val.trim().length < 7) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter your contact number',
                  hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Add Photo & Record Audio side-by-side
            Row(
              children: [
                Expanded(
                  child: _dashedMediaButton(
                    icon: Icons.camera_alt_outlined,
                    label: _pickedImagePath == null ? 'Add Photo' : 'Photo Attached ✓',
                    isDark: isDark,
                    isSelected: _pickedImagePath != null,
                    onTap: _pickImage,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _dashedMediaButton(
                    icon: Icons.mic_none_outlined,
                    label: _hasAudio ? 'Audio Added ✓' : 'Record Audio',
                    isDark: isDark,
                    isSelected: _hasAudio,
                    onTap: () {
                      setState(() => _hasAudio = !_hasAudio);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_hasAudio ? 'Voice memo recorded' : 'Voice memo removed'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Submit Report Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _dashedMediaButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.white12 : const Color(0xFFEFF6FF))
              : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2563EB)
                : (isDark ? Colors.white24 : const Color(0xFFD1D5DB)),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF2563EB) : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
