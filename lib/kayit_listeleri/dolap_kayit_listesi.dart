import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/kayitlar/dolap_kayit.dart';
import 'package:fire_appp/services/database_services_dolap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/dolap.dart';

class DolapKayitListesi extends StatefulWidget {
  const DolapKayitListesi({super.key});

  @override
  State<DolapKayitListesi> createState() => _DolapKayitListesiState();
}

class _DolapKayitListesiState extends State<DolapKayitListesi> {
  final DatabaseServicesDolap _databaseServicesDolap = DatabaseServicesDolap();
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
        _navigateToDolap(scanData.code!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Geçersiz QR Kodu')));
      }
    });
  }
  Future<void> _navigateToDolap(String qrCode) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('Doalp_Kayit')
          .doc(qrCode); // Use qrCode directly as the document ID

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final dolap = Dolap.fromJson(docSnapshot.data() as Map<String, Object?>);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DolapKayit(
              dolapId: docSnapshot.id,
              dolap: dolap,
            ),
          ),
        );
      } else {
        throw Exception('Dolap kaydı bulunamadı');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    }
  }

/*
  Future<void> _navigateToDolap(String qrCode) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Doalp_Kayit')
          .get();

      final doc = querySnapshot.docs.firstWhere(
            (doc) => DateFormat('yyyyMMddHHmmss').format(DateTime.parse(doc['Tarih'])) == qrCode,
        orElse: () => throw Exception('Dolap kaydı bulunamadı'),
      );


      final dolapId = doc.id;
      final dolap = Dolap.fromJson(doc.data() as Map<String, Object?>);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DolapKayit(
            dolapId: dolapId,
            dolap: dolap,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    }
  }
*/
  /*void _printQrCode( DateTime timestamp) async {
    final dateTimeString = DateFormat('yyyyMMddHHmmss').format(timestamp);

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
                data: dateTimeString,
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
*/
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
      resizeToAvoidBottomInset: false,
      appBar: _appBar(),
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DolapKayit()),
          );
        },
        backgroundColor: Colors.blue,
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: Colors.blue[400],
      title: const Text(
        "Dolap Kayıt Listesi",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.qr_code_scanner),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
            );
          },
        ),
      ],
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
      child: StreamBuilder<QuerySnapshot<Dolap>>(
        stream: _databaseServicesDolap.getDolap(),
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
                var dolap = snapshot.data!.docs[index].data();
                return _listItem(
                  id: snapshot.data!.docs[index].id,
                  dolap: dolap,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Bir hata oluştu: ${snapshot.error}"));
          } else {
            return const Center(child: Text("Hiç kayıt yok!"));
          }
        },
      ),
    );
  }

 /* Widget _listItem({required String id, required Dolap dolap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0),
      ),
      color: Colors.blue[50],
      child: ListTile(
        tileColor: Colors.blue[100],
        title: Text(dolap.adres, style: TextStyle(color: Colors.black)),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(dolap.createdOn)), style: TextStyle(color: Colors.black)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DolapKayit(dolapId: id, dolap: dolap),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.print, color: Colors.black),
              onPressed: () {
                _printQrCode(DateTime.parse(dolap.createdOn));
              },
            ),
          ],
        ),
      ),
    );
  }
  */
  Widget _listItem({required String id, required Dolap dolap}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0),
      ),
      color: Colors.blue[50],
      child: ListTile(
        tileColor: Colors.blue[100],
        title: Text(dolap.adres, style: TextStyle(color: Colors.black)),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(dolap.createdOn)), style: TextStyle(color: Colors.black)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DolapKayit(dolapId: id, dolap: dolap),
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
