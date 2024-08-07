import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/pompa.dart';
import 'package:fire_appp/models/tup.dart';

const String POMPA_COLLECTION_REF = "Pompa_Kayit";

class DatabaseServicesPompa {
  final _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Pompa> _pompakayitlarRef;
  DatabaseServicesPompa() {
    _pompakayitlarRef =
        _firestore.collection(POMPA_COLLECTION_REF).withConverter<Pompa>(
            fromFirestore: (snapshots, _) => Pompa.fromJson(
                  snapshots.data()!,
                ),
            toFirestore: (pompa, _) => pompa.toJson());
  }
  Stream<QuerySnapshot<Pompa>> getPompa() {
    return _pompakayitlarRef
        .where('Kontrol', isEqualTo: false)
        .orderBy('Tarih',
            descending:
                true) // En son eklenen verilerin başta olması için descending: true olarak ayarlanıyor
        .snapshots();
  }
  // Stream<QuerySnapshot<Tup>> getTup() {
  // return _pompakayitlarRef

  //   .orderBy('Tarih', descending: true) // Tarihe göre sıralama
  // .snapshots();
  //}
  void addPompa(Pompa pompa) async {
    _pompakayitlarRef.add(pompa);
  }

  Future<void> updatePompa(String pompaId, Pompa pompa) async {
    await _pompakayitlarRef.doc(pompaId).update(pompa.toJson());
  }

  void deletePompa(String pompaId) {
    _pompakayitlarRef.doc(pompaId).delete();
  }
}
