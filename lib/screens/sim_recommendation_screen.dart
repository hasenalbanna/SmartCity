import 'package:flutter/material.dart';
import '../services/sim_recommendation_service.dart';
import '../models/sim_provider.dart';

class SIMRecommendationScreen extends StatefulWidget {
  const SIMRecommendationScreen({super.key});

  @override
  State<SIMRecommendationScreen> createState() =>
      _SIMRecommendationScreenState();
}

class _SIMRecommendationScreenState extends State<SIMRecommendationScreen> {
  int _stayDays = 7;
  double _expectedDataGB = 10;
  double _budgetUSD = 20;
  String _usageType = 'moderate';
  final List<String> _selectedRegions = ['Western', 'Southern'];
  List<SIMRecommendation>? _recommendations;
  bool _isLoading = false;

  void _getRecommendations() {
    setState(() => _isLoading = true);

    // Simulate AI processing
    Future.delayed(const Duration(milliseconds: 800), () {
      final service = SIMRecommendationService();
      final recommendations = service.getRecommendations(
        stayDays: _stayDays,
        expectedDataGB: _expectedDataGB,
        budgetUSD: _budgetUSD,
        visitingRegions: _selectedRegions,
        usageType: _usageType,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: const Text('SIM Recommendation'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF87CEEB), Color(0xFFFFD54F)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sim_card,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI SIM Advisor',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Get personalized SIM recommendations based on your travel plans',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Input Section
            _buildSection(
              'Your Travel Details',
              Column(
                children: [
                  // Stay Duration
                  _buildSliderInput(
                    'Length of Stay',
                    '$_stayDays days',
                    _stayDays.toDouble(),
                    1,
                    30,
                    (value) => setState(() => _stayDays = value.round()),
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),

                  // Expected Data
                  _buildSliderInput(
                    'Expected Data Usage',
                    '${_expectedDataGB.toStringAsFixed(0)} GB',
                    _expectedDataGB,
                    1,
                    50,
                    (value) => setState(() => _expectedDataGB = value),
                    Icons.data_usage,
                  ),
                  const SizedBox(height: 16),

                  // Budget
                  _buildSliderInput(
                    'Budget',
                    '\$${_budgetUSD.toStringAsFixed(0)}',
                    _budgetUSD,
                    3,
                    50,
                    (value) => setState(() => _budgetUSD = value),
                    Icons.attach_money,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Usage Type
            _buildSection(
              'Usage Type',
              Row(
                children: [
                  _buildUsageChip('light', 'Light', Icons.wifi_1_bar),
                  const SizedBox(width: 8),
                  _buildUsageChip('moderate', 'Moderate', Icons.wifi_2_bar),
                  const SizedBox(width: 8),
                  _buildUsageChip('heavy', 'Heavy', Icons.wifi),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Regions
            _buildSection(
              'Visiting Regions',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: SIMRecommendationService.regions.map((region) {
                  final isSelected = _selectedRegions.contains(region);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedRegions.remove(region);
                        } else {
                          _selectedRegions.add(region);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF87CEEB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF87CEEB)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        region,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Get Recommendations Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedRegions.isNotEmpty
                    ? _getRecommendations
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CEEB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome),
                          SizedBox(width: 8),
                          Text(
                            'Get AI Recommendations',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Recommendations
            if (_recommendations != null) ...[
              Text(
                'Top Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              ..._recommendations!.asMap().entries.map((entry) {
                final index = entry.key;
                final rec = entry.value;
                return _buildRecommendationCard(rec, index == 0);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSliderInput(
    String label,
    String value,
    double current,
    double min,
    double max,
    ValueChanged<double> onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF87CEEB),
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: const Color(0xFF87CEEB),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildUsageChip(String value, String label, IconData icon) {
    final isSelected = _usageType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _usageType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF87CEEB) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF87CEEB)
                  : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(SIMRecommendation rec, bool isTop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTop
            ? Border.all(color: const Color(0xFF87CEEB), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rec.provider.logo, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          rec.provider.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (isTop) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BEST',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      rec.package.name,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${rec.package.priceUSD.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF87CEEB),
                    ),
                  ),
                  Text(
                    '${rec.matchScore.toStringAsFixed(0)}% match',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPackageDetail(Icons.data_usage, '${rec.package.dataGB} GB'),
              _buildPackageDetail(
                Icons.calendar_today,
                '${rec.package.validityDays} days',
              ),
              if (rec.package.hasUnlimitedCalls)
                _buildPackageDetail(Icons.phone, 'Unlimited'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Color(0xFF87CEEB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec.reason,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Selected ${rec.provider.name} - ${rec.package.name}',
                    ),
                    backgroundColor: const Color(0xFF87CEEB),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isTop
                    ? const Color(0xFF87CEEB)
                    : Colors.grey[200],
                foregroundColor: isTop ? Colors.white : Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(isTop ? 'Select This Plan' : 'Select'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
