import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sylvara_frontend/core/widgets/custom_text_field.dart';
import 'package:sylvara_frontend/features/projects/models/models.dart';
import 'package:sylvara_frontend/features/projects/services/project_service.dart';

class ProjectFormScreen extends StatefulWidget {
  final Plot? project;

  const ProjectFormScreen({super.key, this.project});

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectService = ProjectService();

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _areaController = TextEditingController();

  int _selectedUnitId = 1;
  bool _isLoading = false;

  bool get _isEditing => widget.project != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nombreController.text = widget.project!.samplingPlotName;
      _descripcionController.text = widget.project!.unitName ?? '';
      if (widget.project!.totalArea != null) {
        _areaController.text = widget.project!.totalArea!.toString();
      }
      if (widget.project!.unitId != null) {
        _selectedUnitId = widget.project!.unitId!;
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final area = _areaController.text.trim().isNotEmpty
          ? double.tryParse(_areaController.text.trim())
          : null;

      if (!_isEditing) {
        final request = CreateProjectRequest(
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          area: area,
          unitId: _selectedUnitId,
        );
        await _projectService.createProject(request);
      } else {
        final request = UpdateProjectRequest(
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim().isEmpty
              ? null
              : _descripcionController.text.trim(),
          area: area,
          unitId: _selectedUnitId,
        );
        await _projectService.updateProject(widget.project!.id, request);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              _isEditing ? 'Proyecto actualizado exitosamente' : 'Proyecto creado exitosamente',
              style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
            ),
          ]),
          backgroundColor: const Color(0xFF0E3520),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                e.toString().replaceAll('Exception: ', ''),
                style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
              ),
            ),
          ]),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0E3520)),
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 20, fontFamily: 'Montserrat', color: Color(0xFF0E3520)),
            children: [
              TextSpan(
                text: _isEditing ? 'Editar ' : 'Crear ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text: 'Proyecto',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre
                CustomTextField(
                  label: 'Nombre del proyecto *',
                  placeholder: 'Ej. Corazón Bonito',
                  controller: _nombreController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Ingresa un nombre';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Descripción
                const Text(
                  'Descripción',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0E3520),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 4,
                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF0E3520)),
                  decoration: InputDecoration(
                    hintText: 'Describe brevemente el proyecto...',
                    hintStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: const Color(0xFF0E3520).withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD0D5DD))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF0E3520), width: 1.5)),
                  ),
                ),

                const SizedBox(height: 20),

                // Área + Unidad
                const Text(
                  'Extensión de la zona de estudio',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0E3520),
                  ),
                ),
                const SizedBox(height: 6),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Expanded(
                      child: TextFormField(
                        controller: _areaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                        style: const TextStyle(fontFamily: 'Montserrat', fontSize: 14, color: Color(0xFF0E3520)),
                        decoration: InputDecoration(
                          hintText: 'Ej. 400',
                          hintStyle: TextStyle(fontFamily: 'Montserrat', fontSize: 13, color: const Color(0xFF0E3520).withOpacity(0.4)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            borderSide: const BorderSide(color: Color(0xFF0E3520), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        border: const Border(
                          top: BorderSide(color: Color(0xFFD0D5DD)),
                          right: BorderSide(color: Color(0xFFD0D5DD)),
                          bottom: BorderSide(color: Color(0xFFD0D5DD)),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedUnitId,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF0E3520)),
                          ),
                          style: const TextStyle(fontFamily: 'Montserrat', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0E3520)),
                          dropdownColor: const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: const [
                            DropdownMenuItem(value: 1, child: Text('m²')),
                            DropdownMenuItem(value: 2, child: Text('ha')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedUnitId = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                ),

                const SizedBox(height: 36),

                // Botones
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF0E3520), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0E3520)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0E3520),
                            disabledBackgroundColor: const Color(0xFFCBD5E1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  _isEditing ? 'Guardar' : 'Crear',
                                  style: const TextStyle(fontFamily: 'Montserrat', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}