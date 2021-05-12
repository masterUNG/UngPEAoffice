import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ungpeaofficer/states/authen.dart';
import 'package:ungpeaofficer/states/my_service.dart';

final Map<String, WidgetBuilder> map = {
  '/authen': (BuildContext context) => Authen(),
  '/myService': (BuildContext context) => MyService(),
};

String initialRoute;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String employedid = preferences.getString('emyloyedid');
  if (employedid == null) {
    initialRoute = '/authen';
    runApp(MyApp());
  } else {
    initialRoute = '/myService';
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: map,
      initialRoute: initialRoute,
      theme: ThemeData(primarySwatch: Colors.purple),
    );
  }
}
