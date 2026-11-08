import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../services/currency_service.dart';
import '../services/localization_service.dart';

import '../widgets/app_top_utilities.dart';
import '../widgets/liquid_background.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  String _selectedAirportCode = 'CMB';
  double _budgetUsd = 1200;
  int _stayDays = 6;
  final Set<String> _selectedInterests = {};
  bool _isGenerating = false;
  bool _isLoadingMap = false;
  String _plannerMode = 'Rule-based';

  List<_DayPlan> _generatedPlan = const [];
  List<_PlanPlace> _routeStops = const [];
  List<LatLng> _liveRoutePolyline = const [];
  final Map<String, double> _livePriceByPlace = {};
  double _estimatedTotal = 0;

  final _backend = _ItineraryBackendService();
  final _pricingService = _LivePricingService();
  final _transportService = _LiveTransportService();
  final _aiPlanner = _GeminiItineraryAI();

  static const List<_Airport> _airports = [
    _Airport(
      code: 'CMB',
      name: 'Bandaranaike International Airport',
      city: 'Katunayake',
      province: 'Western',
    ),
    _Airport(
      code: 'HRI',
      name: 'Mattala Rajapaksa International Airport',
      city: 'Hambantota',
      province: 'Southern',
    ),
    _Airport(
      code: 'JAF',
      name: 'Jaffna International Airport',
      city: 'Jaffna',
      province: 'Northern',
    ),
    _Airport(
      code: 'TRR',
      name: 'China Bay Airport',
      city: 'Trincomalee',
      province: 'Eastern',
    ),
    _Airport(
      code: 'BTC',
      name: 'Batticaloa Airport',
      city: 'Batticaloa',
      province: 'Eastern',
    ),
  ];

  static const Map<String, List<String>> _airportProvincePriority = {
    'CMB': ['Western', 'Central', 'Southern', 'Sabaragamuwa'],
    'HRI': ['Southern', 'Uva', 'Central', 'Sabaragamuwa'],
    'JAF': ['Northern', 'North Central', 'Eastern', 'North Western'],
    'TRR': ['Eastern', 'North Central', 'Uva', 'Northern'],
    'BTC': ['Eastern', 'Uva', 'Southern', 'Northern'],
  };

  static const List<_PlanPlace> _famousPlaces = [
    _PlanPlace(
      name: 'Galle Face Green',
      province: 'Western',
      image: 'assets/western province/galle-face.jpg',
      avgCost: 25,
      popularity: 94,
      history:
          'A colonial-era ocean promenade that evolved into Colombo\'s social heart.',
      visitTip: 'Best between 5:00 PM and 7:00 PM for breeze and street food.',
    ),
    _PlanPlace(
      name: 'Gangaramaya Temple',
      province: 'Western',
      image: 'assets/western province/Gangaramaya-Temple.jpg',
      avgCost: 30,
      popularity: 90,
      history:
          'One of Colombo\'s most important Buddhist sites blending many architectural styles.',
      visitTip: 'Dress modestly and visit early morning to avoid crowds.',
    ),
    _PlanPlace(
      name: 'Mount Lavinia Beach',
      province: 'Western',
      image: 'assets/western province/mount lavinia beach.jpg',
      avgCost: 20,
      popularity: 86,
      history:
          'A historic beach linked to colonial Ceylon and old coastal trade routes.',
      visitTip: 'Ideal for sunset dinner after a city day.',
    ),
    _PlanPlace(
      name: 'Sigiriya Rock Fortress',
      province: 'Central',
      image: 'assets/central province/sigiriya.jpg',
      avgCost: 75,
      popularity: 99,
      history:
          'Built by King Kasyapa in the 5th century as a palace-fortress complex.',
      visitTip: 'Start climb before 8:00 AM for cooler weather.',
    ),
    _PlanPlace(
      name: 'Temple of the Tooth',
      province: 'Central',
      image: 'assets/central province/temple of tooth.jpg',
      avgCost: 35,
      popularity: 96,
      history: 'The temple safeguards the sacred tooth relic of Lord Buddha.',
      visitTip: 'Join evening puja for the full cultural atmosphere.',
    ),
    _PlanPlace(
      name: 'Nuwara Eliya Tea Country',
      province: 'Central',
      image: 'assets/central province/nuwara eliya tea country.jpg',
      avgCost: 45,
      popularity: 91,
      history:
          'Known as Little England, shaped by hill-country tea plantations.',
      visitTip: 'Pair with factory tour and tasting session.',
    ),
    _PlanPlace(
      name: 'Knuckles Mountain Range',
      province: 'Central',
      image: 'assets/central province/knuckles.jpg',
      avgCost: 55,
      popularity: 84,
      history: 'A UNESCO conservation landscape rich in endemic biodiversity.',
      visitTip: 'Use a local guide for safer trekking routes.',
    ),
    _PlanPlace(
      name: 'Galle Fort',
      province: 'Southern',
      image: 'assets/southern province/galle fort.jpg',
      avgCost: 30,
      popularity: 97,
      history:
          'Originally Portuguese and later fortified by the Dutch in the 17th century.',
      visitTip: 'Walk the ramparts during golden hour.',
    ),
    _PlanPlace(
      name: 'Mirissa Beach',
      province: 'Southern',
      image: 'assets/southern province/mirissa beach.jpg',
      avgCost: 35,
      popularity: 93,
      history:
          'A fishing village transformed into a major whale-watching coast.',
      visitTip: 'Book whale watching from November to April.',
    ),
    _PlanPlace(
      name: 'Yala National Park',
      province: 'Southern',
      image: 'assets/southern province/Yala.avif',
      avgCost: 110,
      popularity: 95,
      history:
          'One of Sri Lanka\'s oldest wildlife reserves with famous leopard sightings.',
      visitTip: 'Choose dawn safari for better wildlife activity.',
    ),
    _PlanPlace(
      name: 'Arugam Bay',
      province: 'Eastern',
      image: 'assets/eastern province/arugam bay.jpg',
      avgCost: 45,
      popularity: 89,
      history:
          'A global surf destination once known mainly to local fishing communities.',
      visitTip: 'Peak surf season usually runs from May to September.',
    ),
    _PlanPlace(
      name: 'Pasikuda Beach',
      province: 'Eastern',
      image: 'assets/eastern province/pasikuda beach.jpg',
      avgCost: 50,
      popularity: 88,
      history: 'Known for its shallow bay and calm turquoise water belt.',
      visitTip: 'Best for relaxed swimming and family stays.',
    ),
    _PlanPlace(
      name: 'Batticaloa Fort',
      province: 'Eastern',
      image: 'assets/eastern province/batticaloa fort.jpg',
      avgCost: 20,
      popularity: 77,
      history: 'A Portuguese and Dutch military site overlooking the lagoon.',
      visitTip: 'Combine with lagoon cruise in late afternoon.',
    ),
    _PlanPlace(
      name: 'Kumana National Park',
      province: 'Eastern',
      image: 'assets/eastern province/kumana national park.jpg',
      avgCost: 95,
      popularity: 82,
      history:
          'Bird-rich wetland extension linked to Yala\'s protected ecosystem.',
      visitTip: 'Excellent for birdwatching from April to July.',
    ),
    _PlanPlace(
      name: 'Ella Rock',
      province: 'Uva',
      image: 'assets/uva province/ella rock.webp',
      avgCost: 28,
      popularity: 92,
      history:
          'A classic hill-country trek route used by tea estate workers and hikers.',
      visitTip: 'Start early to avoid mid-day heat on open sections.',
    ),
    _PlanPlace(
      name: 'Ravana Falls',
      province: 'Uva',
      image: 'assets/uva province/ravana falls.jpg',
      avgCost: 18,
      popularity: 85,
      history: 'Linked in folklore to the Ramayana narrative of King Ravana.',
      visitTip: 'Visit after rains for stronger waterfall flow.',
    ),
    _PlanPlace(
      name: 'Dambana Indigenous Village',
      province: 'Uva',
      image: 'assets/uva province/dambana.jpg',
      avgCost: 35,
      popularity: 74,
      history:
          'Home to Vedda heritage and one of the island\'s oldest communities.',
      visitTip: 'Respect local customs during cultural visits.',
    ),
    _PlanPlace(
      name: 'Ancient City of Polonnaruwa',
      province: 'North Central',
      image: 'assets/north central province/encient city of plonnaruwa.jpg',
      avgCost: 60,
      popularity: 91,
      history:
          'A medieval capital with monumental Buddhist and royal architecture.',
      visitTip: 'Use bicycle rental to cover wider archaeological zones.',
    ),
    _PlanPlace(
      name: 'Minneriya National Park',
      province: 'North Central',
      image: 'assets/north central province/minneriya national park.jpg',
      avgCost: 85,
      popularity: 90,
      history:
          'Famous for The Gathering, one of Asia\'s largest elephant aggregations.',
      visitTip: 'Best sightings often happen in late dry season.',
    ),
    _PlanPlace(
      name: 'Kala Wewa Reservoir',
      province: 'North Central',
      image: 'assets/north central province/kala wewa.jpg',
      avgCost: 18,
      popularity: 70,
      history: 'An ancient irrigation masterpiece from the Anuradhapura era.',
      visitTip: 'Great quick stop on cultural-triangle drives.',
    ),
    _PlanPlace(
      name: 'Puttalam Lagoon',
      province: 'North Western',
      image: 'assets/north western province/puttalam lagoon.jpg',
      avgCost: 25,
      popularity: 72,
      history:
          'A large coastal lagoon ecosystem supporting fishing and bird life.',
      visitTip: 'Try sunrise birdwatching tours.',
    ),
    _PlanPlace(
      name: 'Ridi Viharaya',
      province: 'North Western',
      image: 'assets/north western province/ridi viharaya.jpg',
      avgCost: 22,
      popularity: 73,
      history:
          'Historic temple linked to silver ore discoveries in early kingdoms.',
      visitTip: 'Pair with a short heritage circuit in Kurunegala region.',
    ),
    _PlanPlace(
      name: 'Yapahuwa Rock Fortress',
      province: 'North Western',
      image: 'assets/north western province/yapahuwa.jpg',
      avgCost: 28,
      popularity: 78,
      history: 'A 13th-century fortress briefly used as Sri Lanka\'s capital.',
      visitTip: 'Climb steps in the morning when stone is cooler.',
    ),
    _PlanPlace(
      name: 'Nallur Kovil',
      province: 'Northern',
      image: 'assets/nothern province/nallur kovil.jpg',
      avgCost: 18,
      popularity: 88,
      history: 'A key Hindu temple and cultural landmark of Jaffna.',
      visitTip:
          'Dress respectfully; evenings are lively during festival season.',
    ),
    _PlanPlace(
      name: 'Jaffna Fort',
      province: 'Northern',
      image: 'assets/nothern province/jaffna fort.avif',
      avgCost: 16,
      popularity: 80,
      history: 'A Portuguese-built coastal fort later expanded by the Dutch.',
      visitTip: 'Visit around sunset for softer light and views.',
    ),
    _PlanPlace(
      name: 'Delft Island',
      province: 'Northern',
      image: 'assets/nothern province/delft island.jpg',
      avgCost: 45,
      popularity: 76,
      history:
          'An island with colonial ruins and distinct coral-stone landscapes.',
      visitTip: 'Start ferry transfer early in the day.',
    ),
    _PlanPlace(
      name: 'Keerimalai Hot Springs',
      province: 'Northern',
      image: 'assets/nothern province/keerimalai hot springs.jpg',
      avgCost: 14,
      popularity: 67,
      history: 'A coastal spring site tied to local religious traditions.',
      visitTip: 'Combine with temple and coastal stops nearby.',
    ),
    _PlanPlace(
      name: 'Sinharaja Rainforest',
      province: 'Sabaragamuwa',
      image: 'assets/sabaragamuwa province/sinharaja.jpg',
      avgCost: 65,
      popularity: 89,
      history:
          'A UNESCO-listed tropical rainforest with high endemic biodiversity.',
      visitTip: 'Use licensed eco-guides for trails and wildlife spotting.',
    ),
    _PlanPlace(
      name: 'Bopath Ella',
      province: 'Sabaragamuwa',
      image: 'assets/sabaragamuwa province/bopath ella.jpg',
      avgCost: 20,
      popularity: 75,
      history: 'A fan-shaped waterfall popular with local weekend travelers.',
      visitTip: 'Good quick stop on Ratnapura region drives.',
    ),
    _PlanPlace(
      name: 'Ratnapura Gem Mines',
      province: 'Sabaragamuwa',
      image: 'assets/sabaragamuwa province/Ratnapura gem mines.jpg',
      avgCost: 42,
      popularity: 81,
      history: 'The city of gems has supplied sapphires for centuries.',
      visitTip: 'Visit certified gem museums and workshops.',
    ),
  ];

  static const Map<String, List<String>> _placeInterests = {
    'Galle Face Green': ['Beach', 'Food'],
    'Gangaramaya Temple': ['Culture', 'Heritage'],
    'Mount Lavinia Beach': ['Beach'],
    'Sigiriya Rock Fortress': ['Heritage', 'Culture', 'Adventure'],
    'Temple of the Tooth': ['Culture', 'Heritage'],
    'Nuwara Eliya Tea Country': ['Nature', 'Food', 'Honeymoon'],
    'Knuckles Mountain Range': ['Nature', 'Adventure'],
    'Galle Fort': ['Heritage', 'Culture', 'Honeymoon'],
    'Mirissa Beach': ['Beach', 'Wildlife', 'Honeymoon'],
    'Yala National Park': ['Wildlife', 'Adventure'],
    'Arugam Bay': ['Beach', 'Adventure'],
    'Pasikuda Beach': ['Beach', 'Honeymoon'],
    'Batticaloa Fort': ['Heritage'],
    'Kumana National Park': ['Wildlife', 'Nature'],
    'Ella Rock': ['Nature', 'Adventure'],
    'Ravana Falls': ['Nature'],
    'Dambana Indigenous Village': ['Culture', 'Heritage'],
    'Ancient City of Polonnaruwa': ['Heritage', 'Culture'],
    'Minneriya National Park': ['Wildlife', 'Nature'],
    'Kala Wewa Reservoir': ['Heritage', 'Nature'],
    'Puttalam Lagoon': ['Nature', 'Wildlife'],
    'Ridi Viharaya': ['Culture', 'Heritage'],
    'Yapahuwa Rock Fortress': ['Heritage', 'Adventure'],
    'Nallur Kovil': ['Culture', 'Heritage'],
    'Jaffna Fort': ['Heritage', 'Culture'],
    'Delft Island': ['Heritage', 'Adventure'],
    'Keerimalai Hot Springs': ['Culture', 'Nature'],
    'Sinharaja Rainforest': ['Nature', 'Wildlife', 'Adventure'],
    'Bopath Ella': ['Nature'],
    'Ratnapura Gem Mines': ['Culture', 'Food'],
  };

  static const Map<String, LatLng> _placeCoordinates = {
    'Galle Face Green': LatLng(6.9271, 79.8447),
    'Gangaramaya Temple': LatLng(6.9147, 79.8563),
    'Mount Lavinia Beach': LatLng(6.8396, 79.8653),
    'Sigiriya Rock Fortress': LatLng(7.9570, 80.7603),
    'Temple of the Tooth': LatLng(7.2936, 80.6413),
    'Nuwara Eliya Tea Country': LatLng(6.9497, 80.7891),
    'Knuckles Mountain Range': LatLng(7.3967, 80.7926),
    'Galle Fort': LatLng(6.0269, 80.2168),
    'Mirissa Beach': LatLng(5.9456, 80.4583),
    'Yala National Park': LatLng(6.3725, 81.5185),
    'Arugam Bay': LatLng(6.8402, 81.8360),
    'Pasikuda Beach': LatLng(7.9295, 81.5617),
    'Batticaloa Fort': LatLng(7.7102, 81.6924),
    'Kumana National Park': LatLng(6.5878, 81.7059),
    'Ella Rock': LatLng(6.8667, 81.0460),
    'Ravana Falls': LatLng(6.8406, 81.0597),
    'Dambana Indigenous Village': LatLng(7.1540, 81.1160),
    'Ancient City of Polonnaruwa': LatLng(7.9403, 81.0188),
    'Minneriya National Park': LatLng(8.0362, 80.8918),
    'Kala Wewa Reservoir': LatLng(8.1197, 80.5267),
    'Puttalam Lagoon': LatLng(8.0362, 79.8283),
    'Ridi Viharaya': LatLng(7.5768, 80.2486),
    'Yapahuwa Rock Fortress': LatLng(7.8239, 80.3142),
    'Nallur Kovil': LatLng(9.6753, 80.0213),
    'Jaffna Fort': LatLng(9.6615, 80.0138),
    'Delft Island': LatLng(9.5189, 79.7418),
    'Keerimalai Hot Springs': LatLng(9.8169, 79.9608),
    'Sinharaja Rainforest': LatLng(6.4062, 80.4675),
    'Bopath Ella': LatLng(6.7996, 80.3664),
    'Ratnapura Gem Mines': LatLng(6.6828, 80.3992),
  };

  @override
  void initState() {
    super.initState();
    _bootstrapPlanner();
  }

  Future<void> _bootstrapPlanner() async {
    setState(() => _isGenerating = true);
    await _restoreSavedPlan();
    await _generatePlan();
    if (!mounted) return;
    setState(() => _isGenerating = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFB8C1D1)
        : const Color(0xFF6B7A93);
    final primaryColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF111111);

    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              const AppTopUtilities(),
              _animatedSection(
                delayMs: 0,
                child: _buildHeader(context, textColor, primaryColor, isDark),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _animatedSection(
                        delayMs: 70,
                        child: _buildPlannerInputCard(
                          isDark,
                          textColor,
                          mutedColor,
                          primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animatedSection(
                        delayMs: 130,
                        child: _buildRouteMapCard(
                          isDark,
                          textColor,
                          mutedColor,
                          primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _animatedSection(
                        delayMs: 190,
                        child: _buildTripTitle(
                          textColor,
                          mutedColor,
                          primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _animatedSection(
                        delayMs: 210,
                        child: _buildBudgetBreakdownCard(
                          isDark,
                          textColor,
                          mutedColor,
                          primaryColor,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_isGenerating)
                        ...List.generate(
                          _stayDays,
                          (i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildShimmerCard(isDark, i),
                          ),
                        )
                      else
                        ..._generatedPlan.asMap().entries.map((entry) {
                          final dayIndex = entry.key;
                          final day = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _animatedSection(
                              delayMs: 240 + (dayIndex * 40),
                              child: _buildDaySection(
                                title: 'Day ${dayIndex + 1}: ${day.theme}',
                                stops: day.stops,
                                isDark: isDark,
                                textColor: textColor,
                                mutedColor: mutedColor,
                                primaryColor: primaryColor,
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Color textColor,
    Color primaryColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.9),
                ),
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ceylon Explorer',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                Text(
                  'AI Trip Planner',
                  style: TextStyle(fontSize: 12, color: primaryColor),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openExportMenu(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.9),
                ),
              ),
              child: Icon(Icons.ios_share_outlined, size: 16, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerInputCard(
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color primaryColor,
  ) {
    final currencyService = Provider.of<CurrencyService>(context);
    final locService = Provider.of<LocalizationService>(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : const Color(0xFFDADDE3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plan Inputs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedAirportCode,
            dropdownColor: isDark ? const Color(0xFF1D2432) : Colors.white,
            decoration: InputDecoration(
              labelText: 'Arrival Airport (Sri Lanka)',
              labelStyle: TextStyle(color: mutedColor),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFF1F3F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _airports
                .map(
                  (a) => DropdownMenuItem<String>(
                    value: a.code,
                    child: Text('${a.code} - ${a.name}'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() => _selectedAirportCode = value);
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: locService.currentLanguage,
                  dropdownColor: isDark ? const Color(0xFF1D2432) : Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Language',
                    labelStyle: TextStyle(color: mutedColor),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: LocalizationService.supportedLanguages.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value, style: TextStyle(fontSize: 13, color: textColor)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) locService.setLanguage(value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: currencyService.currentCurrency,
                  dropdownColor: isDark ? const Color(0xFF1D2432) : Colors.white,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    labelStyle: TextStyle(color: mutedColor),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF1F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: CurrencyService.supportedCurrencies.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text('${e.key} ${e.value.split(' ')[0]}', style: TextStyle(fontSize: 13, color: textColor)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) currencyService.setCurrency(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.payments_outlined, color: primaryColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Budget: ${currencyService.currentCurrencySymbol}${currencyService.convertFromUsd(_budgetUsd).toStringAsFixed(0)}',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          Slider(
            value: _budgetUsd,
            min: 250,
            max: 4000,
            divisions: 75,
            activeColor: primaryColor,
            onChanged: (v) => setState(() => _budgetUsd = v),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.nights_stay_outlined, color: primaryColor, size: 18),
              const SizedBox(width: 6),
              Text(
                'Stay: $_stayDays days',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              _stepBtn('-', () {
                if (_stayDays <= 2) return;
                setState(() => _stayDays -= 1);
              }, isDark),
              const SizedBox(width: 8),
              _stepBtn('+', () {
                if (_stayDays >= 14) return;
                setState(() => _stayDays += 1);
              }, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Travel Interests',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  'Culture',
                  'Beach',
                  'Nature',
                  'Adventure',
                  'Wildlife',
                  'Heritage',
                  'Food',
                  'Honeymoon',
                ].map((interest) {
                  final selected = _selectedInterests.contains(interest);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _selectedInterests.remove(interest);
                      } else {
                        _selectedInterests.add(interest);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? primaryColor.withValues(
                                alpha: isDark ? 0.92 : 0.86,
                              )
                            : (isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : const Color(0xFFF0F2F5)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? primaryColor
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : const Color(0xFFD2D6DE)),
                        ),
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF3A5275)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _onGeneratePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                disabledBackgroundColor: primaryColor.withValues(alpha: 0.45),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isGenerating
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isGenerating ? 'Generating...' : 'Generate Smart Itinerary',
                style: TextStyle(
                  color: isDark ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(String label, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.black.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteMapCard(
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color primaryColor,
  ) {
    final airport = _airports.firstWhere((a) => a.code == _selectedAirportCode);
    final mapCenter = _routeStops.isNotEmpty
        ? (_placeCoordinates[_routeStops.first.name] ??
              const LatLng(7.8731, 80.7718))
        : const LatLng(7.8731, 80.7718);
    final markers = _routeStops
        .where((p) => _placeCoordinates.containsKey(p.name))
        .map((p) {
          final point = _placeCoordinates[p.name]!;
          return Marker(
            point: point,
            width: 30,
            height: 30,
            child: Tooltip(
              message: p.name,
              child: Icon(
                Icons.location_on,
                color: isDark ? Colors.white : Colors.black,
                size: 24,
              ),
            ),
          );
        })
        .toList();
    final polyline = _liveRoutePolyline.isNotEmpty
        ? _liveRoutePolyline
        : _routeStops
              .map((p) => _placeCoordinates[p.name])
              .whereType<LatLng>()
              .toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF141C2A) : const Color(0xFFF2F4F6),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFDADDE3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.alt_route, size: 18, color: textColor),
              const SizedBox(width: 8),
              Text(
                'Trip Map',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                'from ${airport.code}',
                style: TextStyle(
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 170,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 7.1,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.smartcity.app',
                  ),
                  if (polyline.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: polyline,
                          strokeWidth: 3,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  MarkerLayer(markers: markers),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_routeStops.length} stops • ${_liveRoutePolyline.isNotEmpty ? "live route" : "fallback route"}',
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ),
              if (_isLoadingMap)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: mutedColor,
                    ),
                  ),
                ),
              TextButton.icon(
                onPressed: _routeStops.isEmpty
                    ? null
                    : () => _openLiveMapSheet(isDark),
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text('Open Map'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripTitle(
    Color textColor,
    Color mutedColor,
    Color primaryColor,
  ) {
    final budgetTag = _budgetTierLabel(_budgetUsd);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your $_stayDays-Day AI Journey',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.auto_graph, size: 17, color: primaryColor),
            const SizedBox(width: 4),
            Text(
              budgetTag,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Mode: $_plannerMode. Recommended by airport, budget, stay length, and live transport data. Estimated total: USD ${_estimatedTotal.toStringAsFixed(0)}.',
          style: TextStyle(color: mutedColor, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildDaySection({
    required String title,
    required List<_PlanStop> stops,
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required Color primaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF6DAEA4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isDark
                    ? const Color(0xFF56627A)
                    : const Color(0xFFCFD8E7),
                width: 1.2,
              ),
            ),
          ),
          child: Column(
            children: stops
                .map(
                  (stop) => _buildJourneyCard(
                    stop,
                    isDark,
                    textColor,
                    mutedColor,
                    primaryColor,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyCard(
    _PlanStop stop,
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color primaryColor,
  ) {
    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFEFF2F6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.75),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              stop.place.image,
              width: 74,
              height: 74,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 74,
                height: 74,
                color: const Color(0xFFDDE3EC),
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, size: 12, color: mutedColor),
                    const SizedBox(width: 4),
                    Text(
                      stop.time,
                      style: TextStyle(
                        fontSize: 11,
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.directions, size: 12, color: mutedColor),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        stop.travelMode,
                        style: TextStyle(
                          fontSize: 11,
                          color: mutedColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (stop.durationLabel != null ||
                    stop.scheduleHint != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (stop.durationLabel != null) ...[
                        Icon(
                          Icons.timelapse_outlined,
                          size: 11,
                          color: mutedColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          stop.durationLabel!,
                          style: TextStyle(fontSize: 10.5, color: mutedColor),
                        ),
                      ],
                      if (stop.scheduleHint != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stop.scheduleHint!,
                            style: TextStyle(fontSize: 10.5, color: mutedColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  stop.place.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  stop.place.visitTip,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: mutedColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 11,
                      color: mutedColor,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        '${stop.place.province} province',
                        style: TextStyle(fontSize: 11, color: mutedColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'USD ${_priceFor(stop.place).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
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
    return GestureDetector(
      onTap: () => _openPlaceDetail(stop.place, isDark, textColor, mutedColor),
      child: card,
    );
  }

  Future<void> _generatePlan() async {
    final prefs =
        _airportProvincePriority[_selectedAirportCode] ?? const <String>[];
    final dailyBudget = _budgetUsd / _stayDays;

    List<_PlanPlace> candidates = _famousPlaces.where((p) {
      if (_budgetUsd < 700) return p.avgCost <= 55;
      if (_budgetUsd < 1500) return p.avgCost <= 90;
      return true;
    }).toList();

    candidates.sort((a, b) {
      final ai = prefs.indexOf(a.province);
      final bi = prefs.indexOf(b.province);
      final aRank = ai == -1 ? 999 : ai;
      final bRank = bi == -1 ? 999 : bi;
      if (aRank != bRank) return aRank.compareTo(bRank);
      if (_selectedInterests.isNotEmpty) {
        final aInterests = _placeInterests[a.name] ?? const <String>[];
        final bInterests = _placeInterests[b.name] ?? const <String>[];
        final aMatches = aInterests.where(_selectedInterests.contains).length;
        final bMatches = bInterests.where(_selectedInterests.contains).length;
        if (aMatches != bMatches) return bMatches.compareTo(aMatches);
      }
      return b.popularity.compareTo(a.popularity);
    });

    final currencyService = Provider.of<CurrencyService>(context, listen: false);
    final locService = Provider.of<LocalizationService>(context, listen: false);
    
    final aiOrderedNames = await _aiPlanner.rankPlaces(
      airportCode: _selectedAirportCode,
      budgetUsd: _budgetUsd,
      stayDays: _stayDays,
      interests: _selectedInterests.toList(),
      candidates: candidates,
      currencyCode: currencyService.currentCurrency,
      languageCode: locService.currentLanguage,
    );
    if (aiOrderedNames.isNotEmpty) {
      _plannerMode = 'AI + ML Engine';
      final rank = <String, int>{
        for (int i = 0; i < aiOrderedNames.length; i++) aiOrderedNames[i]: i,
      };
      candidates.sort((a, b) {
        final ar = rank[a.name] ?? 999;
        final br = rank[b.name] ?? 999;
        if (ar != br) return ar.compareTo(br);
        return b.popularity.compareTo(a.popularity);
      });
    } else {
      _plannerMode = 'ML fallback model';
    }

    final neededStops = max(_stayDays * 2, 4);
    final chosen = <_PlanPlace>[];
    for (final place in candidates) {
      if (chosen.length >= neededStops) break;
      final duplicateName = chosen.any((p) => p.name == place.name);
      if (!duplicateName) chosen.add(place);
    }

    if (chosen.isEmpty) {
      chosen.addAll(_famousPlaces.take(min(neededStops, _famousPlaces.length)));
    }

    var days = <_DayPlan>[];
    _PlanPlace? previous;
    for (int day = 0; day < _stayDays; day++) {
      final morning = chosen[(day * 2) % chosen.length];
      final evening = chosen[(day * 2 + 1) % chosen.length];

      final morningMode = previous == null
          ? _arrivalMode(_selectedAirportCode, morning.province)
          : _travelMode(previous.province, morning.province, dailyBudget);
      final eveningMode = _travelMode(
        morning.province,
        evening.province,
        dailyBudget,
      );

      days.add(
        _DayPlan(
          theme: _dailyTheme(morning, evening),
          stops: [
            _PlanStop(
              time: '08:30 AM',
              place: morning,
              travelMode: morningMode,
            ),
            _PlanStop(
              time: '03:30 PM',
              place: evening,
              travelMode: eveningMode,
            ),
          ],
        ),
      );

      previous = evening;
    }

    await _syncLivePrices(chosen);
    days = await _injectLiveTransport(days);

    final uniqueRoute = <_PlanPlace>[];
    for (final place in chosen) {
      if (!uniqueRoute.any((p) => p.name == place.name)) {
        uniqueRoute.add(place);
      }
      if (uniqueRoute.length >= 7) break;
    }

    final baseCost = days
        .expand((d) => d.stops)
        .fold<double>(0, (sum, stop) => sum + _priceFor(stop.place));
    final transferCost = (_stayDays - 1) * (dailyBudget > 190 ? 28 : 16);

    _generatedPlan = days;
    _routeStops = uniqueRoute;
    _estimatedTotal = baseCost + transferCost;

    await _refreshLiveRoute();
    await _backend.saveLatestPlan(_serializePlan());
  }

  double _priceFor(_PlanPlace place) {
    return _livePriceByPlace[place.name] ?? place.avgCost;
  }

  Future<void> _syncLivePrices(List<_PlanPlace> chosen) async {
    final prices = await _pricingService.fetchLivePrices(chosen);
    _livePriceByPlace
      ..clear()
      ..addAll(prices);
  }

  Future<List<_DayPlan>> _injectLiveTransport(List<_DayPlan> days) async {
    final updated = <_DayPlan>[];
    _PlanPlace? previous;
    for (final day in days) {
      final newStops = <_PlanStop>[];
      for (final stop in day.stops) {
        LatLng? from;
        if (previous != null) {
          from = _placeCoordinates[previous.name];
        } else {
          from = _airportCoordinate(_selectedAirportCode);
        }
        final to = _placeCoordinates[stop.place.name];
        String? duration;
        String? schedule;
        if (from != null && to != null) {
          final info = await _transportService.getLiveTransport(from, to);
          if (info != null) {
            duration =
                '${info.durationMinutes} min • ${info.distanceKm.toStringAsFixed(1)} km';
            schedule = info.scheduleHint;
          }
        }
        newStops.add(
          stop.copyWith(durationLabel: duration, scheduleHint: schedule),
        );
        previous = stop.place;
      }
      updated.add(_DayPlan(theme: day.theme, stops: newStops));
    }
    return updated;
  }

  Future<void> _refreshLiveRoute() async {
    final ordered = _routeStops
        .map((p) => _placeCoordinates[p.name])
        .whereType<LatLng>()
        .toList();
    if (ordered.length < 2) {
      _liveRoutePolyline = ordered;
      return;
    }
    final route = await _transportService.getRoutePolyline(ordered);
    _liveRoutePolyline = route.isNotEmpty ? route : ordered;
  }

  Future<void> _restoreSavedPlan() async {
    final saved = await _backend.loadLatestPlan();
    if (saved == null) return;
    _selectedAirportCode = saved['airport'] as String? ?? _selectedAirportCode;
    _budgetUsd = (saved['budget'] as num?)?.toDouble() ?? _budgetUsd;
    _stayDays = (saved['stayDays'] as num?)?.toInt() ?? _stayDays;
    final savedInterests =
        (saved['interests'] as List?)?.cast<String>() ?? const <String>[];
    _selectedInterests
      ..clear()
      ..addAll(savedInterests);
  }

  Map<String, dynamic> _serializePlan() {
    return {
      'airport': _selectedAirportCode,
      'budget': _budgetUsd,
      'stayDays': _stayDays,
      'interests': _selectedInterests.toList(),
      'estimatedTotal': _estimatedTotal,
      'plannerMode': _plannerMode,
      'updatedAt': DateTime.now().toIso8601String(),
      'days': _generatedPlan
          .map(
            (d) => {
              'theme': d.theme,
              'stops': d.stops
                  .map(
                    (s) => {
                      'time': s.time,
                      'place': s.place.name,
                      'province': s.place.province,
                      'travelMode': s.travelMode,
                      'durationLabel': s.durationLabel,
                      'scheduleHint': s.scheduleHint,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };
  }

  LatLng? _airportCoordinate(String code) {
    switch (code) {
      case 'CMB':
        return const LatLng(7.1808, 79.8841);
      case 'HRI':
        return const LatLng(6.2845, 81.1241);
      case 'JAF':
        return const LatLng(9.7924, 80.0701);
      case 'TRR':
        return const LatLng(8.5385, 81.1819);
      case 'BTC':
        return const LatLng(7.7060, 81.6788);
      default:
        return null;
    }
  }

  String _arrivalMode(String airportCode, String destinationProvince) {
    final airport = _airports.firstWhere((a) => a.code == airportCode);
    if (airport.province == destinationProvince) {
      return 'Airport transfer + local taxi';
    }
    if (_budgetUsd / _stayDays > 200) {
      return 'Private cab transfer';
    }
    return 'Train or intercity bus';
  }

  String _travelMode(
    String fromProvince,
    String toProvince,
    double dailyBudget,
  ) {
    if (fromProvince == toProvince) return 'Tuk tuk + short cab rides';
    if (dailyBudget > 220) return 'Private cab to next destination';
    if ((fromProvince == 'Western' && toProvince == 'Central') ||
        (fromProvince == 'Central' && toProvince == 'Uva')) {
      return 'Scenic train route';
    }
    return 'Intercity bus + taxi connection';
  }

  String _dailyTheme(_PlanPlace morning, _PlanPlace evening) {
    final cultural = ['Central', 'North Central', 'Northern'];
    final coastal = ['Western', 'Southern', 'Eastern'];

    if (cultural.contains(morning.province) ||
        cultural.contains(evening.province)) {
      return 'Heritage and Culture Trail';
    }
    if (coastal.contains(morning.province) &&
        coastal.contains(evening.province)) {
      return 'Coastline and Sunset Journey';
    }
    return 'Nature and Scenic Discovery';
  }

  String _budgetTierLabel(double budget) {
    if (budget < 700) return 'Budget Smart';
    if (budget < 1500) return 'Balanced Comfort';
    if (budget < 2600) return 'Premium Explorer';
    return 'Luxury Escape';
  }

  // -- Priority 1: Place detail tap modal ------------------------------------
  void _openPlaceDetail(
    _PlanPlace place,
    bool isDark,
    Color textColor,
    Color mutedColor,
  ) {
    final primaryColor = isDark
        ? const Color(0xFF73D8FF)
        : const Color(0xFF0D8AA8);
    final starCount = ((place.popularity / 20).round()).clamp(1, 5);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx2, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141C2A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: Image.asset(
                    place.image,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      color: isDark
                          ? const Color(0xFF1E2A3B)
                          : const Color(0xFFDDE4F0),
                      child: Icon(Icons.terrain, size: 60, color: mutedColor),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${place.province} Province',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        place.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(
                            starCount,
                            (_) => const Icon(
                              Icons.star,
                              size: 15,
                              color: Color(0xFFFFB347),
                            ),
                          ),
                          ...List.generate(
                            5 - starCount,
                            (_) => Icon(
                              Icons.star_border,
                              size: 15,
                              color: mutedColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${place.popularity}/100 popularity',
                            style: TextStyle(fontSize: 12, color: mutedColor),
                          ),
                          const Spacer(),
                          Text(
                            'USD ${place.avgCost.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2BC0E4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Historical Background',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.history,
                        style: TextStyle(
                          fontSize: 14,
                          color: mutedColor,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                place.visitTip,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: textColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6DAEA4).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Color(0xFF6DAEA4),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Recommended based on your airport, budget & '
                                '${_selectedInterests.isEmpty ? "top popularity" : _selectedInterests.join(", ")} preferences.',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6DAEA4),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -- Priority 2: Budget breakdown card -------------------------------------
  Widget _buildBudgetBreakdownCard(
    bool isDark,
    Color textColor,
    Color mutedColor,
    Color primaryColor,
  ) {
    final currencyService = Provider.of<CurrencyService>(context);
    if (_generatedPlan.isEmpty) return const SizedBox.shrink();
    final activityCost = _generatedPlan
        .expand((d) => d.stops)
        .fold<double>(0, (sum, stop) => sum + _priceFor(stop.place));
    final dailyAccomm = _budgetUsd < 700
        ? 30.0
        : _budgetUsd < 1500
        ? 65.0
        : _budgetUsd < 2600
        ? 115.0
        : 200.0;
    final dailyFood = _budgetUsd < 700
        ? 18.0
        : _budgetUsd < 1500
        ? 35.0
        : _budgetUsd < 2600
        ? 58.0
        : 90.0;
    final transportCost =
        (_stayDays - 1) * (_budgetUsd / _stayDays > 190 ? 28.0 : 16.0);
    final accommCost = dailyAccomm * _stayDays;
    final foodCost = dailyFood * _stayDays;
    final total = activityCost + accommCost + transportCost + foodCost;
    final overBudget = total > _budgetUsd;
    final cats = <({String label, double cost, Color color, IconData icon})>[
      (
        label: 'Activities',
        cost: activityCost,
        color: const Color(0xFF2BC0E4),
        icon: Icons.confirmation_num_outlined,
      ),
      (
        label: 'Accommodation',
        cost: accommCost,
        color: const Color(0xFF8B93FF),
        icon: Icons.hotel_outlined,
      ),
      (
        label: 'Transport',
        cost: transportCost,
        color: const Color(0xFF52BFAD),
        icon: Icons.directions_car_outlined,
      ),
      (
        label: 'Food & Dining',
        cost: foodCost,
        color: const Color(0xFFFFB347),
        icon: Icons.restaurant_menu_outlined,
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : const Color(0xFFD6E3F8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Budget Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: overBudget
                      ? Colors.redAccent.withValues(alpha: 0.15)
                      : const Color(0xFF2BC0E4).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  overBudget ? 'Over budget' : 'Within budget',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: overBudget
                        ? Colors.redAccent
                        : const Color(0xFF2BC0E4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...cats.map((cat) {
            final fraction = total > 0
                ? (cat.cost / total).clamp(0.0, 1.0)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(cat.icon, size: 14, color: cat.color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          cat.label,
                          style: TextStyle(fontSize: 12, color: mutedColor),
                        ),
                      ),
                      Text(
                        '${currencyService.currentCurrencySymbol}${currencyService.convertFromUsd(cat.cost).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 5,
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : const Color(0xFFE8EDF5),
                      valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Estimated Total',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                '${currencyService.currentCurrencySymbol}${currencyService.convertFromUsd(total).toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: overBudget ? Colors.redAccent : primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your budget',
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
              ),
              Text(
                '${currencyService.currentCurrencySymbol}${currencyService.convertFromUsd(_budgetUsd).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -- Priority 3: Loading shimmer --------------------------------------------
  Widget _buildShimmerCard(bool isDark, int index) {
    final shimmerColor = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : const Color(0xFFDDE5F4);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.85),
      duration: Duration(milliseconds: 850 + index * 120),
      curve: Curves.easeInOut,
      builder: (_, v, __) => Opacity(
        opacity: v,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : const Color(0xFFEFF2F6),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 11,
                      width: 75,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 17,
                      width: 160,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 11,
                      width: 110,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(6),
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

  // -- Priority 4: Generate with loading animation ---------------------------
  void _onGeneratePressed() {
    setState(() {
      _isGenerating = true;
      _isLoadingMap = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      await _generatePlan();
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _isLoadingMap = false;
      });
    });
  }

  // -- Priority 5: Export options (copy / native share / PDF) ---------------
  void _openExportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141C2A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.copy_all_outlined),
                    title: const Text('Copy Itinerary Text'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _copyTripText();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('Share Natively'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _shareTripNatively();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf_outlined),
                    title: const Text('Export PDF'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _exportAsPdf();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _tripPlanText() {
    if (_generatedPlan.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln('Sri Lanka Ceylon Explorer Trip Plan - $_stayDays Days');
    buf.writeln(
      'Airport: $_selectedAirportCode  |  Budget: USD ${_budgetUsd.toStringAsFixed(0)}',
    );
    buf.writeln('Planner mode: $_plannerMode');
    if (_selectedInterests.isNotEmpty) {
      buf.writeln('Interests: ${_selectedInterests.join(', ')}');
    }
    buf.writeln();
    for (int i = 0; i < _generatedPlan.length; i++) {
      final day = _generatedPlan[i];
      buf.writeln('Day ${i + 1}: ${day.theme}');
      for (final stop in day.stops) {
        buf.writeln(
          '  ${stop.time} — ${stop.place.name} (${stop.place.province})',
        );
        buf.writeln(
          '  via ${stop.travelMode}${stop.durationLabel != null ? ' • ${stop.durationLabel}' : ''}',
        );
      }
      buf.writeln();
    }
    buf.writeln('Estimated Total: USD ${_estimatedTotal.toStringAsFixed(0)}');
    buf.writeln('Generated by Ceylon Explorer App');
    return buf.toString();
  }

  void _copyTripText() {
    final text = _tripPlanText();
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('? Trip plan copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  Future<void> _shareTripNatively() async {
    final text = _tripPlanText();
    if (text.isEmpty) return;
    await Share.share(text, subject: 'My Sri Lanka Itinerary');
  }

  Future<void> _exportAsPdf() async {
    final doc = pw.Document();
    final text = _tripPlanText();
    if (text.isEmpty) return;
    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Smart City - Trip Plan')),
          pw.Paragraph(text: text),
        ],
      ),
    );
    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: 'smartcity-itinerary.pdf');
  }

  void _openLiveMapSheet(bool isDark) {
    final markers = _routeStops
        .where((p) => _placeCoordinates.containsKey(p.name))
        .map((p) {
          final point = _placeCoordinates[p.name]!;
          return Marker(
            point: point,
            width: 36,
            height: 36,
            child: Tooltip(
              message: p.name,
              child: const Icon(
                Icons.location_pin,
                color: Color(0xFF2BC0E4),
                size: 30,
              ),
            ),
          );
        })
        .toList();

    final polyline = _liveRoutePolyline.isNotEmpty
        ? _liveRoutePolyline
        : _routeStops
              .map((p) => _placeCoordinates[p.name])
              .whereType<LatLng>()
              .toList();

    final center = polyline.isNotEmpty
        ? polyline.first
        : const LatLng(7.8731, 80.7718);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.88,
        maxChildSize: 0.96,
        minChildSize: 0.5,
        builder: (ctx, _) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141C2A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Live Route Map',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(initialCenter: center, initialZoom: 7.0),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smartcity.app',
                    ),
                    if (polyline.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: polyline,
                            strokeWidth: 4,
                            color: const Color(0xFF2BC0E4),
                          ),
                        ],
                      ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _animatedSection({required int delayMs, required Widget child}) {
    final duration = Duration(milliseconds: 450 + delayMs);

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

class _Airport {
  final String code;
  final String name;
  final String city;
  final String province;

  const _Airport({
    required this.code,
    required this.name,
    required this.city,
    required this.province,
  });
}

class _PlanPlace {
  final String name;
  final String province;
  final String image;
  final double avgCost;
  final int popularity;
  final String history;
  final String visitTip;

  const _PlanPlace({
    required this.name,
    required this.province,
    required this.image,
    required this.avgCost,
    required this.popularity,
    required this.history,
    required this.visitTip,
  });
}

class _PlanStop {
  final String time;
  final _PlanPlace place;
  final String travelMode;
  final String? durationLabel;
  final String? scheduleHint;

  const _PlanStop({
    required this.time,
    required this.place,
    required this.travelMode,
    this.durationLabel,
    this.scheduleHint,
  });

  _PlanStop copyWith({
    String? time,
    _PlanPlace? place,
    String? travelMode,
    String? durationLabel,
    String? scheduleHint,
  }) {
    return _PlanStop(
      time: time ?? this.time,
      place: place ?? this.place,
      travelMode: travelMode ?? this.travelMode,
      durationLabel: durationLabel ?? this.durationLabel,
      scheduleHint: scheduleHint ?? this.scheduleHint,
    );
  }
}

class _DayPlan {
  final String theme;
  final List<_PlanStop> stops;

  const _DayPlan({required this.theme, required this.stops});
}

class _GeminiItineraryAI {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<List<String>> rankPlaces({
    required String airportCode,
    required double budgetUsd,
    required int stayDays,
    required List<String> interests,
    required List<_PlanPlace> candidates,
    String currencyCode = 'USD',
    String languageCode = 'en',
  }) async {
    if (_apiKey.isEmpty) {
      return _LocalMlRecommender.rank(candidates, interests);
    }
    try {
      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: _apiKey);
      final prompt =
          '''
Return only a JSON array of place names in ranked order for a Sri Lanka itinerary.
Target user language code: $languageCode
Target user currency: $currencyCode
Airport: $airportCode
Budget USD: ${budgetUsd.toStringAsFixed(0)}
Days: $stayDays
Interests: ${interests.join(', ')}
Candidates: ${candidates.map((e) => '${e.name} (${e.province}, popularity ${e.popularity}, avg ${e.avgCost})').join('; ')}
      ''';
      final result = await model.generateContent([Content.text(prompt)]);
      final text = result.text ?? '';
      final firstBracket = text.indexOf('[');
      final lastBracket = text.lastIndexOf(']');
      if (firstBracket == -1 ||
          lastBracket == -1 ||
          lastBracket <= firstBracket) {
        return _LocalMlRecommender.rank(candidates, interests);
      }
      final decoded = jsonDecode(text.substring(firstBracket, lastBracket + 1));
      if (decoded is List) {
        return decoded.whereType<String>().toList();
      }
    } catch (_) {
      return _LocalMlRecommender.rank(candidates, interests);
    }
    return _LocalMlRecommender.rank(candidates, interests);
  }
}

class _LocalMlRecommender {
  static List<String> rank(
    List<_PlanPlace> candidates,
    List<String> interests,
  ) {
    final interestSet = interests.toSet();
    final scored = candidates.map((p) {
      final tags =
          _ItineraryScreenState._placeInterests[p.name] ?? const <String>[];
      final interestScore = tags.where(interestSet.contains).length * 20;
      final novelty = (100 - p.popularity) * 0.08;
      final score = p.popularity + interestScore + novelty;
      return (name: p.name, score: score);
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.map((e) => e.name).toList();
  }
}

class _LiveTransportInfo {
  final int durationMinutes;
  final double distanceKm;
  final String scheduleHint;

  const _LiveTransportInfo({
    required this.durationMinutes,
    required this.distanceKm,
    required this.scheduleHint,
  });
}

class _LiveTransportService {
  Future<_LiveTransportInfo?> getLiveTransport(LatLng from, LatLng to) async {
    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${from.longitude},${from.latitude};${to.longitude},${to.latitude}?overview=false',
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (json['routes'] as List?) ?? const [];
      if (routes.isEmpty) return null;
      final first = routes.first as Map<String, dynamic>;
      final minutes = ((first['duration'] as num?)?.toDouble() ?? 0) ~/ 60;
      final km = ((first['distance'] as num?)?.toDouble() ?? 0) / 1000;
      final hh = DateTime.now().hour;
      final hint = hh < 12
          ? 'Next departure in ~20 min'
          : 'Next departure in ~35 min';
      return _LiveTransportInfo(
        durationMinutes: minutes,
        distanceKm: km,
        scheduleHint: hint,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<LatLng>> getRoutePolyline(List<LatLng> points) async {
    if (points.length < 2) return points;
    try {
      final coords = points
          .map((p) => '${p.longitude},${p.latitude}')
          .join(';');
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson',
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) return points;
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final routes = (json['routes'] as List?) ?? const [];
      if (routes.isEmpty) return points;
      final geometry =
          (routes.first as Map<String, dynamic>)['geometry']
              as Map<String, dynamic>?;
      final coordinates = (geometry?['coordinates'] as List?) ?? const [];
      return coordinates
          .whereType<List>()
          .where((c) => c.length >= 2)
          .map(
            (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          )
          .toList();
    } catch (_) {
      return points;
    }
  }
}

class _LivePricingService {
  static const String _apiBase = String.fromEnvironment(
    'ITINERARY_API_BASE_URL',
  );

  Future<Map<String, double>> fetchLivePrices(List<_PlanPlace> places) async {
    if (_apiBase.isNotEmpty) {
      try {
        final uri = Uri.parse('$_apiBase/pricing');
        final res = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'places': places.map((e) => e.name).toList()}),
        );
        if (res.statusCode == 200) {
          final json = jsonDecode(res.body) as Map<String, dynamic>;
          final data =
              (json['prices'] as Map?)?.cast<String, dynamic>() ??
              const <String, dynamic>{};
          return data.map((k, v) => MapEntry(k, (v as num).toDouble()));
        }
      } catch (_) {}
    }

    final dayFactor = (DateTime.now().weekday % 3) * 0.04;
    return {
      for (final p in places)
        p.name: p.avgCost * (1 + dayFactor + ((p.popularity % 5) * 0.01)),
    };
  }
}

class _ItineraryBackendService {
  static const String _key = 'smartcity_latest_plan';
  static const String _apiBase = String.fromEnvironment(
    'ITINERARY_API_BASE_URL',
  );

  Future<void> saveLatestPlan(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(payload));
    if (_apiBase.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$_apiBase/plans'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );
      } catch (_) {}
    }
  }

  Future<Map<String, dynamic>?> loadLatestPlan() async {
    if (_apiBase.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse('$_apiBase/plans/latest'));
        if (res.statusCode == 200) {
          final cloud = jsonDecode(res.body) as Map<String, dynamic>;
          return cloud;
        }
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
