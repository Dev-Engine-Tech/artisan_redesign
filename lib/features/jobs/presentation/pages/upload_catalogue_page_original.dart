import 'package:flutter/material.dart';
import 'package:artisans_circle/core/theme.dart';
import 'package:artisans_circle/core/di.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/create_catalog.dart';
import 'package:artisans_circle/features/catalog/domain/usecases/update_catalog.dart';
import 'package:artisans_circle/features/catalog/domain/entities/catalog_item.dart';
import 'package:artisans_circle/features/catalog/data/datasources/catalog_categories_remote_data_source.dart';
// import 'package:image_picker/image_picker.dart';

/// Multi-step upload flow for creating a catalogue entry.
///
/// Steps implemented:
/// 1) Basic info: title, category, description, media upload placeholder
/// 2) Pricing & preferences: min/max price, timeline, preferred skills, materials preference
/// 3) Review: show a preview of the entered data and submit
class UploadCataloguePage extends StatefulWidget {
  final CatalogItem? item; // if provided, editing
  const UploadCataloguePage({super.key, this.item});

  @override
  State<UploadCataloguePage> createState() => _UploadCataloguePageState();
}

class _UploadCataloguePageState extends State<UploadCataloguePage> {
  final PageController _pageController = PageController();
  int _step = 0;

  // Step 1 controllers
  final TextEditingController _titleController = TextEditingController();
  String? _category;
  final TextEditingController _subCategoryIdController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategoryName;
  String? _selectedSubcategoryName;

  // Step 2 controllers
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  String? _timeline;
  final Set<String> _selectedSkills = {};
  bool _materialsIncluded = true;

  // Selected image file paths (for upload)
  final List<String> _media = [];
  // final ImagePicker _picker = ImagePicker(); // Temporarily disabled

  final List<String> _categories = [
    'Electrical and Electronics',
    'Fashion and Textiles',
    'Event Planning',
    'Construction and Masonry',
    'Tech and Communications'
  ];

  final List<String> _timelines = [
    'Less than a week',
    'Less than a month',
    '1 - 3 months',
    '3+ months'
  ];

  final List<String> _skills = [
    'Engineers',
    'Technicians',
    'Electricians',
    'Repairers',
    'Carpenters',
    'Tailors'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _subCategoryIdController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    if (it != null) {
      _titleController.text = it.title;
      _descriptionController.text = it.description;
      if (it.priceMin != null)
        _minPriceController.text = it.priceMin.toString();
      if (it.priceMax != null)
        _maxPriceController.text = it.priceMax.toString();

      // Initialize existing images
      if (it.imageUrl != null && it.imageUrl!.isNotEmpty) {
        _media.add(it.imageUrl!);
      }

      // Map numeric timeline values to dropdown options
      if (it.projectTimeline != null) {
        final days = int.tryParse(it.projectTimeline!);
        if (days != null) {
          if (days <= 7) {
            _timeline = 'Less than a week';
          } else if (days <= 30) {
            _timeline = 'Less than a month';
          } else if (days <= 90) {
            _timeline = '1 - 3 months';
          } else {
            _timeline = '3+ months';
          }
        } else {
          // If it's already a text value that matches our options, use it
          if (_timelines.contains(it.projectTimeline)) {
            _timeline = it.projectTimeline;
          }
        }
      }
    }
  }

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
      _pageController.animateToPage(_step,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(_step,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final subCategoryId = _subCategoryIdController.text.trim().isEmpty
        ? '1'
        : _subCategoryIdController.text.trim();
    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter title and description')));
      return;
    }
    int? toInt(String s) => int.tryParse(s.replaceAll(',', '').trim());

    // Convert timeline text back to numeric value for API
    String? timelineValue = _timeline;
    if (_timeline != null) {
      switch (_timeline) {
        case 'Less than a week':
          timelineValue = '7';
          break;
        case 'Less than a month':
          timelineValue = '30';
          break;
        case '1 - 3 months':
          timelineValue = '90';
          break;
        case '3+ months':
          timelineValue = '120';
          break;
        default:
          timelineValue = _timeline; // Keep original if not recognized
      }
    }

    try {
      if (widget.item == null) {
        final create = getIt<CreateCatalog>();
        await create(
          title: title,
          subCategoryId: subCategoryId,
          description: desc,
          priceMin: toInt(_minPriceController.text),
          priceMax: toInt(_maxPriceController.text),
          projectTimeline: timelineValue,
          imagePaths: _media,
        );
      } else {
        final update = getIt<UpdateCatalog>();
        await update(
          id: widget.item!.id,
          title: title,
          subCategoryId: subCategoryId,
          description: desc,
          priceMin: toInt(_minPriceController.text),
          priceMax: toInt(_maxPriceController.text),
          projectTimeline: timelineValue,
          newImagePaths: _media,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.item == null
              ? 'Catalogue submitted'
              : 'Catalogue updated')));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to submit: $e')));
    }
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.softPink,
              borderRadius: BorderRadius.circular(10)),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: _back,
          ),
        ),
      ),
      title: const Text('Upload Projects',
          style: TextStyle(color: Colors.black87)),
    );
  }

  Widget _stepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= _step;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i == 2 ? 0 : 8),
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppColors.orange : AppColors.subtleBorder,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _step1() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        const SizedBox(height: 8),
        const Text('Project Title',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            hintText: 'what are you working on ?',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.softBorder),
            color: AppColors.cardBackground,
          ),
          child: const Text(
              'Title Samples\n• Modern 4-seater dinning table.\n• Eternal elegance wedding gown.\n• Metal staircases handrails.'),
        ),
        const SizedBox(height: 18),
        const Text('Select project category',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _category,
          items: _categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _category = v),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            hintText: 'Select project category',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        const SizedBox(height: 12),
        const Text('Sub-category',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickSubcategory,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(_selectedSubcategoryName ??
                        'Select sub-category (tap to choose)')),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Project Description',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            hintText: 'Describe what your project is',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppColors.softBorder, style: BorderStyle.solid),
            color: AppColors.cardBackground,
          ),
          child: const Text(
              'Descriptions should be specific to the product\n• Clear description of what your preferences and specifications are\n• Details about how you and your team likes to work'),
        ),
        const SizedBox(height: 18),
        const Text('Attached File (Optional)',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            // final files = await _picker.pickMultiImage(); // Temporarily disabled
            // if (files != null && files.isNotEmpty) {
            //   setState(() => _media.addAll(files.map((f) => f.path)));
            // }
          },
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.softBorder,
                  style: BorderStyle.solid,
                  width: 1.5),
              color: Colors.white,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.perm_media_outlined,
                      color: AppColors.orange, size: 36),
                  const SizedBox(height: 8),
                  const Text(
                      'Copy and paste images, videos or any file from your device.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      // final files = await _picker.pickMultiImage(); // Temporarily disabled
                      // if (files != null && files.isNotEmpty) {
                      //   setState(() => _media.addAll(files.map((f) => f.path)));
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: AppColors.orange),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Upload Media',
                        style: TextStyle(color: AppColors.orange)),
                  )
                ],
              ),
            ),
          ),
        ),
        if (_media.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              children: _media.map((m) {
                String displayText =
                    m.startsWith('http') ? 'Existing Image' : m.split('/').last;
                return Chip(
                    label: Text(displayText),
                    onDeleted: () => setState(() => _media.remove(m)));
              }).toList(),
            ),
          ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9A4B20),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Proceed'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _step2() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        const SizedBox(height: 8),
        const Text('Price Range',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'NGN ',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  hintText: '100,000',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: 'NGN ',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  hintText: '100,000',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text('Product Timeline',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _timeline,
          items: _timelines
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (v) => setState(() => _timeline = v),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardBackground,
            hintText: 'Select preferable timeline',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Select preferred skill',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10)),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((s) {
              final selected = _selectedSkills.contains(s);
              return ChoiceChip(
                label: Text(s),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    _selectedSkills.add(s);
                  } else {
                    _selectedSkills.remove(s);
                  }
                }),
                selectedColor: const Color(0xFF9A4B20),
                backgroundColor: Colors.white,
                labelStyle:
                    TextStyle(color: selected ? Colors.white : Colors.black87),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Materials Preference',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              // ignore: deprecated_member_use
              RadioListTile<bool>(
                value: true,
                // ignore: deprecated_member_use
                groupValue: _materialsIncluded,
                // ignore: deprecated_member_use
                onChanged: (v) =>
                    setState(() => _materialsIncluded = v ?? true),
                title: const Text(
                    'Include a preliminary list of materials (names, sizes, quantities) with your application.'),
              ),
              // ignore: deprecated_member_use
              RadioListTile<bool>(
                value: false,
                // ignore: deprecated_member_use
                groupValue: _materialsIncluded,
                // ignore: deprecated_member_use
                onChanged: (v) =>
                    setState(() => _materialsIncluded = v ?? false),
                title: const Text('No materials are needed for this project.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9A4B20),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Proceed'),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _pickSubcategory() async {
    try {
      final ds = getIt<CatalogCategoriesRemoteDataSource>();
      final groups = await ds.fetchCategories();
      if (!mounted) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (c) {
          return Container(
            height: MediaQuery.of(c).size.height * 0.8,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Sub-category',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: groups.length,
                    itemBuilder: (ctx, i) {
                      final g = groups[i];
                      return ExpansionTile(
                        title: Text(g.name),
                        children: g.subcategories
                            .map((s) => ListTile(
                                  title: Text(s.name),
                                  onTap: () {
                                    _subCategoryIdController.text = s.id;
                                    _selectedCategoryName = g.name;
                                    _selectedSubcategoryName =
                                        '${g.name} • ${s.name}';
                                    Navigator.of(ctx).pop();
                                    setState(() {});
                                  },
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')));
    }
  }

  Widget _step3() {
    // Simple read-only preview
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 180,
            color: AppColors.softPink,
            child: Center(
              child: _media.isEmpty
                  ? const Icon(Icons.image_outlined,
                      size: 56, color: AppColors.orange)
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _media.map((m) => Chip(label: Text(m))).toList()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
            _titleController.text.isEmpty
                ? 'Untitled project'
                : _titleController.text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(_category ?? 'Uncategorized',
            style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.softBorder),
          ),
          child: Text('Duration: ${_timeline ?? 'Not specified'}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.brownHeader)),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.softBorder),
          ),
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
                _descriptionController.text.isEmpty
                    ? 'No description provided.'
                    : _descriptionController.text,
                style: const TextStyle(color: Colors.black54)),
          ]),
        ),
        const SizedBox(height: 14),
        const Text('Skills', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSkills.isEmpty
                ? [const Text('No skills selected')]
                : _selectedSkills.map((s) => Chip(label: Text(s))).toList()),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: () {
            // edit — go back to first step
            setState(() {
              _step = 0;
            });
            _pageController.jumpToPage(0);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF213447),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Edit'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9A4B20),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Submit'),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _stepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _step1(),
                _step2(),
                _step3(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
