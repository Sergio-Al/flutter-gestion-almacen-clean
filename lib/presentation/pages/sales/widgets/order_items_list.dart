import 'package:flutter/material.dart';
import '../../../../domain/entities/order_item.dart';

class OrderItemsList extends StatelessWidget {
  final List<OrderItem> items;
  final bool showActions;
  final ValueChanged<OrderItem>? onEditItem;
  final ValueChanged<OrderItem>? onRemoveItem;
  final VoidCallback? onAddItem;

  const OrderItemsList({
    super.key,
    required this.items,
    this.showActions = false,
    this.onEditItem,
    this.onRemoveItem,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              child: Text(
                'Artículos del Pedido',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (showActions && onAddItem != null)
              TextButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Items List
        if (items.isEmpty)
          _buildEmptyState(context)
        else
          Column(
            children: [
              // Headers for desktop/tablet
              if (MediaQuery.of(context).size.width > 600)
                _buildDesktopHeader(context),
              
              // Items
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _buildItemRow(context, item, index);
              }),
              
              const Divider(),
              _buildTotalRow(context),
            ],
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay artículos en este pedido',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          if (showActions && onAddItem != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAddItem,
              icon: const Icon(Icons.add),
              label: const Text('Agregar Artículo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text(
              'Producto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Cantidad',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Precio Unit.',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const Expanded(
            flex: 1,
            child: Text(
              'Subtotal',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          if (showActions)
            const SizedBox(
              width: 80,
              child: Text(
                'Acciones',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, OrderItem item, int index) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    
    if (isDesktop) {
      return _buildDesktopItemRow(context, item, index);
    } else {
      return _buildMobileItemRow(context, item, index);
    }
  }

  Widget _buildDesktopItemRow(BuildContext context, OrderItem item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (item.productDescription?.isNotEmpty == true)
                  Text(
                    item.productDescription!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${item.unitPrice.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (showActions)
            SizedBox(
              width: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onEditItem != null)
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: () => onEditItem!(item),
                      tooltip: 'Editar',
                    ),
                  if (onRemoveItem != null)
                    IconButton(
                      icon: const Icon(Icons.delete, size: 18),
                      onPressed: () => onRemoveItem!(item),
                      tooltip: 'Eliminar',
                      color: Colors.red[600],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileItemRow(BuildContext context, OrderItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (item.productDescription?.isNotEmpty == true)
                        Text(
                          item.productDescription!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                if (showActions)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEditItem != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => onEditItem!(item),
                        ),
                      if (onRemoveItem != null)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: () => onRemoveItem!(item),
                          color: Colors.red[600],
                        ),
                    ],
                  ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Quantity and Price Info
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Cantidad', '${item.quantity}'),
                ),
                Expanded(
                  child: _buildInfoItem('Precio Unit.', '\$${item.unitPrice.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Subtotal',
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    isHighlighted: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? Colors.green[700] : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total ($totalItems artículos)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}
