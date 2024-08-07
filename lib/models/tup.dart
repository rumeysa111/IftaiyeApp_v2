import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Tup {
  final String adres;
 // final Timestamp updatedOn;
  final String createdOn;
  final String aciklama;
  final String cinsi;
  final bool emniyetPini;
  final bool fizikiDurum;
  final String imageUrl;
  final bool nanometreGostergesi;
  final bool tetikTerkibat;
  final bool tupYerinde;
 // final String qrCode;
  final String userEmail;
  final bool Kontrol;
  Tup({
    required this.userEmail,
    required this.adres,
  //  required this.updatedOn,
    required this.createdOn,
    required this.aciklama,
    required this.cinsi,
    required this.emniyetPini,
    required this.fizikiDurum,
    required this.imageUrl,
    required this.nanometreGostergesi,
    required this.tetikTerkibat,
    required this.tupYerinde,
   // required this.qrCode,
    required this.Kontrol,
  });

  factory Tup.fromJson(Map<String, Object?> json) {

    return Tup(
      adres: json['Adres'] as String,
      createdOn: json['Tarih'] as String,
        //  ? json['updatedOn'] as Timestamp
          //: Timestamp.now(),
      aciklama: json['Aciklama'] as String,
      cinsi: json['Cinsi'] as String,
      emniyetPini: json['Soru3'] as bool,
      fizikiDurum: json['Soru5'] as bool,
      imageUrl: json['image'] as String,
      nanometreGostergesi: json['Soru1'] as bool,
      tetikTerkibat: json['Soru2'] as bool,
      tupYerinde: json['Soru4'] as bool,
      //qrCode: json['qrCode'] as String,
      userEmail: json['Kayit_Yapan'] as String,  // Yeni alan
      Kontrol: json['Kontrol'] as bool,

    );
  }

  Tup copyWith({
    String? adres,
    String? createdOn,
   // Timestamp? updatedOn,
    String? aciklama,
    String? cinsi,
    bool? emniyetPini,
    bool? fizikiDurum,
    String? imageUrl,
    bool? nanometreGostergesi,
    bool? tetikTerkibat,
    bool? tupYerinde,
  //  String? qrCode,
    String? userEmail,
    bool? Kontrol,

  }) {
    return Tup(
      adres: adres ?? this.adres,
      createdOn: createdOn ?? this.createdOn,
      //updatedOn: updatedOn ?? this.updatedOn,
      aciklama: aciklama ?? this.aciklama,
      cinsi: cinsi ?? this.cinsi,
      emniyetPini: emniyetPini ?? this.emniyetPini,
      fizikiDurum: fizikiDurum ?? this.fizikiDurum,
      imageUrl: imageUrl ?? this.imageUrl,
      nanometreGostergesi: nanometreGostergesi ?? this.nanometreGostergesi,
      tetikTerkibat: tetikTerkibat ?? this.tetikTerkibat,
      tupYerinde: tupYerinde ?? this.tupYerinde,
     // qrCode: qrCode ?? this.qrCode,
      userEmail: userEmail ?? this.userEmail,  // Yeni alan
      Kontrol: Kontrol ?? this.Kontrol,

    );
  }

  Map<String, Object?> toJson() {
    return {
      'Adres': adres,
      'Tarih': createdOn,
  //    'updatedOn': updatedOn,
      'Aciklama': aciklama,
      'Cinsi': cinsi,
      'Soru3': emniyetPini,
      'Soru5': fizikiDurum,
      'image': imageUrl,
      'Soru1': nanometreGostergesi,
      'Soru2': tetikTerkibat,
      'Soru4': tupYerinde,
     // 'qrCode': qrCode,
      'Kayit_Yapan': userEmail,
      'Kontrol': Kontrol,

    };
  }
}
