class LupaPasswordapi {
  final String apiUrl = 'dummy_mode';

  Future<bool> requestResetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
