import 'dart:io'; // Platform sınıfını kullanmak için gerekli
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_appp/models/dolap.dart';
import 'package:fire_appp/models/pompa.dart';
import 'package:fire_appp/models/tup.dart';
import 'package:fire_appp/kayitlar/pompa_kayit.dart';
import 'package:fire_appp/kayitlar/tup_kayit.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'kayitlar/dolap_kayit.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Kod Tarayıcı'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: <Widget>[
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQRViewCreated,
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              padding: EdgeInsets.all(16),
              child: Text(
                'QR Kod Tarayıcı',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      Navigator.pop(context, scanData.code);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
