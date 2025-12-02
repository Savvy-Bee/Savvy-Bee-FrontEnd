// class MonoInputData {
//   final String name;
//   final String email;
//   final String? monoCustomerId;
//   final String identity;

//   MonoInputData({
//     required this.name,
//     required this.email,
//     this.monoCustomerId,
//     required this.identity,
//   });

//   factory MonoInputData.fromJson(Map<String, dynamic> json) {
//     return MonoInputData(
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       monoCustomerId: json['monoCustomerId'],
//       identity: json['identity'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'email': email,
//       'monoCustomerId': monoCustomerId,
//       'identity': identity,
//     };
//   }
// }