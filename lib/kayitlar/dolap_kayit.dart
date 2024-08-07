import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fire_appp/kayit_listeleri/dolap_kayit_listesi.dart'; // DolapKayitListesi sayfasını import ettik
import 'package:fire_appp/models/dolap.dart'; // Dolap modelini import ettik

class DolapKayit extends StatefulWidget {
  final String? dolapId;
  final Dolap? dolap;

  DolapKayit({
    this.dolapId,
    this.dolap,
  });

  @override
  State<DolapKayit> createState() => _DolapKayitState();
}

class _DolapKayitState extends State<DolapKayit> {
  final adresController = TextEditingController();
  final aciklamaController = TextEditingController();

  bool yanginDolabi = true;
  bool hortumAnahtar = true;
  bool suKacagi = true;
  bool tesisat = true;
  bool tumBaglanti = true;
  bool Kontrol=false;
 // bool Kontrol=true;


  File? _image;
  final picker = ImagePicker();

  @override
  void dispose() {
    adresController.dispose();
    aciklamaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.dolap != null) {
      adresController.text = widget.dolap!.adres;
      aciklamaController.text = widget.dolap!.aciklama;
      hortumAnahtar = widget.dolap!.hortumVeAnahtar;
      suKacagi = widget.dolap!.suKacagi;
      tesisat = widget.dolap!.tesisattaSu;
      tumBaglanti = widget.dolap!.tumBaglantilar;
      yanginDolabi = widget.dolap!.yanginDolabi;
    }
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  String generateQRCode() {
    return 'QR_${DateTime.now().microsecondsSinceEpoch}';
  }

  Future<String?> uploadImage(File image) async {
    try {
      // Extract the file name from the File object
      final fileName = image.path.split('/').last;

      // Create a reference to Firebase Storage with the file name
      final storageRef = FirebaseStorage.instance.ref().child('dolap_resimler/$fileName');

      // Upload the file
      final uploadTask = storageRef.putFile(image);
      await uploadTask.whenComplete(() => print('Upload complete'));

      // Get the download URL of the uploaded file
      final imageUrl = await storageRef.getDownloadURL();

      // Show a success message to the user

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

      String qrCode = generateQRCode();
      String? userEmail = getCurrentUserEmail(); // E-Posta adresini alın
      final createdOn = DateTime.now().toIso8601String(); // Tarihi String olarak formatlayın

      final dolapData = Dolap(
        adres: adresController.text,
        aciklama: aciklamaController.text,
        yanginDolabi: yanginDolabi,
        hortumVeAnahtar: hortumAnahtar,
        suKacagi: suKacagi,
        tesisattaSu: tesisat,
        imageUrl: imageUrl ?? '',
        userEmail: userEmail ?? '',
Kontrol:  Kontrol,
      //  qrCode: qrCode,
        tumBaglantilar: tumBaglanti,
        createdOn: widget.dolap?.createdOn ?? createdOn, // Eğer varsa mevcut tarihi kullanın, yoksa yeni tarihi ekleyin
       // updatedOn: Timestamp.now(),
      );

      if (widget.dolapId != null) {
        await FirebaseFirestore.instance.collection('Doalp_Kayit').doc(widget.dolapId).update(dolapData.toJson());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Başarıyla kayıt güncellendi!')));
      } else {
        await FirebaseFirestore.instance.collection('Doalp_Kayit').add(dolapData.toJson());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt başarıyla eklendi!')));
      }
      await Future.delayed(Duration(seconds: 1));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DolapKayitListesi()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt eklenirken/güncellenirken hata oluştu: $e')));
    }
  }
  String? getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dolapId != null ? 'Dolap Düzenle' : 'Dolap Kayıt'),
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
                      fit: BoxFit.fitHeight,
                    ),
                  )
                      : widget.dolap != null && widget.dolap!.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.dolap!.imageUrl,
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
                controller: adresController,
                decoration: InputDecoration(labelText: 'Adres'),
              ),
              TextField(
                controller: aciklamaController,
                decoration: InputDecoration(labelText: 'Açıklama'),
              ),
              SwitchListTile(
                title: Text('Yangın dolabının fiziki durumu?'),
                value: yanginDolabi,
                onChanged: (bool value) {
                  setState(() {
                    yanginDolabi = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Hortum ve anahtar var mı?'),
                value: hortumAnahtar,
                onChanged: (bool value) {
                  setState(() {
                    hortumAnahtar = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Su kaçağı var mı?'),
                value: suKacagi,
                onChanged: (bool value) {
                  setState(() {
                    suKacagi = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Tesisatta su var mı?'),
                value: tesisat,
                onChanged: (bool value) {
                  setState(() {
                    tesisat = value;
                  });
                },
                activeColor: Colors.lightBlue, // Açık mavi aktif renk
              ),
              SwitchListTile(
                title: Text('Tüm bağlantılar var mı?'),
                value: tumBaglanti,
                onChanged: (bool value) {
                  setState(() {
                    tumBaglanti = value;
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
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                style: TextButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Kamera düğmesi rengi açık mavi
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.image,color: Colors.black,),
                onPressed: () {
                  getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
                label: Text("Galeri",style: TextStyle(color: Colors.black),),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Galeri düğmesi rengi açık mavi
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
