import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rekanpabrik/api/login_api.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/melamar_pekerjaan_api.dart';
import 'package:rekanpabrik/api/pelamar_api.dart';
import 'package:rekanpabrik/api/perusahaan_api.dart';
import 'package:rekanpabrik/api/posting_pekerjaan_api.dart';
import 'package:rekanpabrik/api/saved_jobs_api.dart';
import 'package:rekanpabrik/components/company_name_input.dart';
import 'package:rekanpabrik/components/search_bar_pelamar_pekerjaan.dart';
import 'package:rekanpabrik/pages/hrd/change_profile_page_perusahaan.dart';
import 'package:rekanpabrik/pages/hrd/reset_pass_perusahaan.dart';
import 'package:rekanpabrik/pages/auth/lupa_password.dart';
import 'package:rekanpabrik/pages/pelamar/change_profile_page_pelamar.dart';
import 'package:rekanpabrik/pages/pelamar/reset_pass_pelamar.dart';
import 'package:rekanpabrik/pages/pelamar/upload_cv.dart';
import 'package:rekanpabrik/pages/pengaduan/pengaduan.dart';
import 'package:url_launcher/url_launcher.dart';

// COMPONENTS
import 'package:rekanpabrik/components/carousel.dart';
import 'package:rekanpabrik/components/confirm_pass_input.dart';
import 'package:rekanpabrik/components/container_home_pelamar.dart';
import 'package:rekanpabrik/components/email_input.dart';
import 'package:rekanpabrik/components/name_input.dart';
import 'package:rekanpabrik/components/pass_input.dart';
import 'package:rekanpabrik/components/search_bar_cari_pabrik.dart';
import 'package:rekanpabrik/components/search_bar_cari_pekerjaan.dart';
import 'package:rekanpabrik/components/search_bar_riwayat_lamaran.dart';
import 'package:rekanpabrik/components/search_bar_saved_jobs.dart';

// THEMES
import 'package:rekanpabrik/shared/shared.dart';

// UTILS
import 'package:rekanpabrik/dummy/dummy_melamar_pekerjaan.dart';
import 'package:rekanpabrik/dummy/dummy_perusahaan.dart';
import 'package:rekanpabrik/utils/formatted_date.dart';

import '../components/hrd_navbar_component.dart';

// PAGES
part 'welcome_page.dart';

// UTILS
part 'auth/register_pelamar.dart';
part 'auth/login_page.dart';
part 'auth/register_hrd.dart';

// PELAMAR
part 'pelamar/home_pelamar.dart';
part 'pelamar/cari_pabrik.dart';
part 'pelamar/saved_jobs.dart';
part 'pelamar/cari_pekerjaan.dart';
part 'pelamar/lamar_pekerjaan.dart';
part 'pelamar/riwayat_lamaran.dart';
part 'pelamar/detail_saved_jobs.dart';
part 'pelamar/detail_history_lamaran.dart';
part 'pelamar/profile_page.dart';
part 'pelamar/detail_perusahaan.dart';
part 'pelamar/detail_pekerjaan.dart';

//HRD
part 'hrd/homepage_hrd.dart';
part 'hrd/post_history.dart';
part 'hrd/profile_hrd.dart';
part 'hrd/cek_pelamar.dart';
part 'hrd/post_job.dart';
part 'hrd/detail_pekerjaan_hrd.dart';
