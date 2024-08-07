import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/tup.dart';
import 'package:fire_appp/services/database_services_tup.dart';
import 'package:fire_appp/kayitlar/tup_kayit.dart';

class TupKayitListesi extends StatefulWidget {
  const TupKayitListesi({super.key});

  @override
  State<TupKayitListesi> createState() => _TupKayitListesiState();
}

class _TupKayitListesiState extends State<TupKayitListesi> {
  final DatabaseServicesTup _databaseServicesTup = DatabaseServicesTup();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        _navigateToTup(scanData.code!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Geçersiz QR Kodu')));
      }
    });
  }

  Future<void> _navigateToTup(String qrCode) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('Tup_Kayit')
          .doc(qrCode); // Use qrCode directly as the document ID

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final tup = Tup.fromJson(docSnapshot.data() as Map<String, Object?>);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TupKayit(
                  tupId: docSnapshot.id,
                  tup: tup,
                ),
          ),
        );
      }
      else {
        throw Exception('Tüp kaydı bulunamadı');
      }
    }catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    }
  }




  void _printQrCode(String docId) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              height: 200,
              width: 200,
              child: pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: docId,
                width: 200,
                height: 200,
              ),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tüp Kayıt Listesi'),
        backgroundColor: Colors.blue[400],
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                )),
              );
            },
          ),
        ],
      ),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TupKayit()));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(child: _messagesListView()),
        ],
      ),
    );
  }

  Widget _messagesListView() {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: MediaQuery.sizeOf(context).width,
      child: StreamBuilder<QuerySnapshot<Tup>>(
        stream: _databaseServicesTup.getTup(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var tup = snapshot.data!.docs[index].data();
                return _listItem(
                  id: snapshot.data!.docs[index].id,
                  tup: tup,
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Bir hata oluştu!"));
          } else {
            return const Center(child: Text("Hiç kayıt yok!"));
          }
        },
      ),
    );
  }

  Widget _listItem({required String id, required Tup tup}) {


    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0),
      ),
      color: Colors.blue[50],
      child: ListTile(
        tileColor: Colors.blue[100],
        title: Text(tup.adres, style: TextStyle(color: Colors.black)),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(tup.createdOn)), style: TextStyle(color: Colors.black)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TupKayit(tupId: id, tup: tup),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.print, color: Colors.black),
              onPressed: () {
                _printQrCode(id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
