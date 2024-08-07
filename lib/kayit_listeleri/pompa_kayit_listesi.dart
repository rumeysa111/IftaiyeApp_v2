import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/pompa.dart';
import 'package:fire_appp/services/database_services_pompa.dart';
import 'package:fire_appp/kayitlar/pompa_kayit.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class PompaKayitListesi extends StatefulWidget {
  const PompaKayitListesi({super.key});

  @override
  State<PompaKayitListesi> createState() => _PompaKayitListesiState();
}

class _PompaKayitListesiState extends State<PompaKayitListesi> {
  final DatabaseServicesPompa _databaseServicesPompa = DatabaseServicesPompa();
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
        _navigateToPompa(scanData.code!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Geçersiz QR Kodu')));
      }
    });
  }
  Future<void> _navigateToPompa(String qrCode) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('Pompa_Kayit')
          .doc(qrCode);

      final docSnapshot = await docRef.get();


      if(docSnapshot.exists) {
        final pompa = Pompa.fromJson(docSnapshot.data() as Map<String, Object?>);


        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PompaKayit(
                  pompaId: docSnapshot.id,
                  pompa: pompa,
                ),
          ),
        );
      }else{
        throw Exception('Pompa kaydı bulunamadı');

      }
    } catch (e) {
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
        title: const Text('Pompa Kayıt Listesi'),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => PompaKayit()));
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
      child: StreamBuilder<QuerySnapshot<Pompa>>(
        stream: _databaseServicesPompa.getPompa(),
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
                var pompa = snapshot.data!.docs[index].data();
                return _listItem(
                  id: snapshot.data!.docs[index].id,
                  pompa: pompa,
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

  Widget _listItem({required String id, required Pompa pompa}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35.0),
      ),
      color: Colors.blue[50],
      child: ListTile(
        tileColor: Colors.blue[100],
        title: Text(pompa.adres, style: TextStyle(color: Colors.black)),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(DateTime.parse(pompa.createdOn)), style: TextStyle(color: Colors.black)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PompaKayit(pompaId: id, pompa: pompa),
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
