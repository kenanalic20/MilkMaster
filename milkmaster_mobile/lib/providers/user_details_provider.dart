import 'package:milkmaster_mobile/models/user_details_model.dart';
import 'package:milkmaster_mobile/providers/base_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailsProvider extends BaseProvider<UserDetails> {
  UserDetailsProvider()
      : super(
          'UserDetail',
          fromJson: (json) => UserDetails.fromJson(json),
        );

  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      final headers = await getHeaders();
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/File'),
      );
      
      request.headers.addAll(headers);
      request.fields['Subfolder'] = 'Images/Profile';
      request.files.add(
        await http.MultipartFile.fromPath(
          'File',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final imageUrl = data['fileUrl'];
        
        // Get existing user details to preserve firstName and lastName
        final existingDetails = await getById(userId);
        final updateData = {'imageUrl': imageUrl};
        
        // Preserve existing firstName and lastName if they exist
        if (existingDetails != null) {
          if (existingDetails.firstName != null) {
            updateData['firstName'] = existingDetails.firstName;
          }
          if (existingDetails.lastName != null) {
            updateData['lastName'] = existingDetails.lastName;
          }
        }
        
        await update(userId, updateData);
        
        return imageUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
}
