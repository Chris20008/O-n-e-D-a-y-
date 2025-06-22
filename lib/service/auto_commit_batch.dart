import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class AutoCommitBatch {
  late final FirebaseFirestore firestore;
  WriteBatch? _batch;
  Timer? _timer;
  int _counter = 0;
  int _writes = 0;
  int _deletes = 0;
  bool _waitingForCommit = false;

  final int maxBatchSize;
  final Duration autoCommitDuration;

  AutoCommitBatch({
    this.autoCommitDuration = const Duration(milliseconds: 500),
    this.maxBatchSize = 400,
    required this.firestore
  });

  void _startAutoCommitTimer() {
    _timer?.cancel();
    _timer = Timer(autoCommitDuration, commit);
  }

  Future<WriteBatch> get currentBatch async{
    if(_counter >= maxBatchSize){
      await commit();
    }
    if (_batch == null) {
      _batch = firestore.batch();
      _startAutoCommitTimer();
    }
    return _batch!;
  }

  Future set(DocumentReference ref, Map<String, dynamic> data, [SetOptions? options]) async{
    (await currentBatch).set(ref, data, options);
    // _counter += data.length;
    _counter += 1;
    _writes += 1;
  }

  Future update(DocumentReference ref, Map<String, dynamic> data) async{
    (await currentBatch).update(ref, data);
    // _counter += data.length;
    _counter += 1;
    _writes += 1;
  }

  Future delete(DocumentReference ref) async{
    (await currentBatch).delete(ref);
    _counter += 1;
    _deletes += 1;
  }

  Future<void> commit() async {
    if(_waitingForCommit){
      while (_waitingForCommit) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    _waitingForCommit = true;

    try{
      final batchToCommit = _batch;
      _batch = null;
      _counter = 0;
      _writes = 0;
      _deletes = 0;
      _timer?.cancel();
      _timer = null;

      if (batchToCommit != null) {
        await batchToCommit.commit();
      }
    }
    finally{
      _waitingForCommit = false;
    }
  }

  void dispose() {
    _batch = null;
    _timer?.cancel();
  }
}