import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sharing_items/src/custom/app_bar.dart';
import 'package:geocoding/geocoding.dart';

/// 홈페이지
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.5665, 126.9780), //서울 시청
    zoom: 14.0,
  );

  String? _currentAddress;

  TextEditingController itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setLocaleIdentifier('ko_KR');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "홈",
        locationText: _currentAddress,
        showSearch: true,
        onLocateMe: (LatLng target) async {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(target, 16),
          );

          setState(() {
            _markers.removeWhere((m) => m.markerId == const MarkerId('current_location'));
            _markers.add(
              Marker(
                markerId: const MarkerId('current_location'),
                position: target,
                infoWindow: const InfoWindow(title: '현재 위치'),
              ),
            );
          });

          final address = await _toKoreanAddress(target);
          setState(() => _currentAddress = address);
        },
      ),
      body: Stack(
        children: [
          SizedBox.expand(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.5,
            builder: (context, scrollController){
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const Text(
                      '추천 아이템',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('자동차'),)
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(8),
                                child: Icon(Icons.car_rental),
                              ),
                              const SizedBox(width: 12),
                              
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          ),
        ]
      ),
    );
  }

  Future<String> _toKoreanAddress(LatLng target) async {
    try{
      final placemarks = await placemarkFromCoordinates(
        target.latitude, target.longitude,
      );
      if(placemarks.isEmpty){
        return '${target.latitude.toStringAsFixed(5)}, ${target.longitude.toStringAsFixed(5)}';
      }

      final p = placemarks.first;
      final parts = <String>[];

      void add(String? s){
        if(s != null && s.trim().isNotEmpty) parts.add(s.trim());
      }
      
      add(p.administrativeArea);
      add(p.subAdministrativeArea);
      add(p.locality);
      add(p.subLocality);
      
      final road = _joinWithSpace([p.thoroughfare, p.subThoroughfare]);
      if(road.isNotEmpty){
        parts.add(road);
      }
      final result = parts.join(' ');
      return result.isNotEmpty ? result : '${target.latitude.toStringAsFixed(5)}, ${target.longitude.toStringAsFixed(5)}';

    } catch (_) {
      return '${target.latitude.toStringAsFixed(5)}, ${target.longitude.toStringAsFixed(5)}';
    }
  }

  String _joinWithSpace(List<String?> items) {
    return items.where((e) => e != null && e!.trim().isNotEmpty).join(' ');
  }
}
