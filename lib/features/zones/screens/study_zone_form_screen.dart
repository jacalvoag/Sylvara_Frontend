import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Screen para crear o editar una Zona de Estudio.
///
/// Si [zoneId] es null, se crea una nueva zona.
/// Si [zoneId] tiene valor, se edita la zona existente.
class StudyZoneFormScreen extends StatefulWidget {
  final int projectId;
  final int? zoneId;
  final StudyZone? existingZone;

  const StudyZoneFormScreen({
    super.key,
    required this.projectId,
    this.zoneId,
    this.existingZone,
  });

  @override
  State<StudyZoneFormScreen> createState() => _StudyZoneFormScreenState();
}

class _StudyZoneFormScreenState extends State<StudyZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();

  int _selectedUnitId = 2; // Default: Hectáreas
  bool _isSubmitting = false;

  final Map<int, String> _units = {
    1: 'Metros',
    2: 'Hectáreas',
  };

  @override
  void initState() {
    super.initState();
    if (widget.existingZone != null) {
      _nameController.text = widget.existingZone!.nameStudyZone;
      _areaController.text = widget.existingZone!.subArea.toString();
      _selectedUnitId = widget.existingZone!.unitId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final request = StudyZoneRequest(
        nameStudyZone: _nameController.text.trim(),
        subArea: double.parse(_areaController.text),
        unitId: _selectedUnitId,
      );

      if (widget.zoneId == null) {
        // Crear nueva zona
        await StudyZoneService.instance.createStudyZone(
          widget.projectId,
          request,
        );
        if (!mounted) return;
        Navigator.of(context).pop(true); // true = created
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zona de estudio creada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      } else {
        // Editar zona existente
        await StudyZoneService.instance.updateStudyZone(
          widget.projectId,
          widget.zoneId!,
          request,
        );
        if (!mounted) return;
        Navigator.of(context).pop(true); // true = updated
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zona de estudio actualizada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } on StudyZoneException catch (e) {
      if (!mounted) return;
      String message = e.message;
      if (e.statusCode == 422) {
        if (e.message.contains('AREA_EXCEEDED')) {
          message = 'El área excede el límite permitido (5000 ha)';
        } else if (e.message.contains('name')) {
          message = 'El nombre debe tener al menos 3 caracteres';
        }
      } else if (e.statusCode == 404) {
        message = 'Zona no encontrada';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFAE0000),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: const Color(0xFFAE0000),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.zoneId != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E3520),
        foregroundColor: const Color(0xFFF1F5F9),
        title: Text(isEditing ? 'Editar Zona' : 'Nueva Zona'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nombre de la zona
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la zona',
                hintText: 'Ej: Zona Norte',
                prefixIcon: const Icon(
                  Icons.terrain,
                  color: Color(0xFF0E3520),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF0E3520),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Área
            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Área',
                hintText: 'Ej: 250.5',
                prefixIcon: const Icon(
                  Icons.square_foot,
                  color: Color(0xFF0E3520),
                ),
                suffixText: _units[_selectedUnitId],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF0E3520),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El área es obligatoria';
                }
                final area = double.tryParse(value);
                if (area == null) {
                  return 'Ingrese un número válido';
                }
                if (area <= 0) {
                  return 'El área debe ser mayor a 0';
                }
                if (area > 5000) {
                  return 'El área no puede exceder 5000 ha';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Unidad de medida
            DropdownButtonFormField<int>(
              initialValue: _selectedUnitId,
              decoration: InputDecoration(
                labelText: 'Unidad de medida',
                prefixIcon: const Icon(
                  Icons.straighten,
                  color: Color(0xFF0E3520),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF0E3520),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _units.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedUnitId = value);
                }
              },
            ),
            const SizedBox(height: 40),

            // Botón de envío
            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E3520),
                foregroundColor: const Color(0xFFF1F5F9),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFF1F5F9),
                        ),
                      ),
                    )
                  : Text(
                      isEditing ? 'Actualizar Zona' : 'Crear Zona',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
