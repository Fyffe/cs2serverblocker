class Relay {
  final String ipAddress;
  final int portStart;
  final int portEnd;

  const Relay({
    required this.ipAddress,
    required this.portStart,
    required this.portEnd
  });

  static Relay fromJson(json) => Relay(
    ipAddress: json["ipv4"],
    portStart: json["port_range"][0],
    portEnd: json["port_range"][1],
  );
}