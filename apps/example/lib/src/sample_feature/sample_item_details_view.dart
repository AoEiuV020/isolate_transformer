import 'dart:async';

import 'package:example/src/prime/prime.dart';
import 'package:flutter/material.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

/// Displays detailed information about a SampleItem.
class SampleItemDetailsView extends StatefulWidget {
  const SampleItemDetailsView({super.key});

  static const routeName = '/sample_item';

  @override
  State<SampleItemDetailsView> createState() => _SampleItemDetailsViewState();
}

class _SampleItemDetailsViewState extends State<SampleItemDetailsView> {
  StreamController<int> numController = StreamController<int>();
  StreamController<int> primeController = StreamController<int>();
  int currentNumber = 1000;
  @override
  void initState() {
    super.initState();
    IsolateTransformer()
        .transform(numController.stream,
            (e) => e.asyncExpand((event) => findPrimeNumbers(event)))
        .listen((event) {
      primeController.add(event);
    });
  }

  void start() {
    numController.add(currentNumber);
    currentNumber *= 10;
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
            ElevatedButton(
              onPressed: () {
                start();
              },
              child: Text('start'),
            ),
          ],
        ),
      ),
    );
  }
}
