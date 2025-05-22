import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'home_screen.dart';
import 'dart:convert';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _claveController = TextEditingController();
  bool _isLoading = false;
  bool _configLoaded = false;
  String? _loadedCredentials;
  String? _loadedSpreadsheetId;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final configFile = File('config.json');
      if (!await configFile.exists()) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: config.json no encontrado.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final configString = await configFile.readAsString();
      final configJson = jsonDecode(configString);

      // GSheets constructor expects the entire JSON credentials as a string.
      final credentialsJsonString = jsonEncode(configJson);

      if (!mounted) return;
      setState(() {
        _loadedCredentials = credentialsJsonString;
        _loadedSpreadsheetId = configJson['spreadsheet_id'];
        _configLoaded = true;
      });

      if (_loadedSpreadsheetId == null || _loadedSpreadsheetId!.isEmpty) {
         if (!mounted) return;
         setState(() => _configLoaded = false);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: spreadsheet_id no encontrado o vacío en config.json.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar configuración: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      // Ensure configLoaded is false if an error occurs
      setState(() {
        _configLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  Future<void> _verificarCredenciales() async {
    if (!_configLoaded) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La configuración no se ha cargado correctamente. Por favor, revise el archivo config.json e inténtelo de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_loadedCredentials == null || _loadedSpreadsheetId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Credenciales o ID de hoja de cálculo no cargados. Verifique config.json.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final gsheets = GSheets(_loadedCredentials!);
      final spreadsheet = await gsheets.spreadsheet(_loadedSpreadsheetId!);
      final sheet = await _getOrCreateWorksheet(spreadsheet, 'USUARIOS');

      final usuario = _usuarioController.text.trim();
      final clave = _claveController.text.trim();

      final authResult = await _verificarYActualizarSheets(sheet, usuario, clave);

      if (!mounted) return; // Check if the widget is still in the tree
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
      if (!mounted) return; // Check if the widget is still in the tree
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🚨 Error en _verificarCredenciales: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() => _isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>> _verificarYActualizarSheets(
      Worksheet sheet, String usuario, String clave) async {
    final records = await sheet.values.allRows();
    // It's better to check if records is empty rather than null for gsheets
    if (records.isEmpty) {
      return {
        'success': false,
        'message': 'No se encontraron registros en la hoja de usuarios.'
      };
    }

    for (int i = 0; i < records.length; i++) {
      final row = records[i];
      if (row.length >= 3) { // Ensure there are enough columns
        final user = row[1]?.toString().trim() ?? ''; // Corresponds to 'USUARIO'
        final pass = row[2]?.toString().trim() ?? ''; // Corresponds to 'CLAVE'

        if (user == usuario && pass == clave) {
          await _actualizarFechaAcceso(sheet, i + 1); // Sheet rows are 1-indexed
          return {
            'success': true,
            'message': '🎉 ¡Bienvenido $usuario!'
          };
        }
      }
    }

    return {
      'success': false,
      'message': '❌ Usuario o clave incorrectos.'
    };
  }

  Future<void> _actualizarFechaAcceso(Worksheet sheet, int rowNumber) async {
    try {
      final headers = await sheet.values.row(1);
      int modfchIndex = headers.indexWhere(
          (header) => header?.toString().trim().toUpperCase() == 'MODFCH');

      if (modfchIndex == -1) {
        // If 'MODFCH' header doesn't exist, add it as a new column
        modfchIndex = headers.length; // Index for the new column
        await sheet.values.insertValue(
          'MODFCH',
          column: modfchIndex + 1, // Columns are 1-indexed
          row: 1, // Header row
        );
      }

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      await sheet.values.insertValue(
        formattedDate,
        column: modfchIndex + 1, // Columns are 1-indexed
        row: rowNumber, // The row of the authenticated user
      );
    } catch (e) {
      // It's good to log this error or show a non-blocking notification if critical
      print('Error al actualizar fecha de acceso: $e');
      // Optionally, show a SnackBar if this information is crucial for the user to know
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('No se pudo actualizar la fecha de acceso: $e')),
      //   );
      // }
    }
  }

  Future<Worksheet> _getOrCreateWorksheet(
      Spreadsheet spreadsheet, String title) async {
    try {
      var sheet = spreadsheet.worksheetByTitle(title);
      sheet ??= await spreadsheet.addWorksheet(title);
      // Ensure headers exist if we just created the sheet
      // This check might be too simplistic if sheet could exist but be empty
      final firstRow = await sheet.values.row(1);
      if (firstRow.isEmpty || firstRow.every((cell) => cell.isEmpty)) {
         await sheet.values.insertRow(1, ['ID', 'USUARIO', 'CLAVE', 'MODFCH']);
      }
      return sheet;
    } catch (e) {
      throw Exception('Error al acceder o crear la hoja de usuarios "$title": $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
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
                const SizedBox(height: 40),
                const FlutterLogo(size: 100),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ingrese su usuario' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _claveController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Clave',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Ingrese su clave' : null,
                ),
                const SizedBox(height: 30),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _configLoaded ? _verificarCredenciales : null,
                    child: const Text('INICIAR SESIÓN'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _configLoaded ? Theme.of(context).primaryColor : Colors.grey,
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
