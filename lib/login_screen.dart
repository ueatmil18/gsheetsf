import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();
  bool _isLoading = false;

  // Configuración de Google Sheets
  final _credentials = r'''{"type": "service_account",
  "project_id": "asiscom25",
  "private_key_id": "e6521cf53c96f3dcefa2c5189626ae2264acecc7",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQChBa18g6cFUbGt\nkV7+g0X/7Y6Fryx44PKlYk6boBcd4h7QX8s9HIGbazvIiRSBYLXa/Zu21k+pzrID\necIrSHhUD01mHyHn6xw9J3fU0s7TjwADEgBRONI4x2X3p6IBEnfXiayb2Pl4sGqX\ntFjlW44YwjTKTPA2OseZHF+POJvsMJqxBOeZzK+evWRV5JxqNXRFoXREdOuLOVZO\nFdICuBnRzvooX1LEftUKsvTDAEe+xuUcTkERnpkBLgIlzD7K+l2qspeuQirM2Go1\noSbo324XsH4X0frtttBlmTUZO4YklMZfQTKRxUQcgwVGE/24L3kxXXsHZEUk9H9G\nXCgK5W4nAgMBAAECggEAQAxWGXT0dnUsS3HLa0kkCsyfKCWpdttjKM2VnulqyIQs\n5Y109fXkx8E7omSEN4IUU+sUiQFt5olE3YUM6tKEqkr76mbvwaQPM3QDgi/n/Nag\nlpgOcEA9vj/yGzQeiHakHKOyeLsxYAQsIfOmeHSWbNqyzNUVpzxyMEDM8db+jk+U\nsge3hrqzNXCaDUHp20TppVCZeD80KSVxSY2kUGzT73LFU/qELd/Xo/xBRYr41OiE\nNAF2N1AVJQwE4gV4TmbQSwKWBqsheKXty3Ea21vPDRjaQVg/GTSBI+Zxrdd2R09p\nMaGIxKPzmpnpwUgEwATDqYDQjaQYHRWbKaKoYee0gQKBgQDfqSCwhojqc2RrLduC\nO4W2XlPGlGoUP36rGoUVQj7NFWfIoD1vZoszuSeSIoXM0DEsDYG+0MNic/ODkLws\noCDg0rnynjQl1lBVNRmR9Ul4EhqqvDshMDwPRLET9EGrdAhzfrTd9QiVebohPQIi\nqBbvFyKiO9SUiTEQWyM3fpRc8QKBgQC4TfdekZzXq3KXDSC4KZeJAhxkQvMwdlWS\nlOCKLP+Z1/PQorpM39E+XoIuUzVmO0oECrJ7fT/POq+TJVx9msWz0gLtLAMY/7q7\nTt5VO1PdgEN1N4EBZo14BV/OS9CHTmfJYV2t6vq+wXLwQo+dyGQ9IIKiSX4dF+qi\nWKTTv7xclwKBgQCoZe72+lScMcWp7R0ZMTe718m7+oLkO+pjadRJ7VbbkwJRTFT1\nS4ADsaTZoqSbUSW0xXaq9QQnXKY8qP0FnIsku4TF59fbpUFW5mQaQVTP0tHBO3hJ\nxMdzt4ScQYwwS20RiJUliRitcrlxzT2OWoDqA8FP5TxpmeIXLoeVgPi0AQKBgFj/\nlUd+a02eBey5MyabNwi7Ezi7N7IcQoBREgjHZ/pDVQJXwjzjC6jhfF2gYrXmRXyk\nKcIGHm0UerpEnWAt//AwpqcezLQisWpH0Ic56eqZSHnu/oXNntzpQ3VcGOttyiJt\nuQ4F3WWGBtnMWounu/fknhB+Cr9D0FLrGVUDTpMrAoGAKUv8a0HfkYtvoeQ79MEO\nmBQw/az2AMfF7eiNZiXIDc//fPeGbzAIEEXIfwPSdAeaUamc4h7Rasvkl5TUY1cl\nMzt5Ig63rCx8xfTHi0XOHocWm6sVd6NnWVedlHSFEcF5Q3vjBPYCgSGMFY3k/Q1w\nj1TBeHsBC8uWnxUwp6n47OU=\n-----END PRIVATE KEY-----\n",
  "client_email": "asiscom25@asiscom25.iam.gserviceaccount.com",
  "client_id": "107084469317363780749",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/asiscom25%40asiscom25.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"}''';

  // PRUEBAS
  final _spreadsheetId = '15RArKo4aBsbWbcDE3zTrLsTn8LLy3gRrV-d18vjkOJA';

  // PRODUCCION
  //final _spreadsheetId = '1QuAeSmmm7mpO4TG7ALD4kmsxQbmlR_BYcSoHwGlwlBU';

  @override
  void dispose() {
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _verificarCredenciales() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final gsheets = GSheets(_credentials);
      final spreadsheet = await gsheets.spreadsheet(_spreadsheetId);
      final sheet = await _getOrCreateWorksheet(spreadsheet, 'USUARIOS');

      final usuario = _usuarioController.text.trim();
      final clave = _claveController.text.trim();

      final authResult = await _verificarYActualizarSheets(sheet, usuario, clave);

      if (authResult['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(username: usuario),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authResult['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚨 Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>> _verificarYActualizarSheets(
      Worksheet sheet, String usuario, String clave) async {
    final records = await sheet.values.allRows();
    if (records == null) {
      return {
        'success': false,
        'message': 'No se encontraron registros en la hoja'
      };
    }

    for (int i = 0; i < records.length; i++) {
      final row = records[i];
      if (row.length >= 3) {
        final user = row[1]?.toString().trim() ?? '';
        final pass = row[2]?.toString().trim() ?? '';

        if (user == usuario && pass == clave) {
          await _actualizarFechaAcceso(sheet, i + 1);
          return {
            'success': true,
            'message': '🎉 ¡Bienvenido $usuario!'
          };
        }
      }
    }

    return {
      'success': false,
      'message': '❌ Usuario o clave incorrectos'
    };
  }

  Future<void> _actualizarFechaAcceso(Worksheet sheet, int rowNumber) async {
    try {
      final headers = await sheet.values.row(1);
      int modfchIndex = headers.indexWhere(
          (header) => header?.toString().trim().toUpperCase() == 'MODFCH');

      if (modfchIndex == -1) {
        modfchIndex = headers.length;
        await sheet.values.insertValue(
          'MODFCH',
          column: modfchIndex + 1,
          row: 1,
        );
      }

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      await sheet.values.insertValue(
        formattedDate,
        column: modfchIndex + 1,
        row: rowNumber,
      );
    } catch (e) {
      print('Error al actualizar fecha de acceso: $e');
    }
  }

  Future<Worksheet> _getOrCreateWorksheet(
      Spreadsheet spreadsheet, String title) async {
    try {
      var sheet = spreadsheet.worksheetByTitle(title);
      if (sheet == null) {
        sheet = await spreadsheet.addWorksheet(title);
        await sheet.values.insertRow(1, ['ID', 'USUARIO', 'CLAVE']);
      }
      return sheet;
    } catch (e) {
      throw Exception('Error al acceder a la hoja de usuarios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 40),
                FlutterLogo(size: 100),
                SizedBox(height: 40),
                TextFormField(
                  controller: _usuarioController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ingrese su usuario' : null,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _claveController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Clave',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ingrese su clave' : null,
                ),
                SizedBox(height: 30),
                if (_isLoading)
                  Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _verificarCredenciales,
                    child: Text('INICIAR SESIÓN'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
