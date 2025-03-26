// lib/models/route_model.dart
class KakaoRouteResponse {
  final String transId;
  final List<KakaoRoute > routes;

  KakaoRouteResponse({
    required this.transId, 
    required this.routes,
  });

  factory KakaoRouteResponse.fromJson(Map<String, dynamic> json) {
    return KakaoRouteResponse(
      transId: json['trans_id'],
      routes: (json['routes'] as List)
          .map((route) => KakaoRoute .fromJson(route))
          .toList(),
    );
  }
}

class KakaoRoute  {
  final int resultCode;
  final String resultMsg;
  final RouteSummary summary;
  final List<Section> sections;

  KakaoRoute ({
    required this.resultCode,
    required this.resultMsg,
    required this.summary,
    required this.sections,
  });

  factory KakaoRoute .fromJson(Map<String, dynamic> json) {
    return KakaoRoute (
      resultCode: json['result_code'],
      resultMsg: json['result_msg'],
      summary: RouteSummary.fromJson(json['summary']),
      sections: json['sections'] != null
          ? (json['sections'] as List)
              .map((section) => Section.fromJson(section))
              .toList()
          : [],
    );
  }
}

class RouteSummary {
  final Location origin;
  final Location destination;
  final List<Location> waypoints;
  final String priority;
  final Bound? bound;
  final Fare fare;
  final int distance;
  final int duration;

  RouteSummary({
    required this.origin,
    required this.destination,
    required this.waypoints,
    required this.priority,
    this.bound,
    required this.fare,
    required this.distance,
    required this.duration,
  });

  factory RouteSummary.fromJson(Map<String, dynamic> json) {
    return RouteSummary(
      origin: Location.fromJson(json['origin']),
      destination: Location.fromJson(json['destination']),
      waypoints: json['waypoints'] != null
          ? (json['waypoints'] as List)
              .map((waypoint) => Location.fromJson(waypoint))
              .toList()
          : [],
      priority: json['priority'],
      bound: json['bound'] != null ? Bound.fromJson(json['bound']) : null,
      fare: Fare.fromJson(json['fare']),
      distance: json['distance'],
      duration: json['duration'],
    );
  }
}

class Location {
  final String name;
  final double x;
  final double y;

  Location({
    required this.name,
    required this.x,
    required this.y,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      x: json['x'],
      y: json['y'],
    );
  }
}

class Bound {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  Bound({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  factory Bound.fromJson(Map<String, dynamic> json) {
    return Bound(
      minX: json['min_x'],
      minY: json['min_y'],
      maxX: json['max_x'],
      maxY: json['max_y'],
    );
  }
}

class Fare {
  final int taxi;
  final int toll;

  Fare({
    required this.taxi,
    required this.toll,
  });

  factory Fare.fromJson(Map<String, dynamic> json) {
    return Fare(
      taxi: json['taxi'],
      toll: json['toll'],
    );
  }
}

class Section {
  final int distance;
  final int duration;
  final Bound? bound;
  final List<Road>? roads;
  final List<Guide>? guides;

  Section({
    required this.distance,
    required this.duration,
    this.bound,
    this.roads,
    this.guides,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      distance: json['distance'],
      duration: json['duration'],
      bound: json['bound'] != null ? Bound.fromJson(json['bound']) : null,
      roads: json['roads'] != null
          ? (json['roads'] as List).map((road) => Road.fromJson(road)).toList()
          : null,
      guides: json['guides'] != null
          ? (json['guides'] as List)
              .map((guide) => Guide.fromJson(guide))
              .toList()
          : null,
    );
  }
}

class Road {
  final String name;
  final int distance;
  final int duration;
  final double trafficSpeed;
  final int trafficState;
  final List<double> vertexes;

  Road({
    required this.name,
    required this.distance,
    required this.duration,
    required this.trafficSpeed,
    required this.trafficState,
    required this.vertexes,
  });

  factory Road.fromJson(Map<String, dynamic> json) {
    return Road(
      name: json['name'] ?? '',
      distance: json['distance'],
      duration: json['duration'],
      trafficSpeed: json['traffic_speed'],
      trafficState: json['traffic_state'],
      vertexes: (json['vertexes'] as List).map((v) => v as double).toList(),
    );
  }
  
  // 경로 정보를 카카오맵 drawRoute 메서드에 사용할 수 있는 형식으로 변환
  List<Map<String, double>> getCoordinatesForDrawRoute() {
    List<Map<String, double>> coordinates = [];
    
    for (int i = 0; i < vertexes.length; i += 2) {
      if (i + 1 < vertexes.length) {
        coordinates.add({
          'longitude': vertexes[i],
          'latitude': vertexes[i + 1],
        });
      }
    }
    
    return coordinates;
  }
}

class Guide {
  final String name;
  final double x;
  final double y;
  final int distance;
  final int duration;
  final int type;
  final String guidance;
  final int roadIndex;

  Guide({
    required this.name,
    required this.x,
    required this.y,
    required this.distance,
    required this.duration,
    required this.type,
    required this.guidance,
    required this.roadIndex,
  });

  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      name: json['name'] ?? '',
      x: json['x'],
      y: json['y'],
      distance: json['distance'],
      duration: json['duration'],
      type: json['type'],
      guidance: json['guidance'],
      roadIndex: json['road_index'],
    );
  }
}