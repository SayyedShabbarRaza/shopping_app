import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shopping/models/provider.dart';
import 'package:shopping/screens/auth.dart';
import 'package:shopping/screens/splash_screen.dart';
import 'package:shopping/widgets/side_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => Auth()),
        ChangeNotifierProxyProvider<Auth, Providerr>(
          create: (ctx) => Providerr('', []),  // Initialize with default values
          update: (context, auth, previous) => Providerr(
            auth.token ?? '',  // Handle the case where token might be null
            previous == null ? [] : previous.list,
          ),
        ),
        ChangeNotifierProvider(create: (ctx) => FavouriteProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders('', [],''),  // Initialize with default values
          update: (context, auth, previous) => Orders(
            auth.token ?? '',  // Handle the case where token might be null
            previous == null ? [] : previous.orders,auth.userId??'',
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
            textTheme: GoogleFonts.latoTextTheme(),
            useMaterial3: true,
          ),
          home: auth.isAuth
              ? ProductScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SplashScreen(); // Replace with your loading widget
                    } else {
                      if (snapshot.hasError || snapshot.data == false) {
                        return AuthScreen(); // Auto-login failed, show login screen
                      } else {
                        return ProductScreen(); // Auto-login successful, show main screen
                      }
                    }
                  },
                ),
        ),
      ),
    );
  }
}
