import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/view_model/master_key_page.dart';
import 'package:flutter_application_2/passwords_page.dart';
import 'package:flutter_application_2/view_model/pass_button_visibility.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('data_box');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => MasterKeyPage()),
        ChangeNotifierProvider(create: (c) => PassButtonVisibility()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final routerDelegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(routes: {
    "/": (p0, p1, p2) => const MyHomePage(title: "MainPage"),
    "/password_page": (p0, p1, p2) => const PasswordPage(),
  }));

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controllerMaster = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return SafeArea(
      //appBardan alan kurtarma
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          hoverColor: Colors.transparent,
          backgroundColor: Colors.grey,
          child: const Icon(
            Icons.add,
            size: 40.0,
          ),
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: const Text('New User'),
                      content: TextFormField(
                        decoration: InputDecoration(
                            hintText: 'Master Key',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.security_update_good),
                              onPressed: () {},
                            )),
                      ),
                    ));
          },
        ),
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: screenSize.width / 1.1,
                child: TextFormField(
                  controller: _controllerMaster,
                  decoration: InputDecoration(
                      hintText: "Master Key",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_controllerMaster.text.isEmpty) {
                            _showDialog(context);
                          } else {
                            context
                                .read<MasterKeyPage>()
                                .pass(_controllerMaster.text);
                            Beamer.of(context).beamToNamed("/password_page");
                          }
                        },
                      )),
                ),
              ),
            ),
            /* Positioned(
              bottom: 10,
              right: 10,
              child: IconButton(
                iconSize: 50,
                icon: const Icon(Icons.add_circle),
                onPressed: (){

                },
              ),
            ) */
          ],
        ),
      ),
    );
  }
}

void _showDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("WRONG!"),
          content: Text("Please, Enter Key"),
          actions: <Widget>[],
        );
      });
}
