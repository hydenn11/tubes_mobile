part of 'page.dart';

class WellcomePage extends StatefulWidget {
  const WellcomePage({super.key});

  @override
  State<WellcomePage> createState() => _WellcomePageState();
}

class _WellcomePageState extends State<WellcomePage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  void _requestNotificationPermission() async {
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != null && !granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Izin Notifikasi ditolak!"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colors matching requested reference
    const Color bgWhite = Colors.white;
    const Color darkMaroon = Color(0xFF801C1C);

    final double topSafeArea = MediaQuery.of(context).padding.top;

    // Ensure status bar icons are dark on white background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: bgWhite,
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Top Wave SVG (Safely positioned below status bar inset)
              Positioned(
                top: topSafeArea,
                left: 0,
                right: 0,
                child: SvgPicture.string(
                  _topWaveSvg,
                  fit: BoxFit.fill,
                  width: MediaQuery.of(context).size.width,
                ),
              ),

              // Bottom Wave SVG
              Positioned(
                bottom: 0,
                right: 0,
                child: SvgPicture.string(
                  _bottomWaveSvg,
                  fit: BoxFit.contain,
                ),
              ),

              // Foreground Content (Vertically centered with 24px horizontal padding)
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Badge Text-Chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: darkMaroon.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.factory_rounded,
                                        size: 16, color: darkMaroon),
                                    SizedBox(width: 8),
                                    Text(
                                      "Solusi Karir Industri & Pabrik",
                                      style: TextStyle(
                                        fontFamily: 'poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: darkMaroon,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 26),

                              // Logo (Scaled up ~18% to 215px for bold presence)
                              Image.asset(
                                'assets/img/logoRekanPabrik.png',
                                height: 215,
                                fit: BoxFit.contain,
                              ),

                              const SizedBox(height: 28),

                              // Action Button 1: Daftar Akun
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/registerPelamar');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkMaroon,
                                    foregroundColor: Colors.white,
                                    elevation: 4,
                                    shadowColor:
                                        darkMaroon.withValues(alpha: 0.45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Daftar Akun',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'poppins',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Action Button 2: Masuk
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: darkMaroon,
                                    side: const BorderSide(
                                        color: darkMaroon, width: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'poppins',
                                      color: darkMaroon,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _topWaveSvg = '''
<svg width="393" height="281" viewBox="0 0 393 281" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M0 0H393L330.241 56.4373C325.459 60.7381 319.891 64.0758 313.844 66.2674L256.713 86.9719C249.797 89.4783 243.998 94.3624 240.352 100.751L219.347 137.556C214.142 146.677 204.672 152.542 194.187 153.14L156.573 155.284C144.619 155.965 134.127 163.47 129.619 174.562L119.256 200.061C115.348 209.676 106.888 216.698 96.7163 218.767L56.1527 227.018C49.5634 228.358 43.5885 231.805 39.1292 236.838L0 281V0Z" fill="#801C1C" fill-opacity="0.72"/>
<path d="M0 0H357.911L301.401 50.66C296.619 54.9473 291.056 58.2731 285.015 60.4555L234.747 78.6165C227.832 81.1147 222.03 85.9895 218.377 92.3703L200.516 123.57C195.304 132.673 185.843 138.524 175.371 139.119L144.322 140.883C132.378 141.562 121.89 149.053 117.374 160.131L109.18 180.232C105.264 189.838 96.8017 196.849 86.6344 198.911L52.031 205.928C45.4506 207.262 39.4813 210.697 35.0208 215.715L0 255.118V0Z" fill="#801C1C"/>
</svg>
''';

const String _bottomWaveSvg = '''
<svg width="143" height="159" viewBox="0 0 143 159" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M143 159H71.5L0 159L19.0157 132.408C23.2673 126.462 28.7708 121.521 35.1386 117.933L43.5407 113.197C49.9617 109.579 54.8833 103.791 57.4227 96.8715L61.8093 84.919C64.5041 77.5763 71.1961 72.4495 78.9871 71.7589C87.4822 71.0059 94.5889 64.9982 96.7452 56.7469L98.1009 51.5598C100.455 42.5524 107.268 35.3844 116.145 32.5767C122.649 30.5193 128.138 26.0839 131.515 20.1564L143 0L143 159Z" fill="#801C1C"/>
</svg>
''';
