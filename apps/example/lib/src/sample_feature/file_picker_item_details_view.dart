import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

import '../function/file.dart';

class FilePickerItemDetailsView extends StatelessWidget {
  FilePickerItemDetailsView(this.currentFile, {super.key});

  static const routeName = '/file_picker_item';

  final PlatformFile currentFile;
  final isolateTransformer = IsolateTransformer();

  Stream<List<String>> getStream() async* {
    List<String> items = [];
    final stream = isolateTransformer.transform(
      currentFile.readStream!,
      fileReadTrunkTransform,
      workerName: 'fileReadTrunkTransform',
    );
    await for (String str in stream) {
      items.add(str);
      yield items;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentFile.name),
      ),
      body: Center(
        child: StreamBuilder(
            stream: getStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}\n${snapshot.stackTrace}');
              }
              final done = snapshot.connectionState == ConnectionState.done;
              if (done && !snapshot.hasData) {
                return Text("empty ${currentFile.name}");
              }
              if (!snapshot.hasData) {
                return Text("loading ${currentFile.name}");
              }
              var data = snapshot.requireData;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) => ListTile(
                    title: Text(data[index]),
                    leading: const CircleAvatar(
                      foregroundImage:
                          AssetImage('assets/images/flutter_logo.png'),
                    ),
                    onTap: () {
                      log("onTap");
                    }),
              );
            }),
      ),
    );
  }
}
