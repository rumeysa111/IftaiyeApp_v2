import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/dolap.dart';
import 'package:fire_appp/models/pompa.dart';
import 'package:fire_appp/models/tup.dart';
import 'package:flutter/material.dart';
import 'package:fire_appp/ayarlar.dart';
import 'package:fire_appp/kayitlar/dolap_kayit.dart';
import 'package:fire_appp/kayit_listeleri/dolap_kayit_listesi.dart';
import 'package:fire_appp/login_screen.dart';
import 'package:fire_appp/kayitlar/pompa_kayit.dart';
import 'package:fire_appp/kayit_listeleri/pompa_kayit_listesi.dart';
import 'package:fire_appp/kayitlar/tup_kayit.dart';
import 'package:fire_appp/kayit_listeleri/tup_kayit_listesi.dart';
import 'package:fire_appp/qr_screen.dart';
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İtfaiye Yönetim Sistemi'),
        backgroundColor: Colors.blueAccent, // Blue shade for the AppBar
      ),
      backgroundColor: Colors.lightBlue[50], // Light blue background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // Horizontal padding for margins
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the children
            children: <Widget>[
              _buildCard(
                context,
                title: 'Tüp Kayıt',
                iconPath: 'assets/icon/yangın_tupu.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TupKayitListesi()),
                  );
                },
              ),
              SizedBox(height: 16), // Space between cards
              _buildCard(
                context,
                title: 'Pompa Kayıt',
                iconPath: 'assets/icon/pompa.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PompaKayitListesi()),
                  );
                },
              ),
              SizedBox(height: 16), // Space between cards
              _buildCard(
                context,
                title: 'Dolap Kayıt',
                iconPath: 'assets/icon/cabinet.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DolapKayitListesi()),
                  );
                },
              ),
              SizedBox(height: 16), // Space between cards
              _buildCard(
                context,
                title: 'Ayarlar',
                iconPath: 'assets/icon/setting.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AyarlarSayfasi()),
                  );
                },
              ),
              SizedBox(height: 20), // Space before buttons
              SizedBox(height: 16), // Space before QR button
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRCodeScreen()),
                  );
                  if (result != null) {
                    _handleScanResult(context, result);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, color: Colors.black), // QR code icon
                    SizedBox(width: 8), // Space between icon and text
                    Text('QR Kod ile arama yap', style: TextStyle(color: Colors.black, fontSize: 20)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue color for the button
                  minimumSize: Size(double.infinity, 48), // Full width button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required VoidCallback onTap,
        required String iconPath,
      }) {
    const double iconSize = 54.0; // Icon height

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        color: Colors.blue[100], // Light blue color for the card
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            padding: const EdgeInsets.all(10.0), // Increased padding
            alignment: Alignment.center,
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8, // Center the card
              minHeight: 100, // Minimum height of the card
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
              children: [
                Image.asset(
                  iconPath,
                  width: iconSize, // Set icon width
                  height: iconSize, // Set icon height
                ),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 24, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleScanResult(BuildContext context, String id) async {
    try {
      final tupRef = FirebaseFirestore.instance.collection('Tup_Kayit').doc(id);
      final pompaRef = FirebaseFirestore.instance.collection('Pompa_Kayit').doc(id);
      final dolapRef = FirebaseFirestore.instance.collection('Dolap_Kayit').doc(id);

      final tupSnapshot = await tupRef.get();
      if (tupSnapshot.exists) {
        final tup = Tup.fromJson(tupSnapshot.data() as Map<String, Object?>);
        _navigateToTup(context, id, tup);
        return;
      }

      final pompaSnapshot = await pompaRef.get();
      if (pompaSnapshot.exists) {
        final pompa = Pompa.fromJson(pompaSnapshot.data() as Map<String, Object?>);
        _navigateToPompa(context, id, pompa);
        return;
      }

      final dolapSnapshot = await dolapRef.get();
      if (dolapSnapshot.exists) {
        final dolap = Dolap.fromJson(dolapSnapshot.data() as Map<String, Object?>);
        _navigateToDolap(context, id, dolap);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kayıt bulunamadı')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  void _navigateToTup(BuildContext context, String id, Tup tup) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TupKayit(tupId: id, tup: tup)));
  }

  void _navigateToPompa(BuildContext context, String id, Pompa pompa) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PompaKayit(pompaId: id, pompa: pompa)));
  }

  void _navigateToDolap(BuildContext context, String id, Dolap dolap) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => DolapKayit(dolapId: id, dolap: dolap)));
  }
}
