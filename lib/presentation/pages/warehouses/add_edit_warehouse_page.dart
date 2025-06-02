import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/warehouse_providers.dart';
import '../../../domain/entities/warehouse.dart';

class AddEditWarehousePage extends ConsumerStatefulWidget {
  final String? warehouseId;

  const AddEditWarehousePage({
    super.key,
    this.warehouseId,
  });

  @override
  ConsumerState<AddEditWarehousePage> createState() => _AddEditWarehousePageState();
}

class _AddEditWarehousePageState extends ConsumerState<AddEditWarehousePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _contactInfoController = TextEditingController();
  
  bool _isLoading = false;
  bool get _isEditing => widget.warehouseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadWarehouse();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _managerNameController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  void _loadWarehouse() async {
    if (widget.warehouseId == null) return;
    
    final warehouseAsync = ref.read(warehouseByIdProvider(widget.warehouseId!));
    warehouseAsync.when(
      data: (warehouse) {
        if (warehouse != null && mounted) {
          _nameController.text = warehouse.name;
          _locationController.text = warehouse.location;
          _capacityController.text = warehouse.capacity.toString();
          _managerNameController.text = warehouse.managerName;
          _contactInfoController.text = warehouse.contactInfo;
        }
      },
      loading: () {},
      error: (error, stack) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar almacén: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Almacén' : 'Nuevo Almacén'),
        backgroundColor: theme.colorScheme.surfaceContainer,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Eliminar',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warehouse,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'Editar Almacén' : 'Nuevo Almacén',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _isEditing 
                                ? 'Modifica la información del almacén'
                                : 'Completa la información para crear un nuevo almacén',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Basic Information Section
            _buildSectionTitle('Información Básica', Icons.info_outline),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _nameController,
              label: 'Nombre del Almacén',
              hint: 'Ej: Almacén Central',
              icon: Icons.business,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _locationController,
              label: 'Ubicación',
              hint: 'Ej: Av. Principal 123, Ciudad',
              icon: Icons.location_on,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La ubicación es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _capacityController,
              label: 'Capacidad (unidades)',
              hint: 'Ej: 1000',
              icon: Icons.inventory_2,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La capacidad es obligatoria';
                }
                final capacity = int.tryParse(value);
                if (capacity == null || capacity <= 0) {
                  return 'Ingresa una capacidad válida mayor a 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Contact Information Section
            _buildSectionTitle('Información de Contacto', Icons.contact_phone),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _managerNameController,
              label: 'Responsable/Gerente',
              hint: 'Ej: Juan Pérez',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El responsable es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _contactInfoController,
              label: 'Información de Contacto',
              hint: 'Ej: +1234567890 o email@ejemplo.com',
              icon: Icons.contact_phone,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La información de contacto es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveWarehouse,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Actualizar' : 'Crear'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveWarehouse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final warehouse = Warehouse(
        id: widget.warehouseId ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        location: _locationController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
        managerName: _managerNameController.text.trim(),
        contactInfo: _contactInfoController.text.trim(),
      );

      // TODO: Implement save functionality via repository
      await Future.delayed(const Duration(seconds: 1)); // Simulate save

      if (mounted) {
        // Refresh the warehouses list
        ref.invalidate(warehousesProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing 
                  ? 'Almacén actualizado exitosamente'
                  : 'Almacén creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, warehouse);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Está seguro de que desea eliminar este almacén? Esta acción no se puede deshacer y se perderán todos los datos asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteWarehouse();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteWarehouse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement delete functionality via repository
      await Future.delayed(const Duration(seconds: 1)); // Simulate delete

      if (mounted) {
        // Refresh the warehouses list
        ref.invalidate(warehousesProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Almacén eliminado exitosamente'),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
