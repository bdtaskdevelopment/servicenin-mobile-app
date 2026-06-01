class ClientItem {
  final int id;
  final String name;
  final String email;
  final String phone;

  ClientItem(
      {required this.id,
      required this.name,
      required this.email,
      required this.phone});

  factory ClientItem.fromMap(Map<String, dynamic> m) => ClientItem(
        id: m['id'] as int,
        name: m['name'] as String? ?? '',
        email: m['email'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
      );
}

class ClientsResponse {
  final List<ClientItem> data;
  ClientsResponse({required this.data});
  factory ClientsResponse.fromMap(Map<String, dynamic> m) => ClientsResponse(
        data: (m['data'] as List)
            .map((e) => ClientItem.fromMap(e as Map<String, dynamic>))
            .toList(),
      );
}

ClientsResponse clientsResponseFromMap(Map<String, dynamic> m) =>
    ClientsResponse.fromMap(m);
