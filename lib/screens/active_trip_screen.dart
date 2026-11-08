import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/lita_ai_service.dart';
import '../services/trip_history_service.dart';
import 'trip_summary_screen.dart';

class ActiveTripScreen extends StatefulWidget {
  final String destinationName;
  final String vehicle;
  final List<LatLng> routePoints;

  const ActiveTripScreen({
    super.key,
    required this.destinationName,
    required this.vehicle,
    required this.routePoints,
  });

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  LatLng? _currentPosition;
  double _currentSpeedKmH = 0.0;
  double _maxSpeedKmH = 0.0;
  double _distanceTraveledKm = 0.0;
  DateTime _startTime = DateTime.now();

  StreamSubscription<Position>? _positionStreamSubscription;
  final LitaAiService _litaService = LitaAiService();
  final MapController _mapController = MapController();

  // Minimap position
  Offset _minimapOffset = const Offset(20, 100);

  // Chat variables
  final List<Map<String, String>> _messages = [];
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    if (widget.routePoints.isNotEmpty) {
      _currentPosition = widget.routePoints.first;
    }
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      if (!mounted) return;
      
      final newPos = LatLng(position.latitude, position.longitude);
      
      // Calculate distance (very rough accumulation)
      if (_currentPosition != null) {
        final distance = const Distance().as(LengthUnit.Kilometer, _currentPosition!, newPos);
        _distanceTraveledKm += distance;
      }

      setState(() {
        _currentPosition = newPos;
        // Convert speed from m/s to km/h
        _currentSpeedKmH = position.speed * 3.6;
        if (_currentSpeedKmH > _maxSpeedKmH) {
          _maxSpeedKmH = _currentSpeedKmH;
        }
      });
      
      _mapController.move(newPos, _mapController.camera.zoom);
    });
  }

  void _finishAndSaveTrip() {
    final TextEditingController nameController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Save Trip Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Trip Name (e.g. Weekend Getaway)'),
                ),
                const SizedBox(height: 16),
                const Text('Rate your trip:'),
                Slider(
                  value: rating,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: rating.toStringAsFixed(1),
                  onChanged: (val) => setState(() => rating = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final tripHistory = context.read<TripHistoryService>();
                  final duration = DateTime.now().difference(_startTime);
                  
                  final tripItem = TripHistoryItem(
                    id: const Uuid().v4(),
                    tripName: nameController.text.isEmpty ? 'My Trip to ${widget.destinationName}' : nameController.text,
                    rating: rating,
                    fromLocation: 'Current Location',
                    toLocation: widget.destinationName,
                    vehicle: widget.vehicle,
                    distanceKm: _distanceTraveledKm > 0 ? _distanceTraveledKm : 12.5,
                    timeTaken: duration,
                    date: DateTime.now(),
                    mapPreviewUrl: 'assets/southern province/Galle Fort.jpg',
                    maxSpeedKmH: _maxSpeedKmH,
                  );
                  
                  tripHistory.addTrip(tripItem);
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TripSummaryScreen(trip: tripItem), 
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _chatController.dispose();
    super.dispose();
  }

  IconData _getVehicleIcon() {
    switch (widget.vehicle) {
      case 'Train': return Icons.directions_transit;
      case 'Flight': return Icons.flight;
      case 'Bus': return Icons.directions_bus;
      case 'Lorry': return Icons.local_shipping;
      case 'Car':
      default: return Icons.directions_car;
    }
  }

  Future<void> _sendMessageToLita() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"sender": "User", "text": text});
      _chatController.clear();
    });

    final reply = await _litaService.sendMessage(
      text, 
      speedKmH: _currentSpeedKmH, 
      destination: widget.destinationName
    );

    setState(() {
      _messages.add({"sender": "Lita", "text": reply});
    });
  }

  bool _hasGreeted = false;
  bool _isLitaModalOpen = false;

  void _openLitaAssistant() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _isLitaModalOpen = true;
    
    // Helper function to handle the continuous loop
    void startConversationLoop(StateSetter? setModalState) {
      if (!mounted || !_isLitaModalOpen) return;
      
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (!mounted || !_isLitaModalOpen) return;
        if (!_litaService.isSpeaking.value && !_litaService.isListening) {
          await _litaService.startListening(
            (words) {
              if (words.isNotEmpty && mounted) {
                setState(() => _chatController.text = words);
                if (setModalState != null) setModalState(() {});
              }
            },
            onFinalResult: (finalWords) {
              if (finalWords.isNotEmpty && mounted && _isLitaModalOpen) {
                setState(() => _chatController.text = finalWords);
                
                _sendMessageToLita().then((_) {
                  // Recurse to keep the conversation going!
                  startConversationLoop(setModalState);
                });
              }
            },
          );
          if (setModalState != null && mounted) setModalState(() {});
        }
      });
    }

    if (!_hasGreeted) {
      _hasGreeted = true;
      final greeting = "Hi, I am Lita. Don't worry, I am right here with you! Tell me your name.";
      setState(() {
        _messages.add({"sender": "Lita", "text": greeting});
      });
      _litaService.speak(greeting).then((_) {
        startConversationLoop(null);
      });
    } else {
      startConversationLoop(null);
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Fully transparent
      barrierColor: Colors.black.withValues(alpha: 0.2), // Slight dimming of map
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.5, // Shorter height
            color: Colors.transparent, // No background!
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_chatController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black87 : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    ),
                    child: Text(
                      '"${_chatController.text}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontStyle: FontStyle.italic, color: isDark ? Colors.white : Colors.black),
                    ),
                  ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _litaService.isSpeaking,
                          builder: (context, isSpeaking, _) {
                            return GestureDetector(
                              onTap: () async {
                                if (_litaService.isListening) {
                                  await _litaService.stopListening();
                                  setModalState(() {});
                                  
                                  await Future.delayed(const Duration(milliseconds: 500));
                                  
                                  if (_chatController.text.isNotEmpty) {
                                    _sendMessageToLita().then((_) {
                                      startConversationLoop(setModalState);
                                    });
                                  }
                                } else {
                                  _chatController.clear();
                                  startConversationLoop(setModalState);
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_litaService.isListening)
                                    _PulseWave(color: Colors.green),
                                  if (isSpeaking && !_litaService.isListening)
                                    _PulseWave(color: Colors.pinkAccent),
                                    
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? Colors.black87 : Colors.white,
                                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                                    ),
                                    child: Icon(
                                      Icons.face_3, // Girl icon
                                      size: 72, 
                                      color: _litaService.isListening 
                                          ? Colors.green 
                                          : (isSpeaking ? Colors.pinkAccent : (isDark ? Colors.white : Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 24),
                        ValueListenableBuilder<bool>(
                          valueListenable: _litaService.isSpeaking,
                          builder: (context, isSpeaking, _) {
                            String status;
                            if (isSpeaking) {
                              status = '✨ LITA is speaking...';
                            } else if (_litaService.isListening) {
                              status = '🎙️ I am listening...';
                            } else if (_chatController.text.isNotEmpty) {
                              status = '"${_chatController.text}"';
                            } else {
                              status = '😊 I am right here with you!';
                            }
                            return Text(
                              status,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16, 
                                color: isSpeaking ? Colors.pinkAccent : Colors.grey,
                                fontStyle: _chatController.text.isNotEmpty && !isSpeaking && !_litaService.isListening 
                                    ? FontStyle.italic 
                                    : FontStyle.normal,
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                    left: 24,
                    right: 24,
                    top: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Or type here...',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: isDark ? Colors.black87 : Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          onSubmitted: (_) {
                            if (_chatController.text.isEmpty) return;
                            _sendMessageToLita().then((_) {
                              startConversationLoop(setModalState);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        child: IconButton(
                          icon: Icon(Icons.send, color: isDark ? Colors.black : Colors.white),
                          onPressed: () {
                            if (_chatController.text.isEmpty) return;
                            _sendMessageToLita().then((_) {
                              startConversationLoop(setModalState);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    ).whenComplete(() {
      _isLitaModalOpen = false;
      _litaService.stopListening();
      _litaService.stopSpeaking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Expanded Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? (widget.routePoints.isNotEmpty ? widget.routePoints.first : const LatLng(7.8731, 80.7718)),
              initialZoom: 16.0, 
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smartcity.app',
              ),
              if (widget.routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.routePoints,
                      color: const Color(0xFF2BC0E4).withValues(alpha: 0.5),
                      strokeWidth: 8.0,
                    ),
                  ],
                ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                        ),
                        child: Icon(_getVehicleIcon(), color: isDark ? Colors.black : Colors.white, size: 28),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Speedometer
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _currentSpeedKmH > 80 ? Colors.red : (isDark ? Colors.white24 : Colors.grey.shade300), width: 4),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentSpeedKmH.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text('km/h', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
          
          // Draggable Minimap Overlay
          if (widget.routePoints.isNotEmpty)
            Positioned(
              left: _minimapOffset.dx,
              top: _minimapOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _minimapOffset = Offset(
                      _minimapOffset.dx + details.delta.dx,
                      _minimapOffset.dy + details.delta.dy,
                    );
                  });
                },
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: IgnorePointer( // Ignore pointer so map inside doesn't steal drag gesture
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: widget.routePoints.first,
                          initialZoom: 6.0,
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                          PolylineLayer(
                            polylines: [
                              Polyline(points: widget.routePoints, color: Colors.blue, strokeWidth: 3.0),
                            ],
                          ),
                          if (_currentPosition != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentPosition!,
                                  width: 10,
                                  height: 10,
                                  child: Container(decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Top Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                    ),
                    child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                    ),
                    child: Text(
                      'Driving to ${widget.destinationName}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // End & Save Trip Button
                GestureDetector(
                  onTap: _finishAndSaveTrip,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          
          // LITA AI Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _openLitaAssistant,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: isDark ? Colors.black : Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Travel with LITA',
                      style: TextStyle(color: isDark ? Colors.black : Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseWave extends StatefulWidget {
  final Color color;
  const _PulseWave({required this.color});

  @override
  State<_PulseWave> createState() => _PulseWaveState();
}

class _PulseWaveState extends State<_PulseWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 72 + (_controller.value * 100),
          height: 72 + (_controller.value * 100),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 1 - _controller.value),
              width: 4,
            ),
          ),
        );
      },
    );
  }
}
