import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/dolap.dart';

const String DOLAP_COLLECTION_REF = "Doalp_Kayit";

class DatabaseServicesDolap {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Dolap> _dolapKayitlarRef;

  DatabaseServicesDolap() {
    _dolapKayitlarRef =
        _firestore.collection(DOLAP_COLLECTION_REF).withConverter<Dolap>(
          fromFirestore: (snapshots, _) => Dolap.fromJson(snapshots.data()!),
          toFirestore: (dolap, _) => dolap.toJson(),
        );
  }

  Stream<QuerySnapshot<Dolap>> getDolap() {
    return _dolapKayitlarRef
        .where('Kontrol', isEqualTo: false)
        .orderBy('Tarih', descending: true)
        .snapshots();
  }
  // Stream<QuerySnapshot<Tup>> getTup() {
  // return _dolapkayitlarRef

  //   .orderBy('Tarih', descending: true) // Tarihe göre sıralama
  // .snapshots();
  //}

  Future<void> updateDolap(String dolapId, Dolap dolap) async {
    await _dolapKayitlarRef.doc(dolapId).update(dolap.toJson());
  }
}
