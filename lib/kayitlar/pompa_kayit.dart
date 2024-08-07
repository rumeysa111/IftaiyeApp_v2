import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/pompa.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../kayit_listeleri/pompa_kayit_listesi.dart'; // Import your PompaKayitListesi page here

class PompaKayit extends StatefulWidget {
  final String? pompaId;
  final Pompa? pompa;

  PompaKayit({
    this.pompaId,
    this.pompa,
  });

  @override
  State<PompaKayit> createState() => _PompaKayitState();
}

class _PompaKayitState extends State<PompaKayit> {
  final adresController = TextEditingController();
  final dizelMotorYsController = TextEditingController();
  final dizelMotorHbController = TextEditingController();
  final elektrikliMotorController = TextEditingController();
  final notController = TextEditingController();
  final aciklamaController = TextEditingController();

  bool pompaIstasyonuGenel = true;
  bool panoUzerindeki = true;
  bool basmaEmmeHatVanalari = true;
  bool tumPompalar = true;
  bool pompaIstasyonuIsitma = true;
  bool dizelMotor = true;
  bool pompaIstasyonuServis = true;
  bool birSonrakiPeriyodik = true;
//bool Kontrol=true;
bool Kontrol=false;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.pompa != null) {
      adresController.text = widget.pompa!.adres;
      dizelMotorYsController.text = widget.pompa!.dizelMotorYs;
      dizelMotorHbController.text = widget.pompa!.dizelMotorHb;
      elektrikliMotorController.text = widget.pompa!.elektrikliMotor;
      notController.text = widget.pompa!.not;
      aciklamaController.text = widget.pompa!.aciklama;
      pompaIstasyonuGenel = widget.pompa!.pompaIstasyonuGenel;
      panoUzerindeki = widget.pompa!.panoUzerindeki;
      basmaEmmeHatVanalari = widget.pompa!.basmaEmmeHatVanalari;
      dizelMotor = widget.pompa!.dizelMotor;
      tumPompalar = widget.pompa!.tumPompalar;
      pompaIstasyonuServis = widget.pompa!.pompaIstasyonuServis;
      pompaIstasyonuIsitma = widget.pompa!.pompaIstasyonuIsitma;
      birSonrakiPeriyodik = widget.pompa!.birSonrakiPeriyodik;
    }
  }
  String? getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  @override
  void dispose() {
    adresController.dispose();
    dizelMotorYsController.dispose();
    dizelMotorHbController.dispose();
    elektrikliMotorController.dispose();
    notController.dispose();
    aciklamaController.dispose();
    super.dispose();
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected');
      }
    });
  }

  Future<String?> uploadImage(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('pompa_resimler/$fileName');
      final uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() => print('Upload complete'));
      final imageUrl = await storageRef.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  String generateQRCode() {
    return 'QR_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<void> saveData() async {
    try {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
        if (imageUrl == null) {
          throw 'Görsel yükleme başarısız oldu.';
        }
      }
      final createdOn = DateTime.now().toIso8601String(); // Tarihi String olarak formatlayın

      String qrCode = generateQRCode();
      String? userEmail = getCurrentUserEmail(); // E-Posta adresini alın


      final pompaData = Pompa(
        adres: adresController.text,
        dizelMotorYs: dizelMotorYsController.text,
        dizelMotorHb: dizelMotorHbController.text,
        elektrikliMotor: elektrikliMotorController.text,
        not: notController.text,
        aciklama: aciklamaController.text,
        pompaIstasyonuGenel: pompaIstasyonuGenel,
        panoUzerindeki: panoUzerindeki,
        basmaEmmeHatVanalari: basmaEmmeHatVanalari,
        tumPompalar: tumPompalar,
        pompaIstasyonuIsitma: pompaIstasyonuIsitma,
        dizelMotor: dizelMotor,
        pompaIstasyonuServis: pompaIstasyonuServis,
        imageUrl: imageUrl ?? '',
        createdOn: widget.pompa?.createdOn ?? createdOn, // Eğer varsa mevcut tarihi kullanın, yoksa yeni tarihi ekleyin
       // qrCode: qrCode,
       // updatedOn: Timestamp.now(),
        birSonrakiPeriyodik: birSonrakiPeriyodik,
        userEmail: userEmail ?? '',  // E-Posta adresini ekleyin
        Kontrol: Kontrol,

      );

      if (widget.pompaId != null) {
        await FirebaseFirestore.instance.collection('Pompa_Kayit').doc(widget.pompaId).update(pompaData.toJson());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Başarıyla kayıt güncellendi!')));
      } else {
        await FirebaseFirestore.instance.collection('Pompa_Kayit').add(pompaData.toJson());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt başarıyla eklendi!')));
      }
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PompaKayitListesi()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt eklenirken/güncellenirken hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pompaId != null ? 'Pompa Düzenle' : 'Pompa Kayıt'),
        backgroundColor: Colors.lightBlue, // AppBar arka plan rengi açık mavi
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => bottomSheet(),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.lightBlue, // Profil resmi arka plan rengi açık mavi
                  child: _image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      _image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : widget.pompa != null && widget.pompa!.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.pompa!.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: Colors.lightBlue, // Varsayılan arka plan rengi açık mavi
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: 100,
                    height: 100,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: adresController,
                decoration: InputDecoration(labelText: 'Adres'),
              ),
              TextField(
                controller: dizelMotorYsController,
                decoration: InputDecoration(labelText: 'Dizel Motor Y/S'),
              ),
              TextField(
                controller: dizelMotorHbController,
                decoration: InputDecoration(labelText: 'Dizel Motor H/B'),
              ),
              TextField(
                controller: elektrikliMotorController,
                decoration: InputDecoration(labelText: 'Elektrikli Motor H/B'),
              ),
              TextField(
                controller: notController,
                decoration: InputDecoration(labelText: 'Not'),
              ),
              TextField(
                controller: aciklamaController,
                decoration: InputDecoration(labelText: 'Açıklama'),
              ),
              SwitchListTile(
                title: Text('Pompa istasyonu genel durumu ?'),
                value: pompaIstasyonuGenel,
                onChanged: (bool value) {
                  setState(() {
                    pompaIstasyonuGenel = value;
                  });
                },
                activeColor: Colors.lightBlue, // Switch aktif rengi açık mavi
              ),
              SwitchListTile(
                title: Text('Pano üzerindeki lambalar doğru konumda mı ?'),
                value: panoUzerindeki,
                onChanged: (bool value) {
                  setState(() {
                    panoUzerindeki = value;
                  });
                },
                activeColor: Colors.lightBlue,
              ),
              SwitchListTile(
                title: Text('Basma ve emme hat vanaları açık mı?'),
                value: basmaEmmeHatVanalari,
                onChanged: (bool value) {
                  setState(() {
                    basmaEmmeHatVanalari = value;
                  });
                },
                activeColor: Colors.lightBlue,
              ),
              SwitchListTile(
                title: Text('Tüm pompalar otomatik açılacak konumda mı?'),
                value: tumPompalar,
                onChanged: (bool value) {
                  setState(() {
                    tumPompalar = value;
                  });
                },
                activeColor: Colors.lightBlue,
              ),
              SwitchListTile(
                title: Text('Pompa istasyonu ısıtma sistemi var mı?'),
                value: pompaIstasyonuIsitma,
                onChanged: (bool value) {
                  setState(() {
                    pompaIstasyonuIsitma = value;
                  });
                },
                activeColor: Colors.lightBlue,
              ),
              SwitchListTile(
                title: Text('Dizel motor, yağ ve su seviyeleri uygun mu?'),
                value: dizelMotor,
                onChanged: (bool value) {
                  setState(() {
                    dizelMotor = value;
                  });
                },
                activeColor: Colors.lightBlue,
              ),
              SwitchListTile(
                title: Text('Pompa istasyonu servis bakımı gerekli mi ?'),
                value: pompaIstasyonuServis,
                onChanged: (bool value) {
                  setState(() {
                    pompaIstasyonuServis = value;
                  });
                },
                activeColor: Colors.lightBlue,
              ),
              SwitchListTile(
                title: Text('Bir sonraki periyodik kontrol tarihi ?'),
                value: birSonrakiPeriyodik,
                onChanged: (bool value) {
                  setState(() {
                    birSonrakiPeriyodik = value;
                  });
                },
                activeColor: Colors.lightBlue,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Buton arka plan rengi açık mavi
                ),
                child: Text('Kaydet',style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            'Bir resim seç',
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.camera,color: Colors.black,),
                onPressed: () {
                  getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
                label: Text("Kamera",style: TextStyle(color: Colors.black),),
              ),
              SizedBox(width: 20),
              TextButton.icon(
                icon: Icon(Icons.image,color: Colors.black,),
                onPressed: () {
                  getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                label: Text("Galeri",style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
