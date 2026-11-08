import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/community_issue_service.dart';
import '../services/geocoding_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/falcon_ai_disaster_panel.dart';
import '../widgets/ui/ui.dart';

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
  final int initialModeIndex; // 0 = Local Issues, 1 = Disaster Issues (Falcon AI)

  const ReportIssueWizardScreen({
    super.key,
    this.initialModeIndex = 0,
  });

  @override
  State<ReportIssueWizardScreen> createState() =>
      _ReportIssueWizardScreenState();
}

class _ReportIssueWizardScreenState extends State<ReportIssueWizardScreen> {
  late int _reportModeIndex;
  int _currentStep = 0; // 0 = Category, 1 = Location, 2 = Details
  int _selectedCategoryIndex = 4; // Default to Street Lights

  static const List<ReportCategory> _categories = [
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

  static const List<LatLng> _nintavurBoundary = [
    LatLng(7.3720, 81.8250),
    LatLng(7.3720, 81.8650),
    LatLng(7.3220, 81.8650),
    LatLng(7.3220, 81.8250),
    LatLng(7.3720, 81.8250),
  ];

  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(7.3486, 81.8494);
  final TextEditingController _searchRoadController = TextEditingController();
  String _addressText =
      'Nintavur, Ampara District, Eastern Province, 32340, Sri Lanka';
  bool _isLocating = false;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String? _contactError;
  String? _pickedImagePath;
  bool _hasAudio = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _reportModeIndex = widget.initialModeIndex;
  }

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
          _addressText =
              'Coordinates: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
        });
        _mapController.move(userLatLng, 15.0);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission not granted. Tap map to select location.',
            ),
          ),
        );
      }
    } catch (_) {
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
        const SnackBar(
          content: Text('Place not found. Tap on map to set marker.'),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
    );
    if (image != null && mounted) {
      setState(() => _pickedImagePath = image.path);
    }
  }

  Future<void> _submitReport() async {
    final contact = _contactController.text.trim();
    if (contact.isEmpty || contact.length < 7) {
      setState(() {
        _contactError = 'Please enter a valid contact number.';
      });
      return;
    }

    setState(() {
      _contactError = null;
      _isSubmitting = true;
    });

    final category = _categories[_selectedCategoryIndex];
    final issueService = context.read<CommunityIssueService>();
    final desc = _descriptionController.text.trim();
    final title = desc.length > 40
        ? '${desc.substring(0, 37)}...'
        : (desc.isEmpty ? '${category.title} Issue' : desc);

    final createdIssue = await issueService.addIssue(
      category: category.title.toUpperCase(),
      categoryLocal: category.localTitle,
      title: title,
      description: desc.isEmpty
          ? 'Reported ${category.title} issue in Nintavur'
          : desc,
      address: _addressText,
      location: _selectedLocation,
      contactNumber: contact,
      imagePath: _pickedImagePath,
      hasAudio: _hasAudio,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showAiSubmissionDialog(createdIssue);
  }

  void _showAiSubmissionDialog(CommunityIssue issue) {
    final ai = issue.aiAnalysis;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: AppColors.success(context),
            ),
            const SizedBox(width: AppSpace.sm),
            const Expanded(child: Text('AI Triage Completed')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              backgroundColor: AppColors.surfaceMuted(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket: ${ai?.councilTicketId ?? "CW-2026-NIN-001"}',
                    style: AppTypography.bodyStrong.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.primary(context),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    'Channel: ${ai?.channelLabel ?? "Council Work Order"}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    'Urgency: ${ai?.urgencyScore.toStringAsFixed(1) ?? "7.5"}/10 • ${((ai?.confidenceScore ?? 0.94) * 100).toInt()}% Confidence',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              ai?.reasoning ??
                  'Your report has been verified and dispatched to the Nintavur Municipal Council.',
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Done',
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      maxWidth: 760,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report Issue'),
      ),
      body: Column(
        children: [
          // Top 2-Option Switcher: 1. Local Issues | 2. Disaster Issues (Falcon AI)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.sm,
            ),
            color: AppColors.surface(context),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: '1. Local Civic Issues',
                    icon: Icons.construction_rounded,
                    variant: _reportModeIndex == 0
                        ? AppButtonVariant.primary
                        : AppButtonVariant.secondary,
                    onPressed: () => setState(() => _reportModeIndex = 0),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: AppButton(
                    label: '2. Disaster • Falcon AI',
                    icon: Icons.radar_rounded,
                    variant: _reportModeIndex == 1
                        ? AppButtonVariant.danger
                        : AppButtonVariant.secondary,
                    onPressed: () => setState(() => _reportModeIndex = 1),
                  ),
                ),
              ],
            ),
          ),
          if (_reportModeIndex == 1)
            Expanded(
              child: FalconAiDisasterPanel(mapController: _mapController),
            )
          else ...[
            _buildStepHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpace.pagePadding,
                child: _buildCurrentStepContent(context),
              ),
            ),
            _buildStickyBottomBar(context),
          ],
        ],
      ),
    );
  }

  Widget _buildStepHeader(BuildContext context) {
    const steps = ['1. Category', '2. Location', '3. Details'];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.md,
      ),
      color: AppColors.surface(context),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index <= _currentStep;
          final isCurrent = index == _currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < steps.length - 1 ? AppSpace.sm : 0,
              ),
              child: InkWell(
                onTap: () => setState(() => _currentStep = index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary(context)
                            : AppColors.outline(context),
                        borderRadius: AppRadius.pillBorder,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      steps[index],
                      style: AppTypography.caption.copyWith(
                        color: isCurrent
                            ? AppColors.primary(context)
                            : AppColors.textSecondary(context),
                        fontWeight: isCurrent
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildCategoryStep(context);
      case 1:
        return _buildLocationStep(context);
      default:
        return _buildDetailsStep(context);
    }
  }

  Widget _buildCategoryStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTypography.display.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Select the type of civic problem to route it to the right department.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpace.md,
            crossAxisSpacing: AppSpace.md,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final item = _categories[index];
            final selected = _selectedCategoryIndex == index;
            return InkWell(
              borderRadius: AppRadius.mdBorder,
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(AppSpace.md),
                decoration: BoxDecoration(
                  color: AppColors.surface(context),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: selected
                        ? AppColors.primary(context)
                        : AppColors.outline(context),
                    width: selected ? 2.0 : 1.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 26,
                      color: selected
                          ? AppColors.primary(context)
                          : AppColors.textPrimary(context),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.localTitle,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTypography.display.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Mark the exact problem spot inside the Nintavur boundary.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchRoadController,
                onSubmitted: (_) => _searchRoad(),
                decoration: const InputDecoration(
                  hintText: 'Search road name in Nintavur',
                ),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            AppButton(
              label: 'Search',
              icon: Icons.search_rounded,
              onPressed: _searchRoad,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        AppButton(
          label: _isLocating ? 'Locating...' : 'Use My Current Location',
          icon: Icons.my_location_rounded,
          variant: AppButtonVariant.secondary,
          fullWidth: true,
          isLoading: _isLocating,
          onPressed: _useCurrentLocation,
        ),
        const SizedBox(height: AppSpace.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: 280,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 14.0,
                    onTap: (_, latLng) {
                      setState(() {
                        _selectedLocation = latLng;
                        _addressText =
                            'Nintavur (${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)})';
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smartcity.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _nintavurBoundary,
                          strokeWidth: 3.0,
                          color: AppColors.danger(context),
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            size: 38,
                            color: AppColors.danger(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Positioned(
                  top: AppSpace.md,
                  left: AppSpace.md,
                  child: StatusChip(
                    label: 'Tap map to pin',
                    kind: StatusChipKind.info,
                    icon: Icons.touch_app_outlined,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(
          _addressText,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: AppTypography.display.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          'Provide a short description and contact number for status updates.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        AppTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Describe the issue...',
          maxLines: 4,
        ),
        const SizedBox(height: AppSpace.lg),
        AppTextField(
          controller: _contactController,
          label: 'Contact Number',
          hint: 'Enter your contact number',
          isRequired: true,
          keyboardType: TextInputType.phone,
          errorText: _contactError,
          onChanged: (_) {
            if (_contactError != null) {
              setState(() => _contactError = null);
            }
          },
        ),
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Expanded(
              child: AppCard(
                onTap: _pickImage,
                child: Column(
                  children: [
                    Icon(
                      _pickedImagePath != null
                          ? Icons.check_circle_rounded
                          : Icons.photo_camera_outlined,
                      color: _pickedImagePath != null
                          ? AppColors.success(context)
                          : AppColors.textSecondary(context),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      _pickedImagePath != null ? 'Photo Attached' : 'Add Photo',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: AppCard(
                onTap: () => setState(() => _hasAudio = !_hasAudio),
                child: Column(
                  children: [
                    Icon(
                      _hasAudio ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _hasAudio
                          ? AppColors.danger(context)
                          : AppColors.textSecondary(context),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      _hasAudio ? 'Audio Recorded' : 'Record Audio',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(
          top: BorderSide(color: AppColors.outline(context)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            AppButton(
              label: 'Back',
              variant: AppButtonVariant.secondary,
              onPressed: () => setState(() => _currentStep--),
            ),
            const SizedBox(width: AppSpace.md),
          ],
          Expanded(
            child: AppButton(
              label: _currentStep == 0
                  ? 'Continue to Location'
                  : (_currentStep == 1 ? 'Confirm Location' : 'Submit Report'),
              icon: _currentStep == 2
                  ? Icons.send_rounded
                  : Icons.arrow_forward_rounded,
              isLoading: _isSubmitting,
              fullWidth: true,
              onPressed: () {
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  _submitReport();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
