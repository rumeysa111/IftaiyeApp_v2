import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fire_appp/login_screen.dart'; // Giriş ekranı importunu ekleyin

class AyarlarSayfasi extends StatefulWidget {
  @override
  _AyarlarSayfasiState createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Çıkış yapıldıktan sonra giriş ekranına yönlendirme
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()), // Giriş ekranı widget'ınızı buraya ekleyin
            (Route<dynamic> route) => false, // Tüm önceki ekranları kapatır
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Çıkış yaparken bir hata oluştu')));
    }
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Şifre Değiştir'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Mevcut Şifre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mevcut şifrenizi girin';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Yeni Şifre'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Yeni şifrenizi girin';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  _updatePassword(
                    currentPasswordController.text,
                    newPasswordController.text,
                  );
                  Navigator.of(context).pop();
                }
              },
              child: Text('Güncelle'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şifre başarıyla güncellendi')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şifre güncellenirken bir hata oluştu')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
        backgroundColor: Colors.blue, // Mavi arka plan
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profilim kısmı
            Text(
              'Profilim',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blue), // Mavi başlık
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('E-posta'),
              subtitle: Text(_user?.email ?? 'E-posta bilgisi yok'),
              tileColor: Colors.lightBlue[50], // Çok açık mavi arka plan rengi
            ),
            SizedBox(height: 8),
            ListTile(
              title: Text('Şifre'),
              subtitle: Text('•••••••••••••'), // Şifreyi göstermek yerine placeholder kullanabilirsiniz
              tileColor: Colors.lightBlue[50], // Çok açık mavi arka plan rengi
            ),
            SizedBox(height: 32),
            // Şifre Yenile kısmı
            Center(
              child: ElevatedButton(
                onPressed: _changePassword,
                child: Text(
                  'Şifreyi Yenile',
                  style: TextStyle(
                    color: Colors.white, // Beyaz yazı rengi
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Mavi buton rengi
                ),
              ),
            ),
            SizedBox(height: 32),
            // Çıkış Yap butonu
            Center(
              child: ElevatedButton(
                onPressed: _signOut,
                child: Text('Çıkış Yap', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Mavi buton rengi
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
