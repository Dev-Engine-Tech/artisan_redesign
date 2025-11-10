#!/usr/bin/env python3
"""
Script to split large files into modular components
"""

import os
import re
from pathlib import Path

def split_messages_flow():
    """Split messages_flow.dart into separate page files"""
    source_file = Path('/Users/user/Desktop/artisans_circle/lib/features/messages/presentation/pages/messages_flow.dart')

    if not source_file.exists():
        print(f"Error: {source_file} not found")
        return

    content = source_file.read_text()

    # Find the split points
    # MessagesListPage starts around line 36
    # ChatPage starts around line 272

    # Extract MessagesListPage (from class MessagesListPage to before class ChatPage)
    messages_list_match = re.search(
        r'(class MessagesListPage.*?(?=class ChatPage|class _ChatPageState|\Z))',
        content,
        re.DOTALL
    )

    # Extract ChatPage (from class ChatPage to end, excluding widgets)
    chat_page_match = re.search(
        r'(class ChatPage.*?\n\})',
        content,
        re.DOTALL
    )

    print(f"Analyzing {source_file}...")
    print(f"File size: {len(content)} characters, {len(content.splitlines())} lines")

    # For now, just report what we found
    if messages_list_match:
        print(f"Found MessagesListPage: {len(messages_list_match.group(0))} chars")
    if chat_page_match:
        print(f"Found ChatPage: {len(chat_page_match.group(0))} chars")

    return True

def main():
    print("Large File Splitter")
    print("=" * 60)

    split_messages_flow()

    print("=" * 60)
    print("Analysis complete. Manual refactoring recommended.")

if __name__ == '__main__':
    main()
