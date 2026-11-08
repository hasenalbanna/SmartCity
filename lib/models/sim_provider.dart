class SIMProvider {
  final String id;
  final String name;
  final String logo;
  final List<SIMPackage> packages;
  final Map<String, double>
  coverageByRegion; // Region name -> coverage percentage

  SIMProvider({
    required this.id,
    required this.name,
    required this.logo,
    required this.packages,
    required this.coverageByRegion,
  });
}

class SIMPackage {
  final String id;
  final String name;
  final double dataGB;
  final int validityDays;
  final double priceUSD;
  final bool hasUnlimitedCalls;
  final bool hasUnlimitedSMS;
  final String description;

  SIMPackage({
    required this.id,
    required this.name,
    required this.dataGB,
    required this.validityDays,
    required this.priceUSD,
    required this.hasUnlimitedCalls,
    required this.hasUnlimitedSMS,
    required this.description,
  });
}

class SIMRecommendation {
  final SIMProvider provider;
  final SIMPackage package;
  final double matchScore; // 0-100
  final String reason;

  SIMRecommendation({
    required this.provider,
    required this.package,
    required this.matchScore,
    required this.reason,
  });
}
