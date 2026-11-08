import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService extends ChangeNotifier {
  String _currentCurrency = 'USD';
  
  static const Map<String, String> supportedCurrencies = {
    'USD': '\$ (US Dollar)',
    'LKR': 'Rs (Sri Lankan Rupee)',
    'EUR': '€ (Euro)',
    'GBP': '£ (British Pound)',
    'AUD': 'A\$ (Australian Dollar)',
    'INR': '₹ (Indian Rupee)',
  };

  static const Map<String, double> exchangeRates = {
    'USD': 1.0,
    'LKR': 300.0,
    'EUR': 0.92,
    'GBP': 0.78,
    'AUD': 1.52,
    'INR': 83.0,
  };

  CurrencyService() {
    _loadCurrency();
  }

  String get currentCurrency => _currentCurrency;
  String get currentCurrencyName => supportedCurrencies[_currentCurrency] ?? 'USD';
  String get currentCurrencySymbol => supportedCurrencies[_currentCurrency]?.split(' ')[0] ?? '\$';
  double get currentExchangeRate => exchangeRates[_currentCurrency] ?? 1.0;

  double convertFromUsd(double amountUsd) {
    return amountUsd * currentExchangeRate;
  }
  
  double convertToUsd(double amountLocal) {
    return amountLocal / currentExchangeRate;
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _currentCurrency = prefs.getString('currency') ?? 'USD';
    notifyListeners();
  }

  Future<void> setCurrency(String currencyCode) async {
    if (supportedCurrencies.containsKey(currencyCode)) {
      _currentCurrency = currencyCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currency', currencyCode);
      notifyListeners();
    }
  }
}
