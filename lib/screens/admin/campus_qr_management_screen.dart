import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class CampusQRManagementScreen extends StatefulWidget {
  const CampusQRManagementScreen({super.key});

  @override
  State<CampusQRManagementScreen> createState() =>
      _CampusQRManagementScreenState();
}

class _CampusQRManagementScreenState extends State<CampusQRManagementScreen> {
  List<dynamic> _qrCodes = [];
  bool _isLoading = false;
  final _campusNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQRCodes();
  }

  @override
  void dispose() {
    _campusNameController.dispose();
    super.dispose();
  }

  Future<void> _loadQRCodes() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('${ApiConfig.baseUrl}/campus/qr');
      setState(() {
        _qrCodes = response['qrCodes'] ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading QR codes: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createQRCode() async {
    if (_campusNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter campus name')),
      );
      return;
    }

    try {
      await ApiService.post(
        '${ApiConfig.baseUrl}/campus/qr',
        {'campusName': _campusNameController.text.trim()},
      );

      if (mounted) {
        _campusNameController.clear();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code created successfully!')),
        );
        _loadQRCodes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating QR code: $e')),
        );
      }
    }
  }

  Future<void> _deactivateQRCode(String qrId) async {
    try {
      await ApiService.patch(
        '${ApiConfig.baseUrl}/campus/qr/$qrId/deactivate',
        {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR code deactivated')),
        );
        _loadQRCodes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deactivating QR code: $e')),
        );
      }
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Campus QR Code'),
        content: TextField(
          controller: _campusNameController,
          decoration: const InputDecoration(
            labelText: 'Campus Name',
            hintText: 'e.g., University of Nairobi',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _createQRCode,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus QR Codes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create QR'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _qrCodes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No QR codes yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first campus QR code',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadQRCodes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _qrCodes.length,
                    itemBuilder: (context, index) {
                      final qr = _qrCodes[index];
                      final isActive = qr['is_active'] ?? false;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.qr_code,
                              color: isActive ? Colors.green : Colors.grey,
                            ),
                          ),
                          title: Text(
                            qr['campus_name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Code: ${qr['qr_code']?.substring(0, 8)}...',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: isActive
                              ? IconButton(
                                  icon: const Icon(Icons.block, color: Colors.red),
                                  onPressed: () => _deactivateQRCode(qr['qr_id']),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
