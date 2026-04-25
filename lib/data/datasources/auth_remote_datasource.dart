import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<bool> logout();

  Future<UserModel> currentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  const AuthRemoteDataSourceImpl({required this.apiClient});

  // ===========================================================================
  // 🔧 DUMMY IMPLEMENTATION — REPLACE WITH YOUR REAL API CALL
  // ===========================================================================
  // Behavior of the mock:
  //   • Simulates ~1.2s network latency
  //   • Throws UnauthorizedException for known-bad credentials so the UI's
  //     error path can be tested end-to-end
  //   • Otherwise returns a UserModel with a fake bearer token
  //
  // To switch to the real backend, delete the mock block below the marker
  // and uncomment the production block at the bottom.
  // ===========================================================================
  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // ---------- BEGIN MOCK ----------
    await Future.delayed(const Duration(milliseconds: 1200));

    // Reject these to test error handling
    const invalidUsers = ['invalid', 'wronguser'];
    const invalidPasswords = ['wrong', 'wrongpass'];
    if (invalidUsers.contains(username.toLowerCase()) ||
        invalidPasswords.contains(password.toLowerCase())) {
      throw const UnauthorizedException(
        message: 'Invalid username or password',
      );
    }

    return UserModel(
      userId: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      token: 'dummy_token_${DateTime.now().millisecondsSinceEpoch}',
      pharmacyCode: username.toUpperCase().startsWith('PH') ? username.toUpperCase() : 'PH001',
      role: 'pharmacist',
      email: '$username@virchowrx.app',
      tokenExpiresAt: DateTime.now().add(const Duration(hours: 24)),
    );
    // ---------- END MOCK ----------

    // ---------- PRODUCTION (uncomment when API is ready) ----------
    // final response = await apiClient.post('/auth/login', body: {
    //   'username': username,
    //   'password': password,
    // });
    // return UserModel.fromJson(response['data'] ?? response);
    // --------------------------------------------------------------
  }

  @override
  Future<bool> logout() async {
    // ---------- BEGIN MOCK ----------
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
    // ---------- END MOCK ----------

    // ---------- PRODUCTION ----------
    // await apiClient.post('/auth/logout');
    // return true;
    // --------------------------------
  }

  @override
  Future<UserModel> currentUser() async {
    // ---------- BEGIN MOCK ----------
    await Future.delayed(const Duration(milliseconds: 300));
    throw const UnauthorizedException(message: 'Not signed in');
    // ---------- END MOCK ----------

    // ---------- PRODUCTION ----------
    // final response = await apiClient.get('/auth/me');
    // return UserModel.fromJson(response['data'] ?? response);
    // --------------------------------
  }
}