import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/core/providers/category_providers.dart';
import 'package:gestion_almacen_stock/domain/entities/category.dart';
import 'package:gestion_almacen_stock/presentation/providers/product_providers.dart';
import 'package:gestion_almacen_stock/presentation/widgets/category_selector_dialog.dart';
import '../../../domain/entities/product.dart';
import '../../providers/create_product_provider.dart';
import './widgets/product_image_widget.dart';
import './widgets/barcode_scanner_widget.dart';

class AddEditProductPage extends ConsumerStatefulWidget {
  final Product? product; // null for add, Product instance for edit

  const AddEditProductPage({Key? key, this.product}) : super(key: key);

  @override
  ConsumerState<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends ConsumerState<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _skuController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryIdController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _reorderPointController;
  late final TextEditingController _categoryNameController;

  bool get isEditing => widget.product != null;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final product = widget.product;

    _skuController = TextEditingController(text: product?.sku ?? '');
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _categoryIdController = TextEditingController(
      text: product?.categoryId ?? '',
    );
    _unitPriceController = TextEditingController(
      text: product?.unitPrice.toString() ?? '',
    );
    _costPriceController = TextEditingController(
      text: product?.costPrice.toString() ?? '',
    );
    _reorderPointController = TextEditingController(
      text: product?.reorderPoint.toString() ?? '',
    );
    _categoryNameController = TextEditingController();
    if (product?.categoryId != null) {
      // Cargar el nombre de la categoría basado en el ID
      ref.read(categoryByIdProvider(product!.categoryId!)).whenData((category) {
        if (category != null) {
          setState(() {
            _categoryNameController.text = category.name;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryIdController.dispose();
    _unitPriceController.dispose();
    _costPriceController.dispose();
    _reorderPointController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createProductProvider);

    ref.listen(createProductProvider, (previous, current) {
      if (current.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Producto actualizado con éxito'
                  : 'Producto creado con éxito',
            ),
          ),
        );
        if (!isEditing) {
          _resetForm();
        }
        ref.refresh(productCountProvider); // Refresh products list
        Navigator.pop(context, true); // Return true to indicate success
      }

      if (current.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${current.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Producto' : 'Crear Producto'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Información'),
                        content: Text(
                          'Editando: ${widget.product!.name}\n'
                          'ID: ${widget.product!.id}\n'
                          'Creado: ${_formatDate(widget.product!.createdAt)}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                );
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Section
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Basic Information
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),

                    // Pricing Information
                    _buildPricingSection(),
                    const SizedBox(height: 24),

                    // Inventory Information
                    _buildInventorySection(),
                  ],
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(createState),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Imagen del Producto',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: ProductImageWidget(
                      productId: widget.product?.id ?? 'new-product',
                      imageUrl: _imageUrl,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement image picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selección de imagen próximamente'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.photo),
                        label: const Text('Galería'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement camera
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cámara próximamente'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Cámara'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // SKU Field with Barcode Scanner
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU *',
                      hintText: 'Código único del producto',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            (value?.isEmpty ?? true) ? 'Campo requerido' : null,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showBarcodeScanner(),
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Escanear código',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Product Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Producto *',
                hintText: 'Ej: iPhone 13 Pro',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      (value?.isEmpty ?? true) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción detallada del producto',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryNameController,
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                hintText: 'Ej: Electrónicos',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              validator:
                  (value) =>
                      (value?.isEmpty ?? true) ? 'Campo requerido' : null,
              onTap: () async {
                final Category? selectedCategory = await showDialog<Category>(
                  context: context,
                  builder: (_) => const CategorySelectorDialog(),
                );

                if (selectedCategory != null) {
                  setState(() {
                    _categoryIdController.text = selectedCategory.id;
                    // Opcionalmente, puedes mostrar el nombre de la categoría
                    // en lugar del ID para mejor UX
                    _categoryNameController.text = selectedCategory.name;
                  });
                }
              },
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información de Precios',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio de Costo *',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Campo requerido';
                      if (double.tryParse(value) == null)
                        return 'Debe ser un número';
                      if (double.parse(value) < 0) return 'Debe ser mayor a 0';
                      return null;
                    },
                    onChanged: (_) => _calculateMargin(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio de Venta *',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Campo requerido';
                      if (double.tryParse(value) == null)
                        return 'Debe ser un número';
                      if (double.parse(value) < 0) return 'Debe ser mayor a 0';
                      return null;
                    },
                    onChanged: (_) => _calculateMargin(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _buildMarginIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildInventorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inventario',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _reorderPointController,
              decoration: const InputDecoration(
                labelText: 'Punto de Reorden *',
                hintText: 'Cantidad mínima en stock',
                border: OutlineInputBorder(),
                suffixText: 'unidades',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo requerido';
                if (int.tryParse(value) == null)
                  return 'Debe ser un número entero';
                if (int.parse(value) < 0) return 'Debe ser mayor o igual a 0';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarginIndicator() {
    final costText = _costPriceController.text;
    final priceText = _unitPriceController.text;

    if (costText.isEmpty || priceText.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey),
            SizedBox(width: 8),
            Text('Ingresa ambos precios para ver el margen'),
          ],
        ),
      );
    }

    final cost = double.tryParse(costText);
    final price = double.tryParse(priceText);

    if (cost == null || price == null || cost == 0) {
      return const SizedBox.shrink();
    }

    final margin = price - cost;
    final marginPercentage = (margin / cost) * 100;
    final isPositive = margin > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPositive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Margen de Ganancia',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isPositive ? Colors.green.shade800 : Colors.red.shade800,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${margin.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isPositive ? Colors.green.shade800 : Colors.red.shade800,
                  fontSize: 16,
                ),
              ),
              Text(
                '${marginPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color:
                      isPositive ? Colors.green.shade600 : Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic createState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed:
                    createState.isLoading ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: createState.isLoading ? null : _submitForm,
                child:
                    createState.isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(isEditing ? 'Actualizar' : 'Crear Producto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: BarcodeScannerWidget(
              onBarcodeScanned: (barcode) {
                _skuController.text = barcode;
                Navigator.pop(context);
              },
            ),
          ),
    );
  }

  void _calculateMargin() {
    setState(() {}); // Trigger rebuild to update margin indicator
  }

  void _submitForm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (isEditing) {
      // TODO: Implement update product functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actualización de producto próximamente')),
      );
    } else {
      ref
          .read(createProductProvider.notifier)
          .createProduct(
            sku: _skuController.text,
            name: _nameController.text,
            description: _descriptionController.text,
            categoryId: _categoryIdController.text,
            unitPrice: double.parse(_unitPriceController.text),
            costPrice: double.parse(_costPriceController.text),
            reorderPoint: int.parse(_reorderPointController.text),
          );

    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _skuController.clear();
    _nameController.clear();
    _descriptionController.clear();
    _categoryIdController.clear();
    _unitPriceController.clear();
    _costPriceController.clear();
    _reorderPointController.clear();
    setState(() {
      _imageUrl = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
