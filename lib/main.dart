import 'package:flutter/material.dart';
import 'package:flutter_application_2/password.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:local_auth/local_auth.dart';
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
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;
  final TextEditingController _controllerMaster = TextEditingController();
  static var bytes;
  static var digest;

  @override
  void initState() {
    // TODO: implement initState
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
      _canCheckBiometrics = await auth.canCheckBiometrics;
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

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  /* Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: false,
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
  } */

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: false,
          biometricOnly: true,
        ),
      );
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
    setState(() {
      _authorized = message;
    });
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
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('New User'),
                      content: TextFormField(
                        controller: _controllerMaster,
                        decoration: InputDecoration(
                          hintText: 'Master Key',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.security_update_good),
                            onPressed: () {

                            },
                          )
                          
                        ),
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

                          context.read<Password>().pass(_controllerMaster.text);
                          _showDialog(context);

                          if (_controllerMaster.text.isEmpty) {
                            _showDialog(context);
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: const Text(
                                          'Fingerprint Authenticate'),
                                      actions: [
                                        IconButton(
                                          onPressed: _authenticateWithBiometrics,
                                          icon: const Icon(
                                              Icons.fingerprint_outlined),
                                        ),
                                      ]);
                                });

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
            if (_isAuthenticating)
              ElevatedButton(
                onPressed: _cancelAuthentication,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(Icons.cancel),
                  ],
                ),
              )
            /* Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <Widget>[
                        Icon(Icons.fingerprint_outlined),
                      ],
                    ),
                  )
                ],
              ) */
          ],
        ),
      ),
    );
  }
}


enum _SupportState {
  unknown,
  supported,
  unsupported,
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
