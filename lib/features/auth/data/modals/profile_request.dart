class ProfileRequest {
  final String firstName;
  final String lastName;
  final String description;
  final String email;
  final String mobileNo;
  final String pincode;
  final String city;
  final String? filePath; // Path to the local image file

  ProfileRequest({
    required this.firstName,
    required this.lastName,
    required this.description,
    required this.email,
    required this.mobileNo,
    required this.pincode,
    required this.city,
    this.filePath,
  });
}
