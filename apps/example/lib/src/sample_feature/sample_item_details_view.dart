import 'dart:async';

import 'package:example/src/prime/prime.dart';
import 'package:flutter/material.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

import '../bean/count.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatefulWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  final numController = StreamController<int>();
  final primeController = StreamController<(int, int)>();
  final isolateTransformer = IsolateTransformer();
  var currentPrime = 1;
  var index = 0;
  @override
  void initState() {
    super.initState();
    initIsolate();
  }

  void initIsolate() {
    final prime = Prime();
    prime.setHash();
    isolateTransformer
        .transform(numController.stream, prime.transform)
        .listen((event) {
      currentPrime = event;
      if (!primeController.isClosed) {
        primeController.add((index++, event));
      }
    });
  }

  void start() {
    index = 0;
    numController.add(currentPrime);
  }

  @override
  void dispose() {
    numController.close();
    primeController.close();
    isolateTransformer.killAllIsolates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder<Object>(
                stream: primeController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text('0');
                  } else {
                    return Text(
                      'prime number: ${snapshot.data}',
                    );
                  }
                }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    start();
                  },
                  child: Text('start'),
                ),
                CircularProgressIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
