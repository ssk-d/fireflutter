# Example

## main.dart

```dart
void main() async {
  try {
    await ff.init(
      enableNotification: true,
      firebaseServerToken: '...',
      settings: {},
      translations: translations,
    );
  } catch (e) {
    print('Error: $e');
  }

  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();

    ff.settingsChange.listen((settings) {
      setState(() {}); // You may re-render the screen if you wish.
    });

    ff.translationsChange.listen(
        (translations) => setState(() => updateTranslations(translations)));

    ff.notification.listen((x) {
        Map<String, dynamic> notification = x['notification'];
        Map<dynamic, dynamic> data = x['data'];
        NotificationType type = x['type'];
        print('NotificationType: $type');
        print('notification: $notification');
        print('data: $data');
        // ...
    );
  }
  // ..
```
