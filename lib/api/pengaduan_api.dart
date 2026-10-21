class Pengaduanapi {
  final String apiUrl = 'dummy_mode';

  Future<bool> kirimPengaduan(
    String firstName,
    String lastName,
    String email,
    String phone,
    String message,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}