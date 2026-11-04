import 'package:flutter/material.dart';
import 'package:rekanpabrik/pages/pengaduan/kirim_pengaduan.dart';
import 'package:rekanpabrik/shared/shared.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class Pengaduan extends StatefulWidget {
  const Pengaduan({super.key});

  @override
  State<Pengaduan> createState() => _PengaduanState();
}

class _PengaduanState extends State<Pengaduan> {
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryColor = Color(0xFF7B1E2B);
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  String? _whatsappUrl;
  bool _isOpeningWhatsApp = false;

  @override
  void initState() {
    super.initState();
    _whatsappUrl = dotenv.env['WA_URL'];
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
            ),
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _launchWhatsApp() async {
    if (_isOpeningWhatsApp) return;

    final String? url = _whatsappUrl?.trim();

    if (url == null || url.isEmpty || url == 'null') {
      _showMessage('Link WhatsApp belum tersedia.');
      return;
    }

    final Uri? uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      _showMessage('Link WhatsApp tidak valid.');
      return;
    }

    setState(() {
      _isOpeningWhatsApp = true;
    });

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showMessage('Tidak dapat membuka WhatsApp.');
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Terjadi kesalahan saat membuka WhatsApp.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningWhatsApp = false;
        });
      }
    }
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Color accentColor,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 27,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title == 'Live Chat' ? 'WhatsApp' : 'Formulir',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: _secondaryTextColor,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                disabledBackgroundColor: accentColor.withOpacity(0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          buttonText,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'Customer Service',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Hubungi Customer Service Kami',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Kami siap membantu menjawab pertanyaan, menangani kendala, dan menerima masukan Anda. Silakan pilih layanan yang sesuai dengan kebutuhan.',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 11,
                        color: Colors.white70,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Pilih Layanan',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Tentukan cara yang paling nyaman untuk menghubungi kami.',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 10,
                  color: _secondaryTextColor,
                ),
              ),
              const SizedBox(height: 17),
              _buildContactCard(
                icon: Icons.chat_rounded,
                title: 'Live Chat',
                description:
                    'Hubungi tim kami secara langsung melalui WhatsApp untuk mendapatkan bantuan dan jawaban atas pertanyaan Anda.',
                buttonText: 'Hubungi via WhatsApp',
                accentColor: const Color(0xFF16A34A),
                isLoading: _isOpeningWhatsApp,
                onPressed: _launchWhatsApp,
              ),
              const SizedBox(height: 16),
              _buildContactCard(
                icon: Icons.email_outlined,
                title: 'Kirim Pengaduan',
                description:
                    'Sampaikan keluhan, kendala, atau saran Anda melalui formulir pengaduan. Tim kami akan meninjau laporan tersebut.',
                buttonText: 'Buat Pengaduan',
                accentColor: _primaryColor,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KirimPengaduan(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFD97706),
                      size: 19,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pastikan Anda menyampaikan informasi yang jelas agar tim kami dapat membantu menyelesaikan kendala dengan lebih tepat.',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 10,
                          color: Color(0xFF92400E),
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
