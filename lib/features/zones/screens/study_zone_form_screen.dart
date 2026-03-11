import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Formulario para crear o editar una Zona de Estudio.
/// Estilo similar a la captura del formulario de proyecto.
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

  // unitId 1 = m², unitId 2 = ha
  int _selectedUnitId = 2;
  bool _isSubmitting = false;

  bool get _isEditing => widget.zoneId != null;

  // 1 ha = 10,000 m²
  double _toHectares(double value, int unitId) =>
      unitId == 1 ? value / 10000 : value;

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
        subArea: double.parse(_areaController.text.trim()),
        unitId: _selectedUnitId,
      );

      if (!_isEditing) {
        await StudyZoneService.instance.createStudyZone(widget.projectId, request);
      } else {
        await StudyZoneService.instance.updateStudyZone(
            widget.projectId, widget.zoneId!, request);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEditing
            ? 'Zona actualizada exitosamente'
            : 'Zona creada exitosamente'),
        backgroundColor: const Color(0xFF4CAF50),
      ));
    } on StudyZoneException catch (e) {
      if (!mounted) return;
      String msg = e.message;
      if (msg.contains('AREA_EXCEEDED')) {
        msg = 'El área de la zona excede el área total del proyecto';
      } else if (msg.contains('name')) {
        msg = 'El nombre debe tener al menos 3 caracteres';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFFD32F2F)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFD32F2F)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0E3520)),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _isEditing ? 'Editar ' : 'Crear ',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF0E3520),
                  fontFamily: 'Montserrat',
                ),
              ),
              const TextSpan(
                text: 'Zona',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E3520),
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            // ── NOMBRE ──────────────────────────────────────────────
            _label('Nombre de la zona *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _inputDeco(hint: 'Ej. Corazón Bonito'),
              maxLength: 50,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                return null;
              },
            ),

            // ── ÁREA + UNIDAD ────────────────────────────────────────
            _label('Extensión de la zona de estudio'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Area input
                Expanded(
                  child: TextFormField(
                    controller: _areaController,
                    decoration: _inputDeco(hint: 'Ej. 400'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Obligatorio';
                      final a = double.tryParse(v);
                      if (a == null) return 'Número inválido';
                      if (a <= 0) return 'Debe ser > 0';
                      if (_toHectares(a, _selectedUnitId) > 5000) {
                        return 'Máx. 5000 ha';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Unit dropdown styled as a button
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedUnitId,
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF0E3520), size: 18),
                      style: const TextStyle(
                        color: Color(0xFF0E3520),
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('m²')),
                        DropdownMenuItem(value: 2, child: Text('ha')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedUnitId = v);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // ── BUTTONS ──────────────────────────────────────────────
            Row(
              children: [
                // Cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0E3520),
                      side: const BorderSide(color: Color(0xFF0E3520), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Crear/Actualizar
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E3520),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text(
                            _isEditing ? 'Actualizar' : 'Crear',
                            style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0E3520),
          fontFamily: 'Montserrat',
        ),
      );

  InputDecoration _inputDeco({required String hint}) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontFamily: 'Montserrat', fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0E3520), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD32F2F))),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2)),
        counterText: '',
      );
}
