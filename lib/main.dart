// ignore_for_file: unused_import, unused_local_variable, library_private_types_in_public_api, use_build_context_synchronously, non_constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Pass',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const PasswordGenerator(),
    );
  }
}

class PasswordGenerator extends StatefulWidget {
  const PasswordGenerator({super.key});

  @override
  _PasswordGeneratorState createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  String password = '';
  int passwordLength = 8;
  bool includeUppercase = true;
  bool includeLowercase = true;
  bool includeNumbers = true;
  bool includeSymbols = true;
  List<String> generatedPasswords = [];
  List<String> temporaryNotes = [];
  TextEditingController noteController = TextEditingController();
  String temporaryNote = '';
  List<String> passwordHistory = [];
  String errorMessage = '';

  void generatePassword() {
    final allowedChars = _getAllowedChars();
    final random = Random.secure();

    if (passwordLength <= 0 || allowedChars.isEmpty) {
      setState(() {
        errorMessage =
            'Error: No se puede generar una contraseña Te faltan Parametros.';
      });
      return;
    }

    final generatedPassword = String.fromCharCodes(
      List.generate(
        passwordLength,
        (index) => allowedChars[random.nextInt(allowedChars.length)],
      ),
    );

    setState(() {
      errorMessage = '';
    });

    setState(() {
      password = generatedPassword;
      generatedPasswords.add(password);
      passwordHistory
          .add(password); // Agregar la contraseña generada al historial
    });
  }

  void showPasswordHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Historial de Contraseñas'),
          content: SingleChildScrollView(
            child: Column(
              children: passwordHistory.map((password) {
                return Dismissible(
                  key: Key(password),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      passwordHistory.remove(password);
                    });
                  },
                  child: ListTile(
                    title: Text(password),
                    onTap: () {
                      copyToClipboard();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo emergente
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  List<int> _getAllowedChars() {
    final List<int> allowedChars = [];

    if (includeUppercase) {
      allowedChars.addAll(utf8.encode('ABCDEFGHIJKLMNOPQRSTUVWXYZ'));
    }
    if (includeLowercase) {
      allowedChars.addAll(utf8.encode('abcdefghijklmnopqrstuvwxyz'));
    }
    if (includeNumbers) allowedChars.addAll(utf8.encode('0123456789'));
    if (includeSymbols) {
      allowedChars.addAll(utf8.encode('!@#\$%^&*()-_=+[]{};:,.<>?/'));
    }

    return allowedChars;
  }

  String getPasswordStrength(String password) {
    // Reglas para evaluar la fortaleza de la contraseña
    bool hasUppercase = false;
    bool hasLowercase = false;
    bool hasDigit = false;
    bool hasSpecialChar = false;

    if (password.length < 6) {
      return 'No Haz Generado Una Contraseña O Es Muy Corta'; // Contraseña demasiado corta
    }

    for (int i = 0; i < password.length; i++) {
      if (password[i].toUpperCase() != password[i].toLowerCase()) {
        if (password[i] == password[i].toUpperCase()) {
          hasUppercase = true;
        } else {
          hasLowercase = true;
        }
      } else if (int.tryParse(password[i]) != null) {
        hasDigit = true;
      } else {
        hasSpecialChar = true;
      }
    }

    if (hasUppercase && hasLowercase && hasDigit && hasSpecialChar) {
      return 'Fuerte, Muy Dificil De Hackear'; // Contraseña fuerte
    } else if ((hasUppercase || hasLowercase) && hasDigit) {
      return 'Mas O Menos, A veces Facil A Veces Dificil'; // Contraseña mediana
    } else {
      return 'Facil, Mejor Genera Otra'; // Contraseña débil
    }
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña copiada al portapapeles')),
    );
  }

  void Notas() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Nota'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    temporaryNote = value; // Almacenar la nota temporalmente
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Ingrese una nota',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nota temporal: $temporaryNote',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  temporaryNotes
                      .add(temporaryNote); // Almacenar la nota temporalmente
                });
                Navigator.of(context).pop(); // Cerrar el diálogo emergente
              },
              child: const Text('Guardar temporalmente'),
            ),
          ],
        );
      },
    );
  }

  void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AboutDialog(
          applicationName: 'Generador de Contraseñas',
          applicationVersion: '1.0',
          applicationLegalese: '© Omar Palomares Velasco',
          children: [
            const SizedBox(height: 16),
            const Text('Desarrollado por: Omar Palomares Velasco (omarPVP123)'),
            const SizedBox(height: 16),
            const Text(
                '¡Apóyame para seguir mejorando esta aplicación y todas las próximas!'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                const follow = 'https://www.facebook.com/omar.palomaresvelasco';
                // ignore: deprecated_member_use
                await launch(follow);
              },
              child: const Text('Conóceme más'),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Pass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: copyToClipboard,
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.notes),
            onPressed: Notas,
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: showPasswordHistory,
            color: Colors.black,
          ),
          IconButton(
            icon: const Icon(Icons.info),
            color: Colors.black, // Cambia el color del ícono aquí
            onPressed: () {
              showAboutDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Contraseña generada:',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            SelectableText(
              password,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: generatePassword,
                  child: const Text('Generar Contraseña'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Configuración de la contraseña:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text('Longitud: $passwordLength'),
            Slider(
              value: passwordLength.toDouble(),
              min: 6,
              max: 20,
              onChanged: (newValue) {
                setState(() {
                  passwordLength = newValue.toInt();
                });
              },
              divisions: 14,
              label: passwordLength.toString(),
            ),
            CheckboxListTile(
              title: const Text('Incluir mayúsculas'),
              value: includeUppercase,
              onChanged: (newValue) {
                setState(() {
                  includeUppercase = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Incluir minúsculas'),
              value: includeLowercase,
              onChanged: (newValue) {
                setState(() {
                  includeLowercase = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Incluir números'),
              value: includeNumbers,
              onChanged: (newValue) {
                setState(() {
                  includeNumbers = newValue!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Incluir símbolos'),
              value: includeSymbols,
              onChanged: (newValue) {
                setState(() {
                  includeSymbols = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Fortaleza de la contraseña:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              getPasswordStrength(password),
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 23),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
