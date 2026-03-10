import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';


/// Servicio para subir imágenes a Cloudinary usando un preset unsigned.
/// Usa [http.MultipartRequest] ya disponible en el proyecto.
class CloudinaryService {
  CloudinaryService._();

  static const String _cloudName = 'dbzpkxh6i';
  static const String _uploadPreset = 'sylvara_preset';
  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  static final _picker = ImagePicker();

  /// Abre el selector de fuente (cámara o galería) y sube la imagen elegida a
  /// Cloudinary. Retorna la `secure_url` de la imagen o `null` si el usuario
  /// canceló. Lanza una excepción con mensaje legible si el upload falla.
  static Future<String?> pickAndUpload({
    required ImageSource source,
    int imageQuality = 85,
    double? maxWidth,
  }) async {
    // 1. Seleccionar imagen
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth ?? 1500,
    );

    if (image == null) return null; // Usuario canceló

    // 2. Subir a Cloudinary con MultipartRequest
    final uri = Uri.parse(_uploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      final decoded = jsonDecode(responseBody);
      final message = decoded['error']?['message'] ?? 'Error desconocido';
      throw Exception('Cloudinary upload failed: $message');
    }

    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    return json['secure_url'] as String?;
  }

  /// Muestra un BottomSheet para elegir entre cámara y galería y sube la imagen.
  /// Retorna la URL o null si el usuario canceló.
  static Future<String?> pickSourceAndUpload(context) async {
    ImageSource? source;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF1F5F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3520).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Seleccionar imagen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E3520),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0E3520),
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Cámara',
                    style: TextStyle(color: Color(0xFF0E3520))),
                onTap: () {
                  source = ImageSource.camera;
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF0E3520),
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Galería',
                    style: TextStyle(color: Color(0xFF0E3520))),
                onTap: () {
                  source = ImageSource.gallery;
                  Navigator.of(ctx).pop();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;
    return pickAndUpload(source: source!);
  }
}
