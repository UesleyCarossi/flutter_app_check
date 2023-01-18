import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const kWebRecaptchaSiteKey = '6LelgQckAAAAAKSM79haqoVP0bwSmwgwK26WpIwv';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp firebaseApp = await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    //webRecaptchaSiteKey: kWebRecaptchaSiteKey,
    //androidProvider: AndroidProvider.debug,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String title = 'Firebase App Check';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase App Check',
      home: FirebaseAppCheckExample(title: title),
    );
  }
}

class FirebaseAppCheckExample extends StatefulWidget {
  const FirebaseAppCheckExample({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _FirebaseAppCheck createState() => _FirebaseAppCheck();
}

class _FirebaseAppCheck extends State<FirebaseAppCheckExample> {
  final appCheck = FirebaseAppCheck.instance;
  String _message = '';
  String _eventToken = 'not yet';
  String _requestResponse = 'not yet';

  @override
  void initState() {
    appCheck.onTokenChange.listen(setEventToken);
    super.initState();
  }

  void setMessage(String message) {
    setState(() {
      _message = message;
    });
  }

  void setEventToken(String? token) {
    setState(() {
      _eventToken = token ?? 'not yet';
    });
  }

  void setRequestResponse(String? response) {
    setState(() {
      _requestResponse = response ?? 'not yet';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // Use this button to check whether the request was validated on the Firebase console
                // Gets first document in collection
                final result = await FirebaseFirestore.instance
                    .collection('flutter-tests')
                    .limit(1)
                    .get();

                if (result.docs.isNotEmpty) {
                  setMessage('Document found');
                } else {
                  setMessage(
                    'Document not found, please add a document to the collection',
                  );
                }
              },
              child: const Text('Test App Check validates requests'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Token will be passed to `onTokenChange()` event handler
                setEventToken(await appCheck.getToken(true));
              },
              child: const Text('getToken()'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_eventToken != null) {
                  final response = await http.put(
                    Uri.parse("https://3333-uesleycarossi-goapi-pcakk2p1nei.ws-us83.gitpod.io/app-check"),
                    headers: {"X-Firebase-AppCheck": _eventToken},
                  );
                  setRequestResponse('${response.statusCode} (${response.reasonPhrase}):  ${response.body}');
                } else {
                  // Error: couldn't get an App Check token.
                }
              },
              child: const Text('callApi()'),
            ),
            ElevatedButton(
              onPressed: () async {
                await appCheck.setTokenAutoRefreshEnabled(true);
                setMessage('successfully set auto token refresh!!');
              },
              child: const Text('setTokenAutoRefreshEnabled()'),
            ),
            const SizedBox(height: 20),
            Text(
              _message, //#007bff
              style: const TextStyle(
                color: Color.fromRGBO(47, 79, 79, 1),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Token received from getToken() API: $_eventToken', //#007bff
              style: const TextStyle(
                color: Color.fromRGBO(128, 0, 128, 1),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Response received from callApi() Response: $_requestResponse', //#007bff
              style: const TextStyle(
                color: Color.fromRGBO(128, 0, 128, 1),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
