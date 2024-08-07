import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/tup.dart';
import 'package:fire_appp/kayit_listeleri/tup_kayit_listesi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // Pdf generator dosyasını import edin

class TupKayit extends StatefulWidget {
  final String? tupId;
  final Tup? tup;

  TupKayit({
    this.tupId,
    this.tup,
  });

  @override
  _TupKayitState createState() => _TupKayitState();
}

String? getCurrentUserEmail() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.email;
}


class _TupKayitState extends State<TupKayit> {
  final cinsiController = TextEditingController();
  final adresController = TextEditingController();
  final aciklamaController = TextEditingController();

  bool nanometreGostergesi = true;
  bool tetikTerkibat = true;
  bool emniyetPini = true;
  bool tupYerinde = true;
  bool fizikiDurum = true;
  bool Konrol=false;
//  bool Konrol=true;

late DateTime createdOn;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.tup != null) {
      cinsiController.text = widget.tup!.cinsi ?? '';
      adresController.text = widget.tup!.adres ?? '';
      aciklamaController.text = widget.tup!.aciklama ?? '';
      nanometreGostergesi = widget.tup!.nanometreGostergesi ?? true;
      tetikTerkibat = widget.tup!.tetikTerkibat ?? true;
      emniyetPini = widget.tup!.emniyetPini ?? true;
      tupYerinde = widget.tup!.tupYerinde ?? true;
      fizikiDurum = widget.tup!.fizikiDurum ?? true;

      // Görsel URL'sini `_image` ile doldurmak için gerekli kodu eklemelisiniz.
    }
  }

  @override
  void dispose() {
    cinsiController.dispose();
    adresController.dispose();
    aciklamaController.dispose();
    super.dispose();
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  String generateQRCode() {
    return 'QR_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<String?> uploadImage(File image) async {
    try {
      final fileName = image.path.split('/').last;
      final storageRef = FirebaseStorage.instance.ref().child('tup_resimler/$fileName');
      final uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() => print('Upload complete'));
      final imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
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

      final tupData = Tup(
        cinsi: cinsiController.text,
        adres: adresController.text,
        aciklama: aciklamaController.text,
        nanometreGostergesi: nanometreGostergesi,
        tetikTerkibat: tetikTerkibat,
        emniyetPini: emniyetPini,
        tupYerinde: tupYerinde,
        fizikiDurum: fizikiDurum,
        imageUrl: imageUrl ?? '',
        createdOn: widget.tup?.createdOn ?? createdOn, // Eğer varsa mevcut tarihi kullanın, yoksa yeni tarihi ekleyin
        //qrCode: qrCode,
        userEmail: userEmail ?? '',
      //  updatedOn: Timestamp.now(),
        Kontrol:  Konrol,
      );
      if (widget.tupId != null) {
        await FirebaseFirestore.instance.collection('Tup_Kayit').doc(widget.tupId).update(tupData.toJson());
        print('Data updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Başarıyla kayıt güncellendi!')));
      } else {
        await FirebaseFirestore.instance.collection('Tup_Kayit').add(tupData.toJson());
        print('Data saved successfully');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt başarıyla eklendi!')));
      }
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TupKayitListesi()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt eklenirken/güncellenirken hata oluştu: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tupId != null ? 'Tüp Düzenle' : 'Tüp Kayıt'),
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
                  builder: (builder) => bottomSheet(),
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
                      fit: BoxFit.fitHeight,
                    ),
                  )
                      : widget.tup != null && widget.tup!.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.tup!.imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.fitHeight,
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
                controller: cinsiController,
                decoration: InputDecoration(labelText: 'Cinsi'),
              ),
              TextField(
                controller: adresController,
                decoration: InputDecoration(labelText: 'Adres'),
              ),
              TextField(
                controller: aciklamaController,
                decoration: InputDecoration(labelText: 'Açıklama'),
              ),
              SwitchListTile(
                title: Text('Nanometre göstergesi yeşil mi?'),
                value: nanometreGostergesi,
                onChanged: (bool value) {
                  setState(() {
                    nanometreGostergesi = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Tetik terkibat yerinde mi?'),
                value: tetikTerkibat,
                onChanged: (bool value) {
                  setState(() {
                    tetikTerkibat = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Emniyet pimi yerinde mi?'),
                value: emniyetPini,
                onChanged: (bool value) {
                  setState(() {
                    emniyetPini = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Tüp yerinde mi?'),
                value: tupYerinde,
                onChanged: (bool value) {
                  setState(() {
                    tupYerinde = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Tüpün fiziki durumu?'),
                value: fizikiDurum,
                onChanged: (bool value) {
                  setState(() {
                    fizikiDurum = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveData,
                child: Text('Kaydet',style: TextStyle(color: Colors.black),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Kaydet düğmesi arka plan rengi açık mavi
                ),
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
            "Bir resim seç",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
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
              TextButton.icon(
                icon: Icon(Icons.image,color: Colors.black,),
                onPressed: () {
                  getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                label: Text("Galeri",style: TextStyle(color: Colors.black),),
              ),
            ],
          )
        ],
      ),
    );
  }
}
