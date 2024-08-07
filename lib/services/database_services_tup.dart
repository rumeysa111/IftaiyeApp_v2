import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/tup.dart';
import 'package:fire_appp/kayitlar/tup_kayit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String TUP_COLLECTION_REF = "Tup_Kayit";

class DatabaseServicesTup {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Tup> _tupkayitlarRef;

  DatabaseServicesTup() {
    _tupkayitlarRef = _firestore.collection(TUP_COLLECTION_REF).withConverter<Tup>(
      fromFirestore: (snapshot, _) => Tup.fromJson(snapshot.data()!),
      toFirestore: (tup, _) => tup.toJson(),
    );
  }

  Stream<QuerySnapshot<Tup>> getTup() {
    return _tupkayitlarRef
        .where('Kontrol', isEqualTo: false)

        .orderBy('Tarih', descending: true) // Tarihe göre sıralama
        .snapshots();
  }
 // Stream<QuerySnapshot<Tup>> getTup() {
   // return _tupkayitlarRef

     //   .orderBy('Tarih', descending: true) // Tarihe göre sıralama
       // .snapshots();
  //}
  Future<void> addTup(Tup tup) async {
    await _tupkayitlarRef.add(tup);
  }

  Future<void> updateTup(String tupId, Tup tup) async {

    await _tupkayitlarRef.doc(tupId).update(tup.toJson());


  }

  Future<void> deleteTup(String tupId) async {
    await _tupkayitlarRef.doc(tupId).delete();
  }
}
