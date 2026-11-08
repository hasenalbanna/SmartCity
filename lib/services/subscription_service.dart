import 'package:flutter/foundation.dart';

enum SubscriptionPlan {
  free,
  falconPro,
  businessEnterprise,
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

  static const List<MonetizationAddOn> marketplaceAddOns = [
    MonetizationAddOn(
      id: 'addon_insurance_pdf',
      title: 'Certified AI Insurance Claim Dossier',
      subtitle:
          'Official GPS-stamped AI Vision forensic PDF for vehicle pothole damage or flood claims.',
      priceLabel: 'LKR 450',
      priceLkr: 450,
      badge: 'HIGH DEMAND',
      category: 'Reports & Legal',
    ),
    MonetizationAddOn(
      id: 'addon_fast_track_sla',
      title: 'Priority 2-Hour Contractor Dispatch Boost',
      subtitle:
          'Escalate non-emergency commercial/driveway issues to certified private partner crews.',
      priceLabel: 'LKR 600',
      priceLkr: 600,
      badge: 'FAST TRACK',
      category: 'Reports & Legal',
    ),
    MonetizationAddOn(
      id: 'addon_bus_vip_pass',
      title: 'Smart Bus 7-Day Unlimited VIP Pass',
      subtitle:
          'Unlimited rides on Routes 22 & 48 + guaranteed A/C seat reservation & SMS delay alerts.',
      priceLabel: 'LKR 650 / wk',
      priceLkr: 650,
      badge: 'COMMUTER FAVORITE',
      category: 'Transit',
    ),
    MonetizationAddOn(
      id: 'addon_sponsored_pin',
      title: 'Sponsored Business Pin on Live City Map',
      subtitle:
          'Promote your shop, pharmacy, or restaurant on the Smart Bus & Citizen Map for 7 days.',
      priceLabel: 'LKR 1,500 / wk',
      priceLkr: 1500,
      badge: 'B2B MARKETING',
      category: 'Business',
    ),
    MonetizationAddOn(
      id: 'addon_property_audit',
      title: 'Land & Property Flood-Risk Valuation Certificate',
      subtitle:
          '10-year coastal erosion, drainage, and elevation audit for buyers, landlords, and banks.',
      priceLabel: 'LKR 1,200',
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
    notifyListeners();
  }

  void purchaseAddOn(MonetizationAddOn addOn) {
    _purchasedAddOnIds.add(addOn.id);
    if (addOn.id == 'addon_insurance_pdf') {
      _insuranceDossiersRemaining += 1;
    } else if (addOn.id == 'addon_sponsored_pin') {
      _sponsoredPinsCount += 1;
    }
    notifyListeners();
  }
}

