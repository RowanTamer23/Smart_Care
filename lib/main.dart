import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smart_care/core/routes/app_router.dart';
import 'package:smart_care/core/routes/routes.dart';
import 'package:smart_care/features/auth/data/repository/auth_impl.dart';
import 'package:smart_care/features/doctor/profile/cubit/profile_cubit.dart';
import 'package:smart_care/features/doctor/profile/data/repository/profil_repo_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smart_care/features/auth/cubit/auth_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://hbnvbekhyyaclymabwwi.supabase.co",
    anonKey: "sb_publishable_0lo-1ihNR7sX5RPnD3JMhQ_6tOQAt5Y",
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  // Register Supabase client so GetIt can resolve it inside setupMedicalStaff

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SignUpCubit(AuthRepoImpl())),
        BlocProvider(create: (context) => LoginCubit(AuthRepoImpl())),
        BlocProvider(create: (context) => LogoutCubit(AuthRepoImpl())),
        BlocProvider(
            create: (context) => ProfileCubit(ProfileRepositoryImpl())),
        BlocProvider(
            create: (context) =>
                MedicalStaffCubit(MedicalStaffRepositoryImpl())),
        BlocProvider(
            create: (context) => SpecialityCubit(SpecialityRepositoryImpl())),
        BlocProvider(
            create: (context) => DocumentCubit(DocumentRepositoryImpl())),
      ],
      child: const SmartCareApp(),
    ),
  );
}

class SmartCareApp extends StatelessWidget {
  const SmartCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart-Care',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D3B38),
          primary: const Color(0xFF0D3B38),
          secondary: const Color(0xFFF5C518),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.dmSansTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7F5),
      ),
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: Routes.splash,
    );
  }
}
