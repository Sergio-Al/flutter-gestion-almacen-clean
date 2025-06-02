import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final bool enabled;

  const BarcodeScannerWidget({
    Key? key,
    required this.onBarcodeScanned,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isScanning = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Escanear Código de Barras',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Manual barcode input field
          TextField(
            controller: _barcodeController,
            enabled: widget.enabled,
            decoration: InputDecoration(
              labelText: 'Código de barras / SKU',
              hintText: 'Ingresa o escanea el código',
              prefixIcon: const Icon(Icons.qr_code),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_barcodeController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _barcodeController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  IconButton(
                    onPressed: widget.enabled ? _startScanning : null,
                    icon: Icon(
                      _isScanning ? Icons.stop : Icons.qr_code_scanner,
                      color: _isScanning ? Colors.red : Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.onBarcodeScanned(value);
                _barcodeController.clear();
              }
            },
            onChanged: (value) {
              setState(() {});
            },
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.enabled && _barcodeController.text.isNotEmpty
                      ? () {
                          widget.onBarcodeScanned(_barcodeController.text);
                          _barcodeController.clear();
                        }
                      : null,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.enabled ? _startScanning : null,
                  icon: Icon(_isScanning ? Icons.stop : Icons.camera_alt),
                  label: Text(_isScanning ? 'Detener' : 'Escanear'),
                ),
              ),
            ],
          ),
          
          if (_isScanning) ...[
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cámara del escáner aquí',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Apunta la cámara al código de barras',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
    
    if (_isScanning) {
      // TODO: Implement actual barcode scanning using a package like mobile_scanner
      // For now, simulate a scan after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isScanning) {
          _simulateScan();
        }
      });
    }
  }

  void _simulateScan() {
    // Simulate a successful scan
    const sampleBarcode = '1234567890123';
    widget.onBarcodeScanned(sampleBarcode);
    setState(() {
      _isScanning = false;
    });
    
    // Show feedback
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código escaneado: $sampleBarcode'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
