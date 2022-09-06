import 'package:flutter/material.dart';
import 'package:flutter_application_2/password.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => Password()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Password Manager'),
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
  static var bytes;
  static var digest;

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
          onPressed: () async {},
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
                          context.read<Password>().pass(_controllerMaster.text);
                          _showDialog(context);
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
          actions: <Widget>[

          ],
        );
      }
  );
}
