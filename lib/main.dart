import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'user_info.dart';
import 'reservation_data.dart';
import 'dorm_data.dart';
import 'home_page.dart';
import 'my_page.dart';
import 'reserve_page.dart';
import 'signin_page.dart';
import 'signup_page.dart';
import 'setting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserInfo()
        ),
        ChangeNotifierProvider(
            create: (context) => ReservationData()
        ),
        ChangeNotifierProvider(
            create: (context) => DormData()
        ),
      ],
      child: MaterialApp(
        title: 'Dormitory Clicker',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/signin',
        routes: {
          '/': (context) => HomePage(),
          '/mypage': (context) => MyPage(),
          '/reservation': (context) => ReservePage(),
          '/signin': (context) => SignInPage(),
          '/signup': (context) => SignUpPage(),
          '/setting' : (context) => SettingPage()
        },
      ),
    );
  }
}