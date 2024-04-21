import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'file_picker_item_details_view.dart';
import 'map_list_view copy.dart';
import 'prime_calc_3_view.dart';
import 'prime_calc_view.dart';
import 'sample_item.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({
    super.key,
    this.items = const [
      SampleItem('算质数-不包含web'),
      SampleItem('算质数-包含web'),
      SampleItem('读取文件'),
      SampleItem('传入Map传出List'),
    ],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  void openFileTest(BuildContext context) async {
    var file = await pickFile();
    if (file != null) {
      if (!context.mounted) return;
      Navigator.pushNamed(context, FilePickerItemDetailsView.routeName,
          arguments: file);
    }
  }

  Future<PlatformFile?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: false,
      withReadStream: true,
    );
    if (result == null) return null;
    return result.files.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('异步测试'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'sampleItemListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          final String route;
          if (index == 0) {
            route = PrimeCalcView.routeName;
          } else if (index == 3) {
            route = MapListView.routeName;
          } else {
            route = PrimeCalc3View.routeName;
          }

          return ListTile(
              title: Text(item.text),
              leading: const CircleAvatar(
                // Display the Flutter Logo image asset.
                foregroundImage: AssetImage('assets/images/flutter_logo.png'),
              ),
              onTap: () {
                if (index == 2) {
                  openFileTest(context);
                  return;
                }
                Navigator.restorablePushNamed(
                  context,
                  route,
                );
              });
        },
      ),
    );
  }
}
