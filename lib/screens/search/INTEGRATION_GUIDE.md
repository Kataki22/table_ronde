# Search Integration Guide for ChatScreen

This guide explains how to integrate the search functionality into the ChatScreen.

## Required Changes to ChatScreen

### 1. Add State Variables

```dart
bool _isSearchOpen = false;
```

### 2. Wrap ChatScreen with MessageSearchProvider

In the parent widget or main.dart, ensure MessageSearchProvider is available:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => MessageSearchProvider()),
    // ... other providers
  ],
  child: ChatScreen(),
)
```

### 3. Modify AppBar Actions

Add a search icon button to the AppBar actions:

```dart
actions: [
  // Search button
  IconButton(
    icon: Icon(
      _isSearchOpen ? Icons.close : Icons.search,
      color: context.themeColors.textPrimary,
    ),
    onPressed: () {
      setState(() {
        _isSearchOpen = !_isSearchOpen;
      });
      if (!_isSearchOpen) {
        // Clear search when closing
        context.read<MessageSearchProvider>().clear();
      }
    },
  ),
  // ... existing phone and video buttons
],
```

### 4. Add Search Bar to AppBar Title

Replace the existing title with a conditional that shows either the chat info or search bar:

```dart
title: _isSearchOpen
    ? ChatSearchBar(
        isOpen: _isSearchOpen,
        onSearchChanged: (query) {
          context.read<MessageSearchProvider>().search(query, _chat.id);
        },
        onClose: () {
          setState(() {
            _isSearchOpen = false;
          });
          context.read<MessageSearchProvider>().clear();
        },
      )
    : InkWell(
        // ... existing chat info widget
      ),
```

### 5. Add Search Overlay to Body

Wrap the existing body with a Stack and add the SearchOverlay:

```dart
body: Stack(
  children: [
    // Existing chat body
    Column(
      children: [
        // ... existing message list and input
      ],
    ),
    
    // Search overlay (shown when search is active)
    if (_isSearchOpen)
      SearchOverlay(
        onResultTap: (messageIndex) {
          // Scroll to the message at messageIndex
          // You'll need to implement scrolling logic based on your message list
          setState(() {
            _isSearchOpen = false;
          });
          context.read<MessageSearchProvider>().clear();
          
          // Example scroll logic (adjust based on your implementation):
          // _scrollController.animateTo(
          //   messageIndex * estimatedMessageHeight,
          //   duration: Duration(milliseconds: 300),
          //   curve: Curves.easeInOut,
          // );
        },
      ),
  ],
),
```

### 6. Import Required Files

Add these imports at the top of chat_screen.dart:

```dart
import '../widgets/search/chat_search_bar.dart';
import '../screens/search/search_overlay.dart';
import '../providers/message_search_provider.dart';
```

## Testing the Integration

1. Open a chat conversation
2. Tap the search icon in the AppBar
3. The search bar should animate in
4. Type a query (at least 2 characters)
5. Results should appear with highlighting
6. Use filter chips to filter by message type
7. Navigate between results using up/down arrows
8. Tap a result to jump to that message
9. Close search to return to normal chat view

## Notes

- The search is case-insensitive
- Minimum 2 characters required to trigger search
- Search works across all message types
- Filters can be combined (multiple types selected)
- Navigation wraps around (after last result, goes to first)
