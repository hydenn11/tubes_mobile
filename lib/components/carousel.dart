import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/perusahaan_api.dart';
import 'package:rekanpabrik/models/perusahaan.dart';
import 'package:rekanpabrik/shared/shared.dart';

class Carousel extends StatefulWidget {
  final List<Map<String, dynamic>> dummyPerusahaan;

  const Carousel({super.key, required this.dummyPerusahaan});

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int _currentSlideIndex = 0;
  List<Perusahaan> results = [];
  List<Perusahaan> allresults = [];
  String defaultFotoIMG = 'assets/img/iconRekanPabrik.png';

  @override
  void initState() {
    super.initState();
    _fetchPerusahaan();
  }

  Future<void> _fetchPerusahaan() async {
    try {
      print("=== FETCH PERUSAHAAN ===");

      final pekerjaanData = await PerusahaanAPI().getAllPerusahaan();

      print("=== RESPONSE ===");
      print(pekerjaanData);

      if (!mounted) return;

      setState(() {
        allresults =
            pekerjaanData.map((job) => Perusahaan.fromJson(job)).toList();

        results = allresults.take(5).toList();
      });

      print("Jumlah perusahaan: ${results.length}");
    } catch (e, stackTrace) {
      print("=== ERROR CAROUSEL ===");
      print(e);
      print(stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat Carousel: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            enlargeCenterPage: false,
            autoPlay: true,
            aspectRatio: 16 / 9,
            autoPlayInterval: Duration(seconds: 3),
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              setState(() {
                _currentSlideIndex = index;
              });
            },
          ),
          items: results.map((company) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: thirdColor,
                      width: 2.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        company.profilePict != null &&
                                company.profilePict!.isNotEmpty
                            ? Image.network(
                                company.profilePict!,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    defaultFotoIMG,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                defaultFotoIMG,
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                        SizedBox(height: 10),
                        Text(
                          company.namaPerusahaan,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(217, 217, 217, 100),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${company.jumlahPostingan} Lowongan",
                            style: TextStyle(
                              fontSize: 14,
                              color: blackColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
