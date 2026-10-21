import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rekanpabrik/components/hrd_navbar_component.dart';
import 'package:rekanpabrik/components/navbar_component.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/pages/welcoming_text.dart';
import 'package:rekanpabrik/shared/shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'poppins',
          canvasColor: thirdColor,
          primaryColor: primaryColor,
          appBarTheme: AppBarTheme(backgroundColor: primaryColor),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.white,
          )),
      initialRoute: '/',
      routes: {
        '/': (context) => const WellcomePage(),
        '/login': (context) => login_page(),
        '/registerPelamar': (context) => register_pelamar(),
        '/pagePelamar': (context) => navbarComponent(),
        '/cariPabrik': (context) => CariPabrik(),
        '/pageHRD': (context) => HRDnavbarComponent(),
        '/cekPelamar': (context) => Cekpelamar(),
        '/splashScreen': (context) => SplashScreen(),
      },
    );
  }
}
