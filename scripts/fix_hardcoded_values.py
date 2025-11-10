#!/usr/bin/env python3
"""
Script to fix hardcoded values in Flutter codebase:
1. Replace hardcoded colors with AppColors
2. Track changes and generate report
"""

import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple

# Color mappings: hardcoded hex -> AppColors constant
COLOR_MAPPINGS = {
    'Color(0xFFE9692D)': 'AppColors.orange',
    'Color(0xFFF9E3E0)': 'AppColors.lightPeach',
    'Color(0xFFF5DCDC)': 'AppColors.softPink',
    'Color(0xFFFFF6F5)': 'AppColors.cardBackground',
    'Color(0xFF6A2F1A)': 'AppColors.brownHeader',
    'Color(0xFF213447)': 'AppColors.darkBlue',
    'Color(0xFFE64A3A)': 'AppColors.danger',
    'Color(0xFFF0D9D5)': 'AppColors.subtleBorder',
    'Color(0xFFFFF2EF)': 'AppColors.softPeach',
    'Color(0xFFF7E7E5)': 'AppColors.softBorder',
    'Color(0xFFB85A38)': 'AppColors.disabledOrange',
    'Color(0xFFFFECE8)': 'AppColors.badgeBackground',
    # Common variations
    'const Color(0xFFE9692D)': 'AppColors.orange',
    'const Color(0xFFF9E3E0)': 'AppColors.lightPeach',
    'const Color(0xFFF5DCDC)': 'AppColors.softPink',
    'const Color(0xFFFFF6F5)': 'AppColors.cardBackground',
    'const Color(0xFF6A2F1A)': 'AppColors.brownHeader',
    'const Color(0xFF213447)': 'AppColors.darkBlue',
    'const Color(0xFFE64A3A)': 'AppColors.danger',
    'const Color(0xFFF0D9D5)': 'AppColors.subtleBorder',
    'const Color(0xFFFFF2EF)': 'AppColors.softPeach',
    'const Color(0xFFF7E7E5)': 'AppColors.softBorder',
    'const Color(0xFFB85A38)': 'AppColors.disabledOrange',
    'const Color(0xFFFFECE8)': 'AppColors.badgeBackground',
}

class ChangeTracker:
    def __init__(self):
        self.files_modified = 0
        self.total_replacements = 0
        self.changes_by_file: Dict[str, int] = {}
        self.imports_added = 0

    def record_change(self, filepath: str, count: int):
        if count > 0:
            self.files_modified += 1
            self.total_replacements += count
            self.changes_by_file[filepath] = count

    def record_import(self):
        self.imports_added += 1

    def print_report(self):
        print("\n" + "="*60)
        print("HARDCODED VALUE REPLACEMENT REPORT")
        print("="*60)
        print(f"Files Modified: {self.files_modified}")
        print(f"Total Replacements: {self.total_replacements}")
        print(f"Imports Added: {self.imports_added}")
        print("\nTop 10 Files by Changes:")
        sorted_files = sorted(
            self.changes_by_file.items(),
            key=lambda x: x[1],
            reverse=True
        )[:10]
        for filepath, count in sorted_files:
            print(f"  {count:3d} changes: {filepath}")
        print("="*60)

def ensure_theme_import(content: str, filepath: str) -> Tuple[str, bool]:
    """Ensure the file imports the theme package"""
    # Check if already importing theme
    if "import 'package:artisans_circle/core/theme.dart'" in content:
        return content, False

    if "from 'package:artisans_circle/core/theme.dart'" in content:
        return content, False

    # Don't add import to theme.dart itself
    if 'lib/core/theme.dart' in filepath or 'lib/core/theme/' in filepath:
        return content, False

    # Find the right place to add import (after other imports)
    lines = content.split('\n')
    import_index = -1

    for i, line in enumerate(lines):
        if line.strip().startswith('import '):
            import_index = i

    if import_index >= 0:
        # Add after last import
        lines.insert(import_index + 1, "import 'package:artisans_circle/core/theme.dart';")
        return '\n'.join(lines), True

    # If no imports found, add at the beginning
    if lines and lines[0].strip():
        lines.insert(0, "import 'package:artisans_circle/core/theme.dart';")
        lines.insert(1, "")
        return '\n'.join(lines), True

    return content, False

def replace_hardcoded_colors(content: str) -> Tuple[str, int]:
    """Replace hardcoded color values with AppColors constants"""
    replacements = 0

    for hardcoded, app_color in COLOR_MAPPINGS.items():
        count = content.count(hardcoded)
        if count > 0:
            content = content.replace(hardcoded, app_color)
            replacements += count

    return content, replacements

def process_file(filepath: Path, tracker: ChangeTracker, dry_run: bool = False):
    """Process a single Dart file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            original_content = f.read()

        # Replace colors
        modified_content, color_replacements = replace_hardcoded_colors(original_content)

        if color_replacements > 0:
            # Ensure theme import exists
            modified_content, import_added = ensure_theme_import(
                modified_content,
                str(filepath)
            )

            if not dry_run:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(modified_content)

            tracker.record_change(str(filepath), color_replacements)
            if import_added:
                tracker.record_import()

            print(f"✓ {filepath.name}: {color_replacements} replacements")

    except Exception as e:
        print(f"✗ Error processing {filepath}: {e}", file=sys.stderr)

def main():
    import argparse

    parser = argparse.ArgumentParser(
        description='Fix hardcoded values in Flutter codebase'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be changed without modifying files'
    )
    parser.add_argument(
        'path',
        nargs='?',
        default='/Users/user/Desktop/artisans_circle/lib',
        help='Path to search for Dart files'
    )

    args = parser.parse_args()

    if args.dry_run:
        print("DRY RUN MODE - No files will be modified\n")

    tracker = ChangeTracker()
    lib_path = Path(args.path)

    if not lib_path.exists():
        print(f"Error: Path {lib_path} does not exist")
        sys.exit(1)

    # Find all Dart files
    dart_files = list(lib_path.rglob('*.dart'))
    print(f"Found {len(dart_files)} Dart files\n")

    # Process each file
    for filepath in dart_files:
        # Skip generated files
        if '.g.dart' in str(filepath) or '.freezed.dart' in str(filepath):
            continue

        process_file(filepath, tracker, args.dry_run)

    # Print report
    tracker.print_report()

    if args.dry_run:
        print("\nRun without --dry-run to apply changes")

if __name__ == '__main__':
    main()
