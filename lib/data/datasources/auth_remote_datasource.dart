import '../../core/auth/auth_session.dart';
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
      body: {'username': username, 'password': password},
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
}
