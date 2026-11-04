part of '../page.dart';

class Cekpelamar extends StatefulWidget {
  const Cekpelamar({super.key});

  @override
  State<Cekpelamar> createState() => _CekpelamarState();
}

class _CekpelamarState extends State<Cekpelamar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildInformationCard(),
            const SizedBox(height: 28),
            _buildSearchSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: darkMaroon.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.people_alt_rounded,
                color: darkMaroon,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Pelamar',
                    style: TextStyle(
                      fontSize: 13,
                      color: greyColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pelamar',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkMaroon,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Kelola dan pantau seluruh kandidat yang melamar '
          'pada lowongan pekerjaan perusahaan Anda.',
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: greyColor,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMaroon,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkMaroon.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'REKRUTMEN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tetap Terinformasi Tentang Proses Perekrutan Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Di RekanPabrik, kami membantu Anda mengikuti '
            'setiap tahapan proses perekrutan. Dari lamaran '
            'baru hingga informasi terbaru tentang kandidat '
            'terpilih, Anda dapat menemukan informasi dan '
            'mengelola proses rekrutmen secara lebih efisien.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              height: 1.7,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Pantau proses rekrutmen Anda',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Pelamar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: darkMaroon,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cari dan periksa kandidat yang telah melamar '
          'pada lowongan pekerjaan Anda.',
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: greyColor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 18),
        SearchBarPelamarPekerjaan(),
      ],
    );
  }
}
