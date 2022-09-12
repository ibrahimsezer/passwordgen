import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/master_key_page.dart';
import 'package:flutter_application_2/passwords_page.dart';
import 'package:flutter_application_2/view_model/pass_button_visibility.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:local_auth/local_auth.dart';
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
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  final TextEditingController _controllerMaster = TextEditingController();
  final TextEditingController _masterKey = TextEditingController();



  @override
  void initState() {
    super.initState();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      print('1 $_authorized');
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
        ),
      );
      print('2 $_authorized');
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    print('3 $_authorized');
    setState(() {
      _authorized = message;
    });
    print('4 $_authorized');
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
  }

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
          onPressed: () async {
            var temp = await context.read<MasterKeyPage>().passRead();
            if (temp == '') {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text('New User'),
                        content: TextFormField(
                          controller: _masterKey,
                          decoration: InputDecoration(
                              hintText: 'Master Key',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.security_update_good),
                                onPressed: () async {
                                  context
                                      .read<MasterKeyPage>()
                                      .pass(_masterKey.text);
                                  const snackBar = SnackBar(
                                    content: Text('registered'),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  Navigator.of(context).pop();
                                },
                              )),
                        ),
                      ));
            } else {
              showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Icon(Icons.warning_amber, size: 30, color: Colors.red),
                  content: Text(
                    'There is registered user',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }
          },
        ),
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: screenSize.width / 1.1,
                child: TextFormField(
                  obscureText: true,
                  controller: _controllerMaster,
                  decoration: InputDecoration(
                      hintText: "Master Key",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          var temp =
                              await context.read<MasterKeyPage>().passRead();
                          print(temp);
                          if (_controllerMaster.text.isEmpty ||
                              _controllerMaster.text != temp ) {
                            _showDialog(context);
                          } else {
                            if (_controllerMaster.text == temp) {
                              if (_isAuthenticating) {
                                ElevatedButton(
                                  onPressed: _cancelAuthentication,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const <Widget>[
                                      Icon(Icons.cancel),
                                    ],
                                  ),
                                );
                              } else {
                                await _authenticateWithBiometrics();
                                print('Current State: $_authorized');
                                if(_authorized == 'Authorized'){
                                  context
                                      .read<MasterKeyPage>()
                                      .pass(_controllerMaster.text);
                                  Beamer.of(context).beamToNamed("/password_page");
                                }
                              }
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                        title: Row(
                                          children: const [
                                            Icon(
                                              Icons.warning_amber,
                                              size: 30,
                                              color: Colors.red,
                                            ),
                                            Text(
                                              ' ALERT',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )
                                          ],
                                        ),
                                        content: const Text('Wrong Password'),
                                      ));
                            }
                            /* context
                                .read<MasterKeyPage>()
                                .pass(_controllerMaster.text);
                            Beamer.of(context).beamToNamed("/password_page"); */
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
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.warning_amber,
                size: 30,
                color: Colors.red,
              ),
              Text(
                ' WRONG',
                style:
                TextStyle(color: Colors.red),
              )
            ],
          ),
        );
      });
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}
