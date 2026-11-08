import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_spacing.dart';
import '../widgets/ui/ui.dart';
import 'hotel_booking_screen.dart';

class HotelListScreen extends StatelessWidget {
  final String cityName;
  final LatLng? cityLocation;

  const HotelListScreen({
    super.key,
    required this.cityName,
    this.cityLocation,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('$cityName Hotels')),
      body: SingleChildScrollView(
        padding: AppSpace.pagePadding,
        child: HotelBookingView(
          nearPlace: cityName,
          initialLocationCenter: cityLocation,
        ),
      ),
    );
  }
}
