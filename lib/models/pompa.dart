import 'package:cloud_firestore/cloud_firestore.dart';

class Pompa {
  final String adres;
  final String aciklama;
  final bool basmaEmmeHatVanalari;
  final bool birSonrakiPeriyodik;
final bool pompaIstasyonuServis;
  final String imageUrl;

  final bool tumPompalar;
  final bool pompaIstasyonuIsitma;
  final bool pompaIstasyonuGenel;
  final bool panoUzerindeki;
  final String not;
  final String elektrikliMotor;
  final String dizelMotorYs;
  final  String dizelMotorHb;
  final String createdOn;
  //final Timestamp updatedOn;
  final bool dizelMotor;
  //final String qrCode;
  final String userEmail;
  final bool Kontrol;



  Pompa({
    required this.pompaIstasyonuServis,
    required this.imageUrl,
   // required this.qrCode,

    required this.adres,
required this.dizelMotor,
    required this.aciklama,
    required this.basmaEmmeHatVanalari,
    required this.birSonrakiPeriyodik,
    required  this.tumPompalar,
    required this.pompaIstasyonuIsitma,
    required this.pompaIstasyonuGenel,
    required this.panoUzerindeki,
    required this.not,
    required this.elektrikliMotor,
    required this.dizelMotorYs,
    required this.dizelMotorHb,
    required this.createdOn,
    //required  this.updatedOn,
    required this.userEmail,
    required this.Kontrol,
  });

  factory Pompa.fromJson(Map<String, Object?> json) {
    return Pompa(
      adres: json['Adres'] as String,
      aciklama: json['Aciklama'] as String,
      basmaEmmeHatVanalari: json['Soru3'] as bool,
      birSonrakiPeriyodik: json['Soru8'] as bool,

      imageUrl: json['image'] as String,
   //   qrCode: json['qrCode'] as String,
Kontrol: json['Kontrol'] as bool,
      tumPompalar: json['Soru4'] as bool,
      pompaIstasyonuIsitma: json['Soru5'] as bool,
      pompaIstasyonuGenel: json['Soru1'] as bool,
      pompaIstasyonuServis:  json['Soru7'] as bool,
      panoUzerindeki: json['Soru2'] as bool,
      not: json['Not'] as String,
      dizelMotor: json['Soru6'] as bool,
      elektrikliMotor: json['Elektrik_Hatbasinci'] as String,
      dizelMotorYs: json['Yakit_Seviyesi'] as String,
      dizelMotorHb: json['Dizel_Hatbasinci'] as String,
      createdOn: json['Tarih'] as String,
   //   updatedOn: json['updatedOn'] != null
     //     ? json['updatedOn'] as Timestamp
       //   : Timestamp.now(),
      userEmail: json['Kayit_Yapan']  as String,

    );
  }


  Pompa copyWith({

    String? imageUrl,
String? userEmail,
    String? adres,
    String? aciklama,
    bool? basmaEmmeHatVanalari,
    bool? birSonrakiPeriyodik,
    bool? tumPompalar,
    bool? pompaIstasyonuIsitma,
    bool? pompaIstasyonuServis,
    bool? pompaIstasyonuGenel,
    bool? panoUzerindeki,
    String? not,
    String? elektrikliMotor,
    String? dizelMotorYs,
    String? dizelMotorHb,
    String? createdOn,
  //  Timestamp? updatedOn,
    bool? dizelMotor,
   // String? qrCode,
    bool? Kontrol,

  }) {
    return Pompa(
      pompaIstasyonuServis: pompaIstasyonuServis ?? this.pompaIstasyonuServis,
      adres: adres ?? this.adres,
      aciklama: aciklama ?? this.aciklama,
      imageUrl: imageUrl ?? this.imageUrl,

      basmaEmmeHatVanalari: basmaEmmeHatVanalari ?? this.basmaEmmeHatVanalari,
      birSonrakiPeriyodik: birSonrakiPeriyodik ?? this.birSonrakiPeriyodik,
      tumPompalar: tumPompalar ?? this.tumPompalar,
      pompaIstasyonuIsitma: pompaIstasyonuIsitma ?? this.pompaIstasyonuIsitma,
      pompaIstasyonuGenel: pompaIstasyonuGenel ?? this.pompaIstasyonuGenel,
      panoUzerindeki: panoUzerindeki ?? this.panoUzerindeki,
      not: not ?? this.not,
      elektrikliMotor: elektrikliMotor ?? this.elektrikliMotor,
      dizelMotorYs: dizelMotorYs ?? this.dizelMotorYs,
      dizelMotorHb: dizelMotorHb ?? this.dizelMotorHb,
      createdOn: createdOn ?? this.createdOn,
     // updatedOn: updatedOn ?? this.updatedOn,
      dizelMotor:  dizelMotor ?? this.dizelMotor,
     // qrCode: qrCode ?? this.qrCode,
      userEmail: userEmail ?? this.userEmail,  // Yeni alan
Kontrol: Kontrol ?? this.Kontrol,
    );
  }

  Map<String, Object?> toJson() {
    return {

      'Adres': adres,
      'Aciklama': aciklama,
      'Soru3': basmaEmmeHatVanalari,
      'Soru8': birSonrakiPeriyodik,
      'Soru4': tumPompalar,
      'Soru5': pompaIstasyonuIsitma,
      'Soru1': pompaIstasyonuGenel,
      'Soru2': panoUzerindeki,
      'Not': not,
      'image': imageUrl,
      'Soru6': dizelMotor,
      'Soru7':pompaIstasyonuServis,
      //'qrCode': qrCode,

      'Elektrik_Hatbasinci': elektrikliMotor,
      'Yakit_Seviyesi': dizelMotorYs,
      'Dizel_Hatbasinci': dizelMotorHb,
      'Tarih': createdOn,
      //'updatedOn': updatedOn,
      'Kayit_Yapan': userEmail,  // Yeni alan
      'Kontrol':Kontrol,

    };
  }
}
