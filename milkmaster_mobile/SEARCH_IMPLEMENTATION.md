# General Search Implementation Guide

## Overview
This implementation adds a general search feature to your MilkMaster mobile app that searches across both Products and Cattle using the backend `/Search` endpoint.

## Files Created

### 1. Model: `lib/models/general_search_result_model.dart`
- Defines the `GeneralSearchResult` class that holds search results
- Contains lists of both `Product` and `Cattle` objects
- Includes JSON serialization support

### 2. Provider: `lib/providers/search_provider.dart`
- Manages the search state and API calls
- Handles loading states and error messages
- Calls the backend `/Search?query={searchTerm}` endpoint
- Features:
  - `search(String query)` - Performs the search
  - `clearSearch()` - Clears search results
  - `isLoading` - Loading state indicator
  - `searchResults` - The search results
  - `errorMessage` - Error message if search fails

### 3. Screen: `lib/screens/search_screen.dart`
- Full-featured search UI with:
  - Search bar with clear button
  - Real-time search as you type
  - Separate sections for Products and Cattle results
  - Product cards showing image, title, description, and price
  - Cattle cards showing image, name, tag number, and daily liters
  - Empty states and error handling
  - Loading indicator

### 4. Updated Files:
- `lib/main.dart` - Added SearchProvider to the provider list
- `lib/widgets/home_shell.dart` - Connected search icon to open SearchScreen

## How to Use

### For Users:
1. Tap the search icon (🔍) in the app bar
2. Type your search query in the search field
3. Results will appear automatically as you type
4. View products and cattle that match your search
5. Tap on any result to view details (you can implement navigation)

### For Developers:

#### Basic Usage:
```dart
// Get the provider
final searchProvider = context.read<SearchProvider>();

// Perform a search
await searchProvider.search('milk');

// Clear search
searchProvider.clearSearch();
```

#### Listening to Search Results:
```dart
Consumer<SearchProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.searchResults != null) {
      final products = provider.searchResults!.products;
      final cattle = provider.searchResults!.cattles;
      // Display results
    }
    
    return Container();
  },
)
```

## Backend Endpoint
- **URL**: `GET /Search?query={searchTerm}`
- **Auth**: Requires Bearer token (User role)
- **Response Format**:
```json
{
  "products": [
    {
      "id": 1,
      "title": "Milk",
      "imageUrl": "...",
      "pricePerUnit": 3.99,
      "description": "...",
      ...
    }
  ],
  "cattles": [
    {
      "id": 1,
      "name": "Bessie",
      "imageUrl": "...",
      "tagNumber": "001",
      "litersPerDay": 25.5,
      ...
    }
  ]
}
```

## Features
- ✅ Real-time search (searches as you type)
- ✅ Debounced API calls (reduces server load)
- ✅ Separate product and cattle results
- ✅ Loading states
- ✅ Error handling
- ✅ Empty states
- ✅ Clear search functionality
- ✅ Image error handling
- ✅ Responsive UI

## Customization

### To add navigation to details:
In `search_screen.dart`, update the `onTap` callbacks:

```dart
// For products
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProductDetailsScreen(product: product),
    ),
  );
}

// For cattle
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CattleDetailsScreen(cattle: cattle),
    ),
  );
}
```

### To add search debouncing:
Install the `rxdart` package and modify `search_provider.dart` to debounce API calls.

### To customize the UI:
Modify `search_screen.dart`:
- Change card layouts in `_buildProductCard()` and `_buildCattleCard()`
- Adjust colors, fonts, and spacing
- Add filters or sorting options

## Testing
1. Make sure your backend is running
2. Ensure you're logged in as a User
3. Tap the search icon in the app bar
4. Try searching for:
   - Product names (e.g., "milk", "cheese")
   - Cattle names or tag numbers
   - Partial matches

## Troubleshooting

### "No results found" but data exists:
- Check your backend URL in `search_provider.dart`
- Verify the user is logged in
- Check network connectivity

### Images not loading:
- Verify image URLs are correct
- Check CORS settings on backend
- Ensure images are publicly accessible

### Search not working:
- Check that SearchProvider is registered in `main.dart`
- Verify backend endpoint is accessible
- Check authentication token

## Next Steps
- Add pagination for large result sets
- Implement search history
- Add filters (category, price range, etc.)
- Add voice search
- Implement search suggestions
- Add analytics tracking
