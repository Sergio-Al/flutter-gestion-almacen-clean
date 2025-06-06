import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gestion_almacen_stock/presentation/providers/product_providers.dart';
import '../../../domain/entities/product.dart';
import '../../../core/providers/repository_providers.dart';
import 'widgets/product_grid_widget.dart';
import 'widgets/product_image_widget.dart';
import 'product_detail_page.dart';
import 'add_edit_product_page.dart';
import 'product_search_page.dart';

class ProductsListPage extends ConsumerStatefulWidget {
  const ProductsListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends ConsumerState<ProductsListPage> {
  String _selectedFilter = 'all';
  bool _showGridView = true;

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final lowStockProductsAsync = ref.watch(lowStockProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          // View Toggle
          IconButton(
            onPressed: () {
              setState(() {
                _showGridView = !_showGridView;
              });
            },
            icon: Icon(_showGridView ? Icons.list : Icons.grid_view),
            tooltip: _showGridView ? 'Vista de lista' : 'Vista de cuadrícula',
          ),
          // Search
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductSearchPage(),
                ),
              );
            },
            icon: const Icon(Icons.search),
            tooltip: 'Buscar productos',
          ),
          // Add Product
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditProductPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Agregar producto',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filtros: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('Todos', 'all'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Stock Bajo', 'low_stock'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Sin Stock', 'out_of_stock'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Activos', 'active'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Products Content
          Expanded(
            child: _buildProductsList(productsAsync, lowStockProductsAsync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditProductPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Agregar producto',
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? value : 'all';
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildProductsList(
    AsyncValue<List<Product>> productsAsync,
    AsyncValue<List<Product>> lowStockProductsAsync,
  ) {
    return productsAsync.when(
      data: (products) {
        final filteredProducts = _getFilteredProducts(products, lowStockProductsAsync);
        
        if (_showGridView) {
          return ProductGridWidget(
            products: filteredProducts,
            onProductTap: (product) => _navigateToProductDetail(product),
            onProductEdit: (product) => _navigateToEditProduct(product),
            onProductDelete: (product) => _showDeleteDialog(product),
          );
        } else {
          return _buildListView(filteredProducts);
        }
      },
      loading: () => ProductGridWidget(
        products: const [],
        isLoading: true,
      ),
      error: (error, stack) => ProductGridWidget(
        products: const [],
        error: error.toString(),
      ),
    );
  }

  List<Product> _getFilteredProducts(
    List<Product> allProducts,
    AsyncValue<List<Product>> lowStockProductsAsync,
  ) {
    switch (_selectedFilter) {
      case 'low_stock':
        return lowStockProductsAsync.when(
          data: (products) => products,
          loading: () => [],
          error: (_, __) => [],
        );
      case 'out_of_stock':
        // TODO: Implement out of stock filter with actual stock data
        return allProducts.take(3).toList(); // Mock implementation
      case 'active':
        return allProducts; // All products are considered active for now
      default:
        return allProducts;
    }
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: 50,
                height: 50,
                child: ProductImageWidget(
                  productId: product.id,
                  imageUrl: product.imageUrl,
                  size: 50,
                ),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU: ${product.sku}'),
                Text('\$${product.unitPrice.toStringAsFixed(2)}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'view':
                    _navigateToProductDetail(product);
                    break;
                  case 'edit':
                    _navigateToEditProduct(product);
                    break;
                  case 'delete':
                    _showDeleteDialog(product);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('Ver detalles'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _navigateToProductDetail(product),
          ),
        );
      },
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productId: product.id),
      ),
    );
  }

  void _navigateToEditProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductPage(product: product),
      ),
    );
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${product.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${product.name}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              
              final productRepository = ref.read(productRepositoryProvider);
              
              // Mostrar indicador de carga
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Eliminando producto...'))
              );
              
              // Eliminar el producto usando el repositorio
              productRepository.deleteProduct(product.id)
                .then((_) {
                  // Invalidar los providers para refrescar la UI
                  ref.invalidate(productsProvider);
                  ref.invalidate(productCountProvider);
                  ref.invalidate(lowStockProductsProvider);
                  
                  // Mostrar mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto eliminado con éxito'))
                  );
                })
                .catchError((e) {
                  // Mostrar mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    )
                  );
                });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
