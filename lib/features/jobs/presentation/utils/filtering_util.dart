class FilteringField {
  static const String postedDate = 'posted_date';
  static const String workMode = 'work_mode';
  static const String budgetType = 'budget_type';
  static const String duration = 'duration';
}

/// Maps human-readable filter labels to API query values,
/// mirroring the upstream artisan_app implementation.
String filteringValue(String field, List<String> input) {
  const mappings = {
    FilteringField.postedDate: {
      'Less than 24hrs': '<day',
      'Less than a week': '<week',
      'Less than a month': '<month',
      'More than a month': '>month',
    },
    FilteringField.workMode: {
      'On-site': 'onsite',
      'Hybrid': 'hybrid',
      'Remote': 'remote',
    },
    FilteringField.budgetType: {
      'Fixed Price': 'fixed',
      'Weekly Pay': 'weekly',
      'Daily Pay': 'daily',
    },
    FilteringField.duration: {
      'A day': 'day',
      'Less than a week': '<week',
      'Less than a month': '<month',
      '1 to 3 months': '<3months',
      'More than 3 months': '>3months',
    },
  };

  return mappings[field]?[input.isNotEmpty ? input.first : ''] ?? '';
}

bool isFilterSelected(List<String> selectedFilter) => selectedFilter.isNotEmpty;
