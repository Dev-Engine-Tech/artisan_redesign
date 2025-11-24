import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../core/components/components.dart';
import '../../../../core/di.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/subscription_service.dart';
import '../../domain/entities/business_settings.dart';
import '../../domain/repositories/business_settings_repository.dart';
import '../widgets/business_settings_widgets.dart';
import '../widgets/brand_color_palette_dialog.dart';

class BusinessSettingsPage extends StatefulWidget {
  const BusinessSettingsPage({super.key});

  @override
  State<BusinessSettingsPage> createState() => _BusinessSettingsPageState();
}

class _BusinessSettingsPageState extends State<BusinessSettingsPage> {
  late final BusinessSettingsRepository _repository;
  BusinessSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingLogo = false;

  // Form fields
  final _businessAddressController = TextEditingController();
  final _cacNumberController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  String? _primaryColor;
  String? _secondaryColor;
  InvoiceStyle _selectedInvoiceStyle = InvoiceStyle.classic;
  SubscriptionPlan _plan = SubscriptionPlan.unknown;

  @override
  void initState() {
    super.initState();
    _repository = getIt<BusinessSettingsRepository>();
    _loadSettings();
    _loadPlan();
  }

  @override
  void dispose() {
    _businessAddressController.dispose();
    _cacNumberController.dispose();
    _taxIdController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => _isLoading = true);
      final settings = await _repository.getBusinessSettings();
      setState(() {
        _settings = settings;
        _businessAddressController.text = settings.businessAddress ?? '';
        _cacNumberController.text = settings.cacNumber ?? '';
        _taxIdController.text = settings.taxId ?? '';
        _registrationNumberController.text = settings.registrationNumber ?? '';
        _primaryColor = settings.primaryColor;
        _secondaryColor = settings.secondaryColor;
        _selectedInvoiceStyle = settings.invoiceStyle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    try {
      setState(() => _isSaving = true);

      final updatedSettings = BusinessSettings(
        id: _settings?.id ?? '',
        companyLogo: _settings?.companyLogo,
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        businessAddress: _businessAddressController.text.trim().isEmpty
            ? null
            : _businessAddressController.text.trim(),
        invoiceStyle: _selectedInvoiceStyle,
        cacNumber: _cacNumberController.text.trim().isEmpty
            ? null
            : _cacNumberController.text.trim(),
        taxId: _taxIdController.text.trim().isEmpty
            ? null
            : _taxIdController.text.trim(),
        registrationNumber: _registrationNumberController.text.trim().isEmpty
            ? null
            : _registrationNumberController.text.trim(),
        additionalDocuments: _settings?.additionalDocuments,
        createdAt: _settings?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await _repository.updateBusinessSettings(updatedSettings);

      setState(() {
        _settings = saved;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _loadPlan() async {
    try {
      final sub = getIt<SubscriptionService>();
      final plan = await sub.getCurrentPlan();
      setState(() => _plan = plan);
      // Enforce style per plan
      if (_plan == SubscriptionPlan.free) {
        _selectedInvoiceStyle = InvoiceStyle.modern;
      } else if (_plan == SubscriptionPlan.bronze) {
        if (!_allowedBronze.contains(_selectedInvoiceStyle)) {
          _selectedInvoiceStyle = InvoiceStyle.modern;
        }
      }
    } catch (_) {}
  }

  List<InvoiceStyle> get _allowedStyles {
    switch (_plan) {
      case SubscriptionPlan.free:
        return [InvoiceStyle.modern];
      case SubscriptionPlan.bronze:
        return _allowedBronze;
      case SubscriptionPlan.silver:
      case SubscriptionPlan.gold:
        return InvoiceStyle.values;
      case SubscriptionPlan.unknown:
        return InvoiceStyle.values;
    }
  }

  static const List<InvoiceStyle> _allowedBronze = [
    InvoiceStyle.classic,
    InvoiceStyle.modern,
    InvoiceStyle.minimal,
  ];

  Future<void> _uploadLogo() async {
    try {
      final picker = ImagePickerService();
      final path = await picker.pickAndCropImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (path == null) return;

      setState(() => _isUploadingLogo = true);
      final logoUrl = await _repository.uploadCompanyLogo(path);

      setState(() {
        _settings = _settings?.copyWith(companyLogo: logoUrl);
        _isUploadingLogo = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logo uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingLogo = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading logo: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _selectPrimaryColor() async {
    final color = await showDialog<String>(
      context: context,
      builder: (_) => BrandColorPaletteDialog(
        title: 'Select Primary Color',
        initialColor: _primaryColor,
      ),
    );

    if (color != null) {
      setState(() => _primaryColor = color);
    }
  }

  Future<void> _selectSecondaryColor() async {
    final color = await showDialog<String>(
      context: context,
      builder: (_) => BrandColorPaletteDialog(
        title: 'Select Secondary Color',
        initialColor: _secondaryColor,
      ),
    );

    if (color != null) {
      setState(() => _secondaryColor = color);
    }
  }

  void _showInvoiceStylePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Invoice Style',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _allowedStyles.length,
                itemBuilder: (context, index) {
                  final style = _allowedStyles[index];
                  return InvoiceStyleCard(
                    style: style,
                    isSelected: _selectedInvoiceStyle == style,
                    onTap: () {
                      setState(() => _selectedInvoiceStyle = style);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPeach,
      appBar: AppBar(
        title: const Text('Business Settings'),
        backgroundColor: AppColors.brownHeader,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSettings,
              tooltip: 'Save Settings',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo Section
                  SettingsSectionCard(
                    title: 'Company Logo',
                    subtitle:
                        'Upload your company logo for invoices and documents',
                    child: ImageUploadSection(
                      onUpload: _uploadLogo,
                      label: 'Company Logo',
                      imageUrl: _settings?.companyLogo,
                      isLoading: _isUploadingLogo,
                      onRemove: _settings?.companyLogo != null
                          ? () {
                              setState(() {
                                _settings =
                                    _settings?.copyWith(companyLogo: null);
                              });
                            }
                          : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Theme Colors Section
                  SettingsSectionCard(
                    title: 'Brand Colors',
                    subtitle: 'Customize your invoice and document colors',
                    child: Column(
                      children: [
                        ColorSelectionCard(
                          label: 'Primary Color',
                          onTap: _selectPrimaryColor,
                          hexColor: _primaryColor,
                        ),
                        const SizedBox(height: 12),
                        ColorSelectionCard(
                          label: 'Secondary Color',
                          onTap: _selectSecondaryColor,
                          hexColor: _secondaryColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Invoice Style Section with plan enforcement
                  SettingsSectionCard(
                    title: 'Invoice Style',
                    subtitle: _plan == SubscriptionPlan.free
                        ? 'Fixed to Modern style on Free plan'
                        : 'Choose how your invoices look',
                    child: InkWell(
                      onTap: _plan == SubscriptionPlan.free
                          ? null
                          : _showInvoiceStylePicker,
                      borderRadius: AppRadius.radiusMD,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: AppRadius.radiusMD,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.design_services_outlined,
                              size: 32,
                              color: AppColors.orange,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Current Style',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedInvoiceStyle.name[0]
                                            .toUpperCase() +
                                        _selectedInvoiceStyle.name.substring(1),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_plan != SubscriptionPlan.free)
                              const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Business Address Section
                  SettingsSectionCard(
                    title: 'Business Address',
                    subtitle: 'Your business address for invoices',
                    child: TextField(
                      controller: _businessAddressController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your business address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Registration Documents Section
                  SettingsSectionCard(
                    title: 'Registration Documents',
                    subtitle: 'Business registration and tax information',
                    child: Column(
                      children: [
                        TextField(
                          controller: _cacNumberController,
                          decoration: const InputDecoration(
                            labelText: 'CAC Number',
                            hintText: 'e.g., RC 123456',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _taxIdController,
                          decoration: const InputDecoration(
                            labelText: 'Tax ID / TIN',
                            hintText: 'e.g., 12345678-0001',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _registrationNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Registration Number',
                            hintText: 'Other registration number (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Save Settings',
                      onPressed: _isSaving ? null : _saveSettings,
                      isLoading: _isSaving,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
