import 'package:flutter/material.dart';
import 'package:sylvara_frontend/core/widgets/widgets.dart';
import 'package:sylvara_frontend/features/projects/models/models.dart';
import 'package:sylvara_frontend/features/projects/services/project_service.dart';

class ProjectFormScreen extends StatefulWidget {
  final Plot? project; // null = crear, no null = editar

  const ProjectFormScreen({
    super.key,
    this.project,
  });

  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectService = ProjectService();

  // Controladores
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _areaController = TextEditingController();

  // Unidad seleccionada (1: Metros, 2: Hectáreas)
  int _selectedUnitId = 1;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Si es edición, prellenar los campos
    if (widget.project != null) {
      _nombreController.text = widget.project!.name;
      _descripcionController.text = widget.project!.description;
      // TODO: cargar área y unidad si están disponibles en el modelo
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final area = _areaController.text.isNotEmpty
          ? double.tryParse(_areaController.text)
          : null;

      if (widget.project == null) {
        // Crear proyecto
        final request = CreateProjectRequest(
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          area: area,
          unitId: _selectedUnitId,
        );

        await _projectService.createProject(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Proyecto creado exitosamente',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF0E3520),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true); // true indica que se creó
        }
      } else {
        // Editar proyecto
        final request = UpdateProjectRequest(
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          area: area,
          unitId: _selectedUnitId,
        );

        await _projectService.updateProject(widget.project!.id, request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Proyecto actualizado exitosamente',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF0E3520),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pop(context, true); // true indica que se actualizó
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage ?? 'Error al guardar proyecto',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD32F2F),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.project != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          // Background image
          const BackgroundImage(
            imagePath: 'assets/images/backgrounds/background.png',
            height: 612,
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header con logo y título
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Container(
                        width: 50,
                        height: 54,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/backgrounds/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      // Título
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 22,
                            fontFamily: 'Montserrat',
                            color: const Color(0xFF0E3520),
                          ),
                          children: [
                            TextSpan(
                              text: 'Mis',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            TextSpan(
                              text: ' Proyectos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Contenedor del formulario (estilo glassmorphism)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          // Overlay difuminado (detrás del modal)
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFF1F5F9).withOpacity(0.2),
                            ),
                          ),

                          // Modal del formulario
                          Transform.translate(
                            offset: const Offset(0, -100),
                            child: Container(
                              width: 336,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFF0E3520),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(15),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Título del modal
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontFamily: 'Montserrat',
                                            color: const Color(0xFF0E3520),
                                          ),
                                          children: [
                                            TextSpan(
                                              text: isEditing
                                                  ? 'Editar '
                                                  : 'Crear ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Proyecto',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),

                                      // Campo: Nombre del proyecto
                                      CustomTextField(
                                        label: 'Nombre del proyecto',
                                        placeholder: 'Ej. Corazón Bonito',
                                        controller: _nombreController,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Ingresa un nombre';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 15),

                                      // Campo: Descripción del proyecto
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Descripción del proyecto',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0E3520),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 49,
                                            child: TextFormField(
                                              controller:
                                                  _descripcionController,
                                              maxLines: 3,
                                              style: const TextStyle(
                                                fontFamily: 'Montserrat',
                                                fontSize: 9,
                                                color: Color(0xFF0E3520),
                                              ),
                                              decoration: InputDecoration(
                                                hintText: 'Ej. 300m',
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 9,
                                                  color:
                                                      const Color(0xFF0E3520)
                                                          .withOpacity(0.75),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                contentPadding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                  horizontal: 9,
                                                  vertical: 5,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5),
                                                  borderSide:
                                                      const BorderSide(
                                                    color: Color(0xFF0E3520),
                                                    width: 1,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5),
                                                  borderSide:
                                                      const BorderSide(
                                                    color: Color(0xFF0E3520),
                                                    width: 1,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5),
                                                  borderSide:
                                                      const BorderSide(
                                                    color: Color(0xFF0E3520),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Ingresa una descripción';
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 15),

                                      // Campo: Extensión de la zona
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Extensión de la zona de estudio (m2)',
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0E3520),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 24,
                                            child: Row(
                                              children: [
                                                // Campo de texto para el área
                                                Expanded(
                                                  child: TextFormField(
                                                    controller:
                                                        _areaController,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          'Montserrat',
                                                      fontSize: 9,
                                                      color:
                                                          Color(0xFF0E3520),
                                                    ),
                                                    decoration:
                                                        InputDecoration(
                                                      hintText:
                                                          'Ej. 400m / 1ha',
                                                      hintStyle: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 9,
                                                        color: const Color(
                                                                0xFF0E3520)
                                                            .withOpacity(
                                                                0.75),
                                                      ),
                                                      filled: true,
                                                      fillColor:
                                                          Colors.white,
                                                      contentPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                        horizontal: 9,
                                                        vertical: 5,
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Color(
                                                              0xFF0E3520),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Color(
                                                              0xFF0E3520),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        borderSide:
                                                            const BorderSide(
                                                          color: Color(
                                                              0xFF0E3520),
                                                          width: 2,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // Dropdown de unidad
                                                Container(
                                                  width: 83,
                                                  height: 22,
                                                  margin:
                                                      const EdgeInsets.only(
                                                          left: 0),
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                        0xFFF1F5F9),
                                                    borderRadius:
                                                        const BorderRadius
                                                            .only(
                                                      topRight:
                                                          Radius.circular(5),
                                                      bottomRight:
                                                          Radius.circular(5),
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(
                                                                0.15),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(
                                                                -2, 0),
                                                      ),
                                                    ],
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton<int>(
                                                      value:
                                                          _selectedUnitId,
                                                      isExpanded: true,
                                                      icon: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 8),
                                                        child: Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          size: 12,
                                                          color: const Color(
                                                              0xFF0E3520),
                                                        ),
                                                      ),
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 8,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color(
                                                            0xFF0E3520),
                                                      ),
                                                      dropdownColor:
                                                          const Color(
                                                              0xFFF1F5F9),
                                                      items: const [
                                                        DropdownMenuItem(
                                                          value: 1,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10),
                                                            child: Text(
                                                                'Metros'),
                                                          ),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: 2,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            10),
                                                            child: Text(
                                                                'Hectáreas'),
                                                          ),
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            _selectedUnitId =
                                                                value;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 25),

                                      // Botones: Cancelar y Aceptar
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Botón Cancelar
                                          SizedBox(
                                            width: 129,
                                            height: 30,
                                            child: OutlinedButton(
                                              onPressed: _isLoading
                                                  ? null
                                                  : () =>
                                                      Navigator.pop(context),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(
                                                  color: Color(0xFF0E3520),
                                                  width: 2,
                                                ),
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10),
                                              ),
                                              child: Text(
                                                'Cancelar',
                                                style: const TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: Color(0xFF0E3520),
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Botón Aceptar
                                          SizedBox(
                                            width: 129,
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: _isLoading
                                                  ? null
                                                  : _handleSubmit,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF0E3520),
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(10),
                                              ),
                                              child: _isLoading
                                                  ? SizedBox(
                                                      width: 14,
                                                      height: 14,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                Color>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                  : Text(
                                                      'Aceptar',
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                            0xFFF1F5F9),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
