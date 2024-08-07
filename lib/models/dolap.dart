import 'package:cloud_firestore/cloud_firestore.dart';

class Dolap {
  final String adres;
  final String aciklama;
  final bool hortumVeAnahtar;
  final bool yanginDolabi;
  final bool tumBaglantilar;
  final bool tesisattaSu;
  final bool suKacagi;
  final String createdOn;
  //final Timestamp updatedOn;
  final String imageUrl;
  //final String qrCode;
  final String userEmail;
  final bool Kontrol;


  Dolap({
    required this.userEmail,

    required this.adres,
    required this.aciklama,
    required this.hortumVeAnahtar,
    required this.yanginDolabi,
    required this.tumBaglantilar,
    required this.tesisattaSu,
    required this.suKacagi,
    required this.createdOn,
    //required this.updatedOn,
    required this.imageUrl,
    //required this.qrCode,
    required this.Kontrol,
  });

  factory Dolap.fromJson(Map<String, Object?> json) {
    return Dolap(
      adres: json['Adres'] as String,
     // qrCode: json['qrCode'] as String,

      aciklama: json['Aciklama'] as String,
      hortumVeAnahtar: json['Soru2'] as bool,
      yanginDolabi: json['Soru1'] as bool,
      tumBaglantilar: json['Soru5'] as bool,
      tesisattaSu: json['Soru4'] as bool,
      suKacagi: json['Soru3'] as bool,
      createdOn: json['Tarih'] as String
         ,
      //updatedOn: json['updatedOn'] != null
        //  ? json['updatedOn'] as Timestamp
      //    : Timestamp.now(),
      imageUrl: json['image'] as String,
      userEmail: json['Kayit_Yapan'] as String,  // Yeni alan
      Kontrol: json['Kontrol'] as bool,


    );
  }

  Dolap copyWith({
    String? adres,
    String? aciklama,
    bool? hortumVeAnahtar,
    bool? yanginDolabi,
    bool? tumBaglantilar,
    bool? tesisattaSu,
    bool? suKacagi,
    String? createdOn,
    //Timestamp? updatedOn,
    String? imageUrl,
    String? qrCode,
    String? userEmail,
   bool? Kontrol,


  }) {
    return Dolap(
      adres: adres ?? this.adres,
      aciklama: aciklama ?? this.aciklama,
      hortumVeAnahtar: hortumVeAnahtar ?? this.hortumVeAnahtar,
      yanginDolabi: yanginDolabi ?? this.yanginDolabi,
      tumBaglantilar: tumBaglantilar ?? this.tumBaglantilar,
      tesisattaSu: tesisattaSu ?? this.tesisattaSu,
      suKacagi: suKacagi ?? this.suKacagi,
      createdOn: createdOn ?? this.createdOn,
    //  updatedOn: updatedOn ?? this.updatedOn,
      imageUrl: imageUrl ?? this.imageUrl,
    //  qrCode: qrCode ?? this.qrCode,
      userEmail: userEmail ?? this.userEmail,  // Yeni alan
      Kontrol: Kontrol ?? this.Kontrol,

    );
  }

  Map<String, Object?> toJson() {
    return {
      'Adres': adres,
      'Aciklama': aciklama,
      'Soru2': hortumVeAnahtar,
      'Soru1': yanginDolabi,
      'Soru5': tumBaglantilar,
      'Soru4': tesisattaSu,
      'Soru3': suKacagi,
      'Tarih': createdOn,
      //'updatedOn': updatedOn,
      'image': imageUrl,
      //'qrCode': qrCode,
      'Kayit_Yapan':userEmail,
      'Kontrol': Kontrol,
    };
  }
}
