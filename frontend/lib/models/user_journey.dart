class Journey {
  final String name;

  Journey({required this.name});

  factory Journey.fromString(String journeyName) {
    return Journey(name: journeyName);
  }
}