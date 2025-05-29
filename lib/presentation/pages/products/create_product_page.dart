import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/providers/create_product_provider.dart';

class CreateProductPage extends ConsumerWidget {
  CreateProductPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryIdController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _reorderPointController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createProductProvider);
    
    ref.listen(createProductProvider, (previous, current) {
      if (current.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado con éxito')),
        );
        _resetForm();
      }
      
      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${current.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _categoryIdController,
                decoration: const InputDecoration(labelText: 'Categoría'),
                validator: (value) => (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(labelText: 'Precio de Venta'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (double.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              TextFormField(
                controller: _costPriceController,
                decoration: const InputDecoration(labelText: 'Precio de Costo'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (double.tryParse(value) == null) return 'Debe ser un número';
                  return null;
                },
              ),
              TextFormField(
                controller: _reorderPointController,
                decoration: const InputDecoration(labelText: 'Punto de Reorden'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Campo requerido';
                  if (int.tryParse(value) == null) return 'Debe ser un número entero';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () => _submitForm(ref),
                child: state.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm(WidgetRef ref) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(createProductProvider.notifier).createProduct(
      sku: _skuController.text,
      name: _nameController.text,
      description: _descriptionController.text,
      categoryId: _categoryIdController.text,
      unitPrice: double.parse(_unitPriceController.text),
      costPrice: double.parse(_costPriceController.text),
      reorderPoint: int.parse(_reorderPointController.text),
    );
  }

  void _resetForm() {
    _skuController.clear();
    _nameController.clear();
    _descriptionController.clear();
    _categoryIdController.clear();
    _unitPriceController.clear();
    _costPriceController.clear();
    _reorderPointController.clear();
  }
}
