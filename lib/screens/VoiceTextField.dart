import 'package:flutter/material.dart';
import 'package:helvetasfront/screens/CustomDecoration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final TextStyle? style;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const VoiceTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.style,
    this.keyboardType = TextInputType.number,
    this.validator,
  }) : super(key: key);

  @override
  _VoiceTextFieldState createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';

  final Map<String, int> _wordToNumberMap = {
    'uno': 1,
    'dos': 2,
    'tres': 3,
    'cuatro': 4,
    'cinco': 5,
    'seis': 6,
    'siete': 7,
    'ocho': 8,
    'nueve': 9,
    'cero': 0
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

   Future<void> _requestMicrophonePermission() async {
  PermissionStatus status = await Permission.microphone.status;

  if (!status.isGranted) {
    // Solicita el permiso si no ha sido concedido
    status = await Permission.microphone.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      // Aquí podrías manejar lo que sucede si el permiso es negado
      print('El permiso de micrófono ha sido negado.');
      return;
    }
  }
}


  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (errorNotification) {
        print('Speech error: ${errorNotification.errorMsg}');
      },
    );
    if (!available) {
      print('Speech recognition not available');
    } else {
      print('Speech recognition initialized');
    }
  }

  void _startListening() async {
    setState(() {
      _isListening = true;
    });
    _speech.listen(
      onResult: (result) {
        setState(() {
          _lastWords = result.recognizedWords.toLowerCase(); // Convertir a minúsculas para comparar
          print('Recognized words: $_lastWords');

          // Verificar si las palabras coinciden con algún número en el mapeo
          if (_wordToNumberMap.containsKey(_lastWords)) {
            widget.controller.text = _wordToNumberMap[_lastWords].toString(); // Asignar el número correspondiente
          } else {
            // Verificar si es un número entero
            final int? intValue = int.tryParse(_lastWords);
            if (intValue != null) {
              widget.controller.text = intValue.toString();
            } else {
              // Verificar si es un número decimal
              final double? doubleValue = double.tryParse(_lastWords);
              if (doubleValue != null) {
                widget.controller.text = doubleValue.toString();
              } else {
                print('Not a valid number');
              }
            }
          }
        });
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
      partialResults: false,
      localeId: 'es_ES', // Cambia según sea necesario
    );
  }

  void _stopListening() async {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  InputDecoration get _inputDecoration {
    return CustomDecorations.customDecoration(widget.labelText, widget.icon).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          _isListening ? Icons.stop : Icons.mic,
          color: Colors.white,
        ),
        onPressed: _isListening ? _stopListening : _startListening,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.all(8.0),
      child: TextFormField(
        controller: widget.controller,
        decoration: _inputDecoration,
        style: widget.style,
        keyboardType: TextInputType.number, // Forzar teclado numérico
        validator: widget.validator,
      ),
    );
  }
}
