import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../services/services.dart';

class SpeciesFormScreen extends StatefulWidget {
  final int projectId;
  final int zoneId;
  final String zoneName;
  final SpeciesRecord? species;

  const SpeciesFormScreen({
    super.key,
    required this.projectId,
    required this.zoneId,
    required this.zoneName,
    this.species,
  });

  @override
  State<SpeciesFormScreen> createState() => _SpeciesFormScreenState();
}

class _SpeciesFormScreenState extends State<SpeciesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _individualCountController = TextEditingController();
  final _heightController = TextEditingController();

  int? _selectedSpeciesId;
  int? _selectedFunctionalTypeId;
  bool _isEditMode = false;
  int? _editingSpeciesZoneId;
  bool _isSubmitting = false;

  // Tipos funcionales (mock - en producción vendrían del backend)
  final List<Map<String, dynamic>> _functionalTypes = [
    {'id': 1, 'name': 'Árbol'},
    {'id': 2, 'name': 'Arbusto'},
    {'id': 3, 'name': 'Hierba'},
    {'id': 4, 'name': 'Trepadora'},
    {'id': 5, 'name': 'Otro'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.species != null) {
      _isEditMode = true;
      _editingSpeciesZoneId = widget.species!.speciesZoneId;
      _loadSpeciesData(widget.species!);
    }
  }

  void _loadSpeciesData(SpeciesRecord species) {
    _selectedSpeciesId = species.speciesId;
    _nameController.text = species.speciesName;
    _individualCountController.text = species.individualCount.toString();
    _selectedFunctionalTypeId = species.functionalTypeId;
    _heightController.text = '${species.heightStratumMin}-${species.heightStratumMax}';
  }

  void _autoFillFromCatalog(CatalogSpecies species) {
    setState(() {
      _selectedSpeciesId = species.speciesId;
      _nameController.text = species.speciesName;
      final functionalType = _functionalTypes.firstWhere(
        (type) => type['name'] == species.functionalTypeName,
        orElse: () => _functionalTypes.first,
      );
      _selectedFunctionalTypeId = functionalType['id'];
    });
  }

  Future<void> _showCatalogModal() async {
    try {
      final catalogResponse = await SpeciesService.instance.getSpeciesCatalog(
        widget.projectId,
        widget.zoneId,
      );

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3520).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Catálogo de Especies',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0E3520),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Especies que ya has registrado en este proyecto',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: Color(0xFF0E3520),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: catalogResponse.data.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: const Color(0xFF0E3520).withOpacity(0.3),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No hay especies en el catálogo',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Color(0xFF0E3520),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: catalogResponse.data.length,
                        itemBuilder: (context, index) {
                          final species = catalogResponse.data[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _autoFillFromCatalog(species);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF0E3520),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: species.speciesImageUrl != null
                                          ? Image.network(
                                              species.speciesImageUrl!,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: const Color(0xFF0E3520).withOpacity(0.1),
                                                  child: const Icon(
                                                    Icons.eco,
                                                    color: Color(0xFF0E3520),
                                                    size: 24,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              color: const Color(0xFF0E3520).withOpacity(0.1),
                                              child: const Icon(
                                                Icons.eco,
                                                color: Color(0xFF0E3520),
                                                size: 24,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            species.speciesName,
                                            style: const TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0E3520),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            species.functionalTypeName,
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                              fontSize: 12,
                                              color: const Color(0xFF0E3520).withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${species.totalIndividuals} total',
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0E3520),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar catálogo: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            backgroundColor: const Color(0xFFAE0000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFunctionalTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor selecciona un tipo funcional',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: Color(0xFFAE0000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Parsear altura
    final heightParts = _heightController.text.split('-');
    if (heightParts.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Formato de altura inválido. Usa: min-max (ej. 10-20)',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: Color(0xFFAE0000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final heightMin = double.tryParse(heightParts[0].trim());
    final heightMax = double.tryParse(heightParts[1].trim());

    if (heightMin == null || heightMax == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Los valores de altura deben ser numéricos',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          backgroundColor: Color(0xFFAE0000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = SpeciesRequest(
        speciesId: _selectedSpeciesId ?? 0, // Se actualizará según catálogo
        functionalTypeId: _selectedFunctionalTypeId!,
        individualCount: int.parse(_individualCountController.text),
        heightStratumMin: heightMin,
        heightStratumMax: heightMax,
        unitId: 1, // Mock - en producción se seleccionaría
      );

      if (_isEditMode && _editingSpeciesZoneId != null) {
        // Modo edición
        await SpeciesService.instance.updateSpeciesRecord(
          widget.projectId,
          widget.zoneId,
          _editingSpeciesZoneId!,
          request,
        );

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Especie actualizada correctamente',
                style: TextStyle(fontFamily: 'Montserrat'),
              ),
              backgroundColor: Color(0xFF4CAF50),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Modo creación
        final result = await SpeciesService.instance.registerSpecies(
          widget.projectId,
          widget.zoneId,
          request,
        );

        if (!mounted) return;

        // Pattern matching con sealed class
        switch (result) {
          case SpeciesCreated(:final record):
            // 201: Especie creada exitosamente
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Especie "${record.speciesName}" registrada correctamente',
                  style: const TextStyle(fontFamily: 'Montserrat'),
                ),
                backgroundColor: const Color(0xFF4CAF50),
                behavior: SnackBarBehavior.floating,
              ),
            );

          case SpeciesExistsInCatalog(:final response):
            // 200: Existe en catálogo
            final useBase = await _showExistsInCatalogDialog(response);
            if (useBase && mounted) {
              // Autocompletar con datos del catálogo
              setState(() {
                _selectedSpeciesId = response.speciesId;
                _nameController.text = response.speciesName;
                // Mantener los valores que el usuario ya puso
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Datos base cargados. Completa individuos y altura',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  backgroundColor: Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }

          case SpeciesExistsInZone(:final response):
            // 409: Ya existe en esta zona
            final shouldEdit = await _showExistsInZoneDialog(response);
            if (shouldEdit && mounted) {
              // Cambiar a modo edición
              setState(() {
                _isEditMode = true;
                _editingSpeciesZoneId = response.speciesZoneId;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Modo edición activado. Modifica los datos y guarda',
                    style: TextStyle(fontFamily: 'Montserrat'),
                  ),
                  backgroundColor: Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Montserrat'),
            ),
            backgroundColor: const Color(0xFFAE0000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _showExistsInCatalogDialog(SpeciesExistsInCatalogResponse response) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Especie en Catálogo',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E3520),
          ),
        ),
        content: Text(
          'Esta especie "${response.speciesName}" ya existe en el proyecto con ${response.totalIndividuals} individuos registrados.\n\n¿Deseas usar sus datos base?',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Color(0xFF0E3520),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0E3520),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E3520),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Usar Datos',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<bool> _showExistsInZoneDialog(SpeciesExistsInZoneResponse response) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Especie Ya Registrada',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color(0xFF0E3520),
          ),
        ),
        content: Text(
          'Ya registraste "${response.speciesName}" en esta zona con ${response.individualCount} individuos.\n\n¿Deseas modificarla?',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Color(0xFF0E3520),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: Color(0xFF0E3520),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0E3520),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Modificar',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _individualCountController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
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
        child: Stack(
          children: [
            // Border decorativo
            Positioned.fill(
              left: 5,
              right: 5,
              top: 5,
              bottom: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF0E3520),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            // Contenido
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Row(
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 19,
                                  color: Color(0xFF0E3520),
                                ),
                                children: [
                                  TextSpan(
                                    text: _isEditMode ? 'Editar ' : 'Crear ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'Especie',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Botón de catálogo
                          if (!_isEditMode)
                            IconButton(
                              onPressed: _showCatalogModal,
                              icon: const Icon(
                                Icons.search,
                                color: Color(0xFF0E3520),
                              ),
                              tooltip: 'Buscar en catálogo',
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Nombre común
                      const Text(
                        'Nombre común',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E3520),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Ej. Corazón Bonito',
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9,
                            color: const Color(0xFF0E3520).withOpacity(0.75),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Color(0xFF0E3520),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo requerido';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Número de individuos
                      const Text(
                        'Número de individuos',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E3520),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _individualCountController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: 'Ej. 20',
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9,
                            color: const Color(0xFF0E3520).withOpacity(0.75),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Color(0xFF0E3520),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo requerido';
                          }
                          final count = int.tryParse(value);
                          if (count == null || count <= 0) {
                            return 'Debe ser mayor a 0';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tipo funcional
                      const Text(
                        'Tipo funcional',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E3520),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        initialValue: _selectedFunctionalTypeId,
                        decoration: InputDecoration(
                          hintText: 'Seleccione una opción',
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9,
                            color: const Color(0xFF0E3520).withOpacity(0.75),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Color(0xFF0E3520),
                        ),
                        items: _functionalTypes.map((type) {
                          return DropdownMenuItem<int>(
                            value: type['id'],
                            child: Text(type['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFunctionalTypeId = value;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Altura o estrato
                      const Text(
                        'Altura o estrato',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E3520),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          hintText: 'Ej. 10-20m',
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 9,
                            color: const Color(0xFF0E3520).withOpacity(0.75),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(
                              color: Color(0xFF0E3520),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Color(0xFF0E3520),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo requerido';
                          }
                          if (!value.contains('-')) {
                            return 'Formato: min-max (ej. 10-20)';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Fotografía
                      const Text(
                        'Fotografia',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0E3520),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implementar subida de imagen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Subida de imágenes no implementada aún',
                                style: TextStyle(fontFamily: 'Montserrat'),
                              ),
                              backgroundColor: Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0E3520),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.image, size: 16),
                        label: const Text(
                          'Subir Fotografía',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botones de acción
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF0E3520),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0E3520),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0E3520),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Aceptar',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF1F5F9),
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
          ],
        ),
      ),
    );
  }
}
