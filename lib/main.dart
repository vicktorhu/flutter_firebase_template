import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> firebaseApp = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Firebase Template',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.orange,
          accentColor: Colors.orange,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: TextButton.styleFrom(backgroundColor: Colors.orange)),
        ),
        home: FutureBuilder(
          future: firebaseApp,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text("ERROR: ${snapshot.error.toString()} ");
            }
            if (snapshot.hasData) {
              return Home();
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Firebase Template'),
        ),
        body: Center(
          child: Container(
            child: RegistrationForm(),
          ),
        ),
      ),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  RegistrationForm({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegistrationForm> {
  final textEmailController = TextEditingController();
  final textPasswordController = TextEditingController();
  bool isLoading = false;

  register() async {
    setState(() {
      isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: textEmailController.text,
              password: textPasswordController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
      textEmailController.text = "";
      textPasswordController.text = "";
    }
  }

  Widget getButtonContent() {
    if (isLoading) {
      return SizedBox(
        child: CircularProgressIndicator(
          backgroundColor: Colors.white,
        ),
        height: 20,
        width: 20,
      );
    } else {
      return Text("Register");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          SizedBox(height: 25),
          Text("Register an account",
              style: TextStyle(color: Colors.orange, fontSize: 25)),
          SizedBox(height: 30),
          TextField(
            controller: textEmailController,
            autocorrect: false,
            decoration: InputDecoration(labelText: "Email"),
          ),
          SizedBox(height: 25),
          TextField(
            controller: textPasswordController,
            obscureText: true,
            decoration: InputDecoration(labelText: "Password"),
          ),
          SizedBox(height: 45),
          ElevatedButton(onPressed: register, child: getButtonContent())
        ],
      ),
    );
  }
}
