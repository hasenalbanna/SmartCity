import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionPlan {
  free,
  falconPro,
  businessEnterprise,
}

enum PremiumFeature {
  falconVoiceGuardian,
  unlimitedAiItineraries,
  certifiedInsuranceDossier,
  vipBusRadar,
  microFloodRadar,
  sponsoredBusinessPins,
}

class FeatureBenchmarkInfo {
  final PremiumFeature feature;
  final String featureName;
  final String rivalAppName;
  final String rivalPrice;
  final String rivalPerks;
  final String ourAdvantage;
  final String unlockAction;

  const FeatureBenchmarkInfo({
    required this.feature,
    required this.featureName,
    required this.rivalAppName,
    required this.rivalPrice,
    required this.rivalPerks,
    required this.ourAdvantage,
    required this.unlockAction,
  });
}

class MonetizationAddOn {
  final String id;
  final String title;
  final String subtitle;
  final String priceLabel;
  final int priceLkr;
  final String badge;
  final String category;

  const MonetizationAddOn({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceLabel,
    required this.priceLkr,
    required this.badge,
    required this.category,
  });
}

class SubscriptionService extends ChangeNotifier {
  static const String _keyPlan = 'subscription_plan_tier';
  static const String _keyAddons = 'subscription_purchased_addons';
  static const String _keyDossiers = 'subscription_dossiers_count';
  static const String _keyPins = 'subscription_pins_count';

  SubscriptionPlan _currentPlan = SubscriptionPlan.free;
  final Set<String> _purchasedAddOnIds = {};
  int _sponsoredPinsCount = 0;
  int _insuranceDossiersRemaining = 0;

  SubscriptionPlan get currentPlan => _currentPlan;
  Set<String> get purchasedAddOnIds => Set.unmodifiable(_purchasedAddOnIds);
  int get sponsoredPinsCount => _sponsoredPinsCount;
  int get insuranceDossiersRemaining => _insuranceDossiersRemaining;

  bool get isProOrHigher =>
      _currentPlan == SubscriptionPlan.falconPro ||
      _currentPlan == SubscriptionPlan.businessEnterprise;

  bool get isEnterprise =>
      _currentPlan == SubscriptionPlan.businessEnterprise;

  String get currentPlanName {
    switch (_currentPlan) {
      case SubscriptionPlan.free:
        return 'Citizen Basic (Free)';
      case SubscriptionPlan.falconPro:
        return 'Falcon Shield+ Pro';
      case SubscriptionPlan.businessEnterprise:
        return 'Smart City Business Enterprise';
    }
  }

  SubscriptionService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final planIndex = prefs.getInt(_keyPlan) ?? 0;
      if (planIndex >= 0 && planIndex < SubscriptionPlan.values.length) {
        _currentPlan = SubscriptionPlan.values[planIndex];
      }
      final addonsList = prefs.getStringList(_keyAddons) ?? [];
      _purchasedAddOnIds.addAll(addonsList);
      _insuranceDossiersRemaining = prefs.getInt(_keyDossiers) ?? (isProOrHigher ? 3 : 0);
      _sponsoredPinsCount = prefs.getInt(_keyPins) ?? (isEnterprise ? 5 : 0);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyPlan, _currentPlan.index);
      await prefs.setStringList(_keyAddons, _purchasedAddOnIds.toList());
      await prefs.setInt(_keyDossiers, _insuranceDossiersRemaining);
      await prefs.setInt(_keyPins, _sponsoredPinsCount);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Feature Access & Gating Checks
  // ---------------------------------------------------------------------------

  bool canAccessFeature(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.falconVoiceGuardian:
        return isProOrHigher;
      case PremiumFeature.unlimitedAiItineraries:
        return isProOrHigher;
      case PremiumFeature.certifiedInsuranceDossier:
        return isProOrHigher ||
            _insuranceDossiersRemaining > 0 ||
            _purchasedAddOnIds.contains('addon_insurance_pdf');
      case PremiumFeature.vipBusRadar:
        return isProOrHigher ||
            _purchasedAddOnIds.contains('addon_bus_vip_pass');
      case PremiumFeature.microFloodRadar:
        return isProOrHigher;
      case PremiumFeature.sponsoredBusinessPins:
        return isEnterprise ||
            _sponsoredPinsCount > 0 ||
            _purchasedAddOnIds.contains('addon_sponsored_pin');
    }
  }

  bool get hasUnlimitedAiItineraries => canAccessFeature(PremiumFeature.unlimitedAiItineraries);
  bool get hasCertifiedPdfExport => canAccessFeature(PremiumFeature.certifiedInsuranceDossier);
  bool get has247FalconVoiceGuardian => canAccessFeature(PremiumFeature.falconVoiceGuardian);
  bool get hasVipBusRadar => canAccessFeature(PremiumFeature.vipBusRadar);
  bool get hasMicroFloodRadar => canAccessFeature(PremiumFeature.microFloodRadar);
  bool get hasSponsoredPins => canAccessFeature(PremiumFeature.sponsoredBusinessPins);

  // ---------------------------------------------------------------------------
  // Competitive Benchmark Research Analysis
  // ---------------------------------------------------------------------------

  static const Map<PremiumFeature, FeatureBenchmarkInfo> benchmarkResearch = {
    PremiumFeature.falconVoiceGuardian: FeatureBenchmarkInfo(
      feature: PremiumFeature.falconVoiceGuardian,
      featureName: '24/7 Falcon AI Voice Guardian & Emergency Dispatch',
      rivalAppName: 'Citizen Plus',
      rivalPrice: '\$19.99 / mo (~LKR 6,200/mo)',
      rivalPerks: 'Live safety agent monitoring, SOS audio escalation, 911 auto-connect & family tracking.',
      ourAdvantage: 'Falcon AI voice recognition, automated municipal incident correlation, and hands-free "Hey Falcon" wake word included in Falcon Shield+ Pro for just \$4.99/mo (LKR 990/mo).',
      unlockAction: 'Unlock Falcon Voice Guardian',
    ),
    PremiumFeature.unlimitedAiItineraries: FeatureBenchmarkInfo(
      feature: PremiumFeature.unlimitedAiItineraries,
      featureName: 'Unlimited AI Multi-Day Itineraries & Offline Route Guides',
      rivalAppName: 'AllTrails+ & Citymapper Club',
      rivalPrice: '\$35.99 / yr & \$29.99 / yr',
      rivalPerks: 'Offline maps, custom multi-stop trip plans, wrong-turn trail alerts, and printable high-res PDF guides.',
      ourAdvantage: 'Unlimited generative AI itinerary optimization, multimodal transit schedules, live weather radar, and instant PDF travel dossier export with zero per-trip charges.',
      unlockAction: 'Unlock Unlimited AI Itineraries',
    ),
    PremiumFeature.certifiedInsuranceDossier: FeatureBenchmarkInfo(
      feature: PremiumFeature.certifiedInsuranceDossier,
      featureName: 'Certified AI Vision Insurance Damage Claim PDF Dossier',
      rivalAppName: 'InsurTech & Forensic Legal Audits',
      rivalPrice: '\$25.00 - \$50.00 / audit (~LKR 8,000 - 16,000)',
      rivalPerks: 'Verified timestamp, GPS elevation certificate, damage estimate, and cryptographic tamper check for insurer claims.',
      ourAdvantage: 'Instant municipal council-grade PDF with AI crack/flood severity score, official GPS metadata, and council work order number for just LKR 450 (or 3 free/mo with Pro).',
      unlockAction: 'Unlock Certified Insurance PDF',
    ),
    PremiumFeature.vipBusRadar: FeatureBenchmarkInfo(
      feature: PremiumFeature.vipBusRadar,
      featureName: 'Smart Bus VIP Commuter Pass & Live Occupancy Radar',
      rivalAppName: 'Citymapper Club',
      rivalPrice: '\$2.99 - \$3.99 / mo (~LKR 950 - 1,250/mo)',
      rivalPerks: 'Real-time carriage crowding, delay predictor, turn-by-turn bus voice navigation, and multimodal transfers.',
      ourAdvantage: 'Live A/C occupancy telemetry, guaranteed seat reservation radar, and instant alternate express shuttles.',
      unlockAction: 'Unlock Smart Bus VIP Radar',
    ),
    PremiumFeature.microFloodRadar: FeatureBenchmarkInfo(
      feature: PremiumFeature.microFloodRadar,
      featureName: 'DisasterShield 45-Minute Micro-Neighborhood Flood Warning',
      rivalAppName: 'AccuWeather Premium+ & Weather Underground',
      rivalPrice: '\$24.99 / yr (~LKR 7,800/yr)',
      rivalPerks: 'MinuteCast micro-precipitation, storm surge elevation maps, and high-frequency radar push alerts.',
      ourAdvantage: 'Direct municipal drainage telemetry, street-level storm surge alerts, and coastal erosion sensors linked directly to ward dispatch.',
      unlockAction: 'Unlock Micro Flood Radar',
    ),
    PremiumFeature.sponsoredBusinessPins: FeatureBenchmarkInfo(
      feature: PremiumFeature.sponsoredBusinessPins,
      featureName: 'Sponsored Business Pins & Promoted Map Placements',
      rivalAppName: 'Yelp & Google Local Ads',
      rivalPrice: '\$150 - \$300 / mo (~LKR 46,000 - 92,000/mo)',
      rivalPerks: 'Highlighted map pin, top-of-search placement, lead conversion analytics, and verified business checkmark.',
      ourAdvantage: 'High-visibility illuminated map pin, direct in-app transit radar exposure to thousands of daily commuters, and verified merchant pass for just LKR 1,500/wk or included with Enterprise.',
      unlockAction: 'Unlock Business Sponsored Pins',
    ),
  };

  static const List<MonetizationAddOn> marketplaceAddOns = [
    MonetizationAddOn(
      id: 'addon_insurance_pdf',
      title: 'Certified AI Insurance Claim Dossier',
      subtitle:
          'Official GPS-stamped AI Vision forensic PDF for vehicle pothole damage or flood claims.',
      priceLabel: 'LKR 450 (\$1.49)',
      priceLkr: 450,
      badge: 'HIGH DEMAND',
      category: 'Reports & Legal',
    ),
    MonetizationAddOn(
      id: 'addon_fast_track_sla',
      title: 'Priority 2-Hour Contractor Dispatch Boost',
      subtitle:
          'Escalate non-emergency commercial/driveway issues to certified private partner crews.',
      priceLabel: 'LKR 600 (\$1.99)',
      priceLkr: 600,
      badge: 'FAST TRACK',
      category: 'Reports & Legal',
    ),
    MonetizationAddOn(
      id: 'addon_bus_vip_pass',
      title: 'Smart Bus 7-Day Unlimited VIP Pass',
      subtitle:
          'Unlimited rides on Routes 22 & 48 + guaranteed A/C seat reservation & SMS delay alerts.',
      priceLabel: 'LKR 650 / wk (\$2.10)',
      priceLkr: 650,
      badge: 'COMMUTER FAVORITE',
      category: 'Transit',
    ),
    MonetizationAddOn(
      id: 'addon_sponsored_pin',
      title: 'Sponsored Business Pin on Live City Map',
      subtitle:
          'Promote your shop, pharmacy, or restaurant on the Smart Bus & Citizen Map for 7 days.',
      priceLabel: 'LKR 1,500 / wk (\$4.90)',
      priceLkr: 1500,
      badge: 'B2B MARKETING',
      category: 'Business',
    ),
    MonetizationAddOn(
      id: 'addon_property_audit',
      title: 'Land & Property Flood-Risk Valuation Certificate',
      subtitle:
          '10-year coastal erosion, drainage, and elevation audit for buyers, landlords, and banks.',
      priceLabel: 'LKR 1,200 (\$3.90)',
      priceLkr: 1200,
      badge: 'REAL ESTATE',
      category: 'Alerts & Property',
    ),
  ];

  void upgradePlan(SubscriptionPlan plan) {
    _currentPlan = plan;
    if (plan == SubscriptionPlan.falconPro) {
      _insuranceDossiersRemaining += 3;
    } else if (plan == SubscriptionPlan.businessEnterprise) {
      _insuranceDossiersRemaining += 15;
      _sponsoredPinsCount += 5;
    }
    _saveToStorage();
    notifyListeners();
  }

  void purchaseAddOn(MonetizationAddOn addOn) {
    _purchasedAddOnIds.add(addOn.id);
    if (addOn.id == 'addon_insurance_pdf') {
      _insuranceDossiersRemaining += 1;
    } else if (addOn.id == 'addon_sponsored_pin') {
      _sponsoredPinsCount += 1;
    }
    _saveToStorage();
    notifyListeners();
  }

  bool consumeInsuranceDossier() {
    if (_insuranceDossiersRemaining > 0) {
      _insuranceDossiersRemaining -= 1;
      _saveToStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  bool consumeSponsoredPin() {
    if (_sponsoredPinsCount > 0) {
      _sponsoredPinsCount -= 1;
      _saveToStorage();
      notifyListeners();
      return true;
    }
    return false;
  }
}
