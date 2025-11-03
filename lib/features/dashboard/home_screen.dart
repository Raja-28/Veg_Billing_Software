import 'package:fluent_ui/fluent_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Dashboard'),
      ),
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Welcome to the Dashboard!',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 12),
            Text('Use the left navigation to move between modules.'),
          ],
        ),
      ),
    );
  }
}
