import '../../core/auth/auth_session.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/auth_model.dart';
import '../../domain/entities/forgot_password_entity.dart';
import '../../domain/entities/pharmacy_registration.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password
    
  });

  Future<bool> logout();

  Future<UserModel> currentUser();

  Future<SendVerificationResult> sendPharmacyEmailVerification(String email);

  Future<UniqueFieldResult> checkPharmacyFieldUnique({
    required String field,
    required String value,
  });

  Future<Map<String, dynamic>> registerPharmacy(PharmacyRegistrationPayload payload);

  Future<ForgotPasswordRequestResult> requestForgotPassword(String username);

  Future<String> confirmForgotPassword({
    required String username,
    required String code,
    required String newPassword,
  });

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final AuthSession authSession;

  AuthRemoteDataSourceImpl({
    required this.apiClient,
    required this.authSession,
  });

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await apiClient.post(
      '/auth/login',
      body: {
        'username': username,
        'password': password,
        'client_channel': 'mobile',
      },
      useSessionToken: false,
    ) as Map<String, dynamic>;

    final user = UserModel.fromPharmacyLogin(response);
    await authSession.setToken(user.token);
    return user;
  }

  @override
  Future<bool> logout() async {
    await authSession.clear();
    return true;
  }

  @override
  Future<UserModel> currentUser() async {
    final t = authSession.token.value;
    if (t.isEmpty) {
      throw const UnauthorizedException(message: 'Not signed in');
    }
    final response = await apiClient.get('/auth/profile', useSessionToken: true) as Map<String, dynamic>;
    return UserModel.fromPharmacyProfile(response, token: t);
  }

  @override
  Future<SendVerificationResult> sendPharmacyEmailVerification(String email) async {
    final response = await apiClient.post(
      '/auth/send-verification',
      body: {'email': email.trim()},
      useSessionToken: false,
    ) as Map<String, dynamic>;
    return SendVerificationResult.fromJson(response);
  }

  @override
  Future<UniqueFieldResult> checkPharmacyFieldUnique({
    required String field,
    required String value,
  }) async {
    final response = await apiClient.post(
      '/auth/check-unique',
      body: {'field': field, 'value': value.trim()},
      useSessionToken: false,
    ) as Map<String, dynamic>;
    return UniqueFieldResult.fromJson(response);
  }

  @override
  Future<Map<String, dynamic>> registerPharmacy(PharmacyRegistrationPayload payload) async {
    return await apiClient.postMultipart(
      '/auth/register',
      fields: payload.toFields(),
      filePaths: {
        'pan_document': payload.panDocumentPath,
        'gst_document': payload.gstDocumentPath,
        'license_document': payload.licenseDocumentPath,
      },
      useSessionToken: false,
    ) as Map<String, dynamic>;
  }

  @override
  Future<ForgotPasswordRequestResult> requestForgotPassword(String username) async {
    final response = await apiClient.post(
      '/auth/forgot-password',
      body: {'username': username.trim()},
      useSessionToken: false,
    ) as Map<String, dynamic>;
    return ForgotPasswordRequestResult.fromJson(response);
  }

  @override
  Future<String> confirmForgotPassword({
    required String username,
    required String code,
    required String newPassword,
  }) async {
    final response = await apiClient.post(
      '/auth/forgot-password/confirm',
      body: {
        'username': username.trim(),
        'code': code.trim(),
        'new_password': newPassword,
      },
      useSessionToken: false,
    ) as Map<String, dynamic>;
    return response['message']?.toString() ?? 'Password reset successfully';
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await apiClient.put(
      '/auth/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      useSessionToken: true,
    ) as Map<String, dynamic>;
    return response['message']?.toString() ?? 'Password updated successfully.';
  }
}
