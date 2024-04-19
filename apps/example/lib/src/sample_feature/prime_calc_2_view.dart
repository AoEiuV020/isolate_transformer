import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isolate_manager/isolate_manager.dart';
import 'package:isolate_transformer/isolate_transformer.dart';

import '../function/prime.dart';

/// Displays detailed information about a SampleItem.
class PrimeCalc2View extends StatefulWidget {
  const PrimeCalc2View({super.key});

  static const routeName = '/prime_calc_2';

  @override
  State<PrimeCalc2View> createState() => _PrimeCalc2ViewState();
}

class _PrimeCalc2ViewState extends State<PrimeCalc2View> {
  final numController = StreamController<int>();
  final primeController = StreamController<(int, int)>();
  final isolateTransformer = IsolateTransformer();
  final primeIsolate = IsolateManager.createOwnIsolate(
    findPrimeNumbersIsolateFunction,
  );
  var currentPrime = 1;
  var index = 0;
  @override
  void initState() {
    super.initState();
    initIsolate();
  }

  void initIsolate() {
    primeIsolate.stream.listen((event) {
      currentPrime = event;
      if (!primeController.isClosed) {
        primeController.add((index++, event));
      }
    });
    numController.stream.listen((event) {
      primeIsolate.sendMessage(event);
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
        title: const Text('IsolateManager'),
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
