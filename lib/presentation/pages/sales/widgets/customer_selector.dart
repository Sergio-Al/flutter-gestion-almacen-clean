import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/customer.dart';
import '../../../providers/customer_providers.dart';

class CustomerSelector extends ConsumerStatefulWidget {
  final Customer? selectedCustomer;
  final List<Customer> customers;
  final ValueChanged<Customer?> onCustomerSelected;
  final String? hintText;
  final bool enabled;

  const CustomerSelector({
    super.key,
    this.selectedCustomer,
    required this.customers,
    required this.onCustomerSelected,
    this.hintText,
    this.enabled = true,
  });

  @override
  ConsumerState<CustomerSelector> createState() => _CustomerSelectorState();
}

class _CustomerSelectorState extends ConsumerState<CustomerSelector> {
  final TextEditingController _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  List<Customer> _filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    if (widget.selectedCustomer != null) {
      _searchController.text = widget.selectedCustomer!.name;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _closeDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                enabled: widget.enabled,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Seleccionar cliente...',
                  prefixIcon: const Icon(Icons.person),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onTap: () {
                  if (widget.enabled) {
                    _toggleDropdown();
                  }
                },
                onChanged: _filterCustomers,
              ),
            ),
            if (widget.enabled)
              IconButton(
                icon: Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                ),
                onPressed: _toggleDropdown,
              ),
            if (widget.selectedCustomer != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: widget.enabled ? _clearSelection : null,
              ),
          ],
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isOpen = false;
    });
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = widget.customers;
      } else {
        _filteredCustomers = widget.customers
            .where((customer) =>
                customer.name.toLowerCase().contains(query.toLowerCase()) ||
                customer.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _selectCustomer(Customer customer) {
    _searchController.text = customer.name;
    widget.onCustomerSelected(customer);
    _closeDropdown();
  }

  void _clearSelection() {
    _searchController.clear();
    widget.onCustomerSelected(null);
    setState(() {
      _filteredCustomers = widget.customers;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón para crear nuevo cliente
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        _closeDropdown();
                        _showCreateCustomerDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Crear nuevo cliente'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredCustomers.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = _filteredCustomers[index];
                              return _buildCustomerItem(customer);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerItem(Customer customer) {
    return InkWell(
      onTap: () => _selectCustomer(customer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue[100],
              child: Text(
                customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (customer.email.isNotEmpty)
                    Text(
                      customer.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            if (customer.phone.isNotEmpty)
              Text(
                customer.phone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron clientes',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _closeDropdown();
              _showCreateCustomerDialog(context);
            },
            child: const Text('Crear nuevo cliente'),
          ),
        ],
      ),
    );
  }

  void _showCreateCustomerDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Dirección',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('El nombre es requerido')),
                );
                return;
              }

              Navigator.of(context).pop(); // Cerrar el diálogo

              try {
                // Crear el nuevo cliente
                final newCustomer = Customer(
                  id: '', // El ID se generará en el datasource
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: addressController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                // Mostrar indicador de carga
                _showLoadingDialog(context, 'Creando cliente...');

                // Usar el provider para crear el cliente
                final createdCustomer = await ref
                    .read(createCustomerProvider(newCustomer).future)
                    .timeout(const Duration(seconds: 10));

                // Cerrar el indicador de carga
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                // Actualizar la lista de clientes y seleccionar el nuevo cliente
                if (mounted) {
                  setState(() {
                    // Creamos una nueva lista para asegurar que se detecte el cambio
                    final updatedCustomers = List<Customer>.from(widget.customers);
                    updatedCustomers.add(createdCustomer);
                    
                    // Actualizamos la lista filtrada
                    _filteredCustomers = updatedCustomers;
                    
                    // Seleccionamos automáticamente el nuevo cliente
                    _selectCustomer(createdCustomer);
                  });
                }

                // Mostrar mensaje de éxito
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cliente creado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Cerrar el diálogo de carga si está abierto
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }

                // Mostrar mensaje de error
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message),
            ],
          ),
        );
      },
    );
  }
}
