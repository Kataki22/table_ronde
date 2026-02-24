/// Example usage of ProfileProvider
/// 
/// This file demonstrates how to use the ProfileProvider in your Flutter app.
/// 
/// ## Setup
/// 
/// Add ProfileProvider to your MultiProvider:
/// 
/// ```dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => ProfileProvider()),
///     // ... other providers
///   ],
///   child: MyApp(),
/// )
/// ```
/// 
/// ## Usage Examples
/// 
/// ### 1. Display a user profile
/// 
/// ```dart
/// Consumer<ProfileProvider>(
///   builder: (context, profileProvider, child) {
///     final profile = profileProvider.getProfile('user_1');
///     if (profile == null) return Text('Profile not found');
///     
///     return Column(
///       children: [
///         Text(profile.name),
///         Text(profile.bio ?? 'No bio'),
///         Text('Posts: ${profile.posts.length}'),
///       ],
///     );
///   },
/// )
/// ```
/// 
/// ### 2. Display current user profile
/// 
/// ```dart
/// Consumer<ProfileProvider>(
///   builder: (context, profileProvider, child) {
///     final currentUser = profileProvider.currentUserProfile;
///     if (currentUser == null) return Text('Not logged in');
///     
///     return ProfileHeader(profile: currentUser);
///   },
/// )
/// ```
/// 
/// ### 3. Update profile
/// 
/// ```dart
/// final provider = context.read<ProfileProvider>();
/// 
/// try {
///   await provider.updateProfile(
///     bio: 'My new bio',
///     phone: '+33 6 12 34 56 78',
///   );
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Profile updated!')),
///   );
/// } catch (e) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('Error: $e')),
///   );
/// }
/// ```
/// 
/// ### 4. Block/Unblock users
/// 
/// ```dart
/// final provider = context.read<ProfileProvider>();
/// 
/// // Block a user
/// await provider.blockUser('user_2');
/// 
/// // Check if blocked
/// if (provider.isUserBlocked('user_2')) {
///   print('User is blocked');
/// }
/// 
/// // Unblock a user
/// await provider.unblockUser('user_2');
/// ```
/// 
/// ### 5. Get user activities and posts
/// 
/// ```dart
/// final provider = context.read<ProfileProvider>();
/// 
/// // Get activities
/// final activities = provider.getUserActivities('user_1');
/// for (var activity in activities) {
///   print('${activity.type}: ${activity.description}');
/// }
/// 
/// // Get posts
/// final posts = provider.getUserPosts('user_1');
/// for (var post in posts) {
///   print('${post.content} - ${post.likesCount} likes');
/// }
/// ```
/// 
/// ## Validation Rules
/// 
/// ### Bio
/// - Maximum 500 characters
/// - Throws `ArgumentError` if exceeded
/// 
/// ### Phone
/// - Must start with '+' or a digit
/// - Must contain at least 10 digits
/// - Accepts formats: '+33 6 12 34 56 78', '0612345678', '+1234567890'
/// - Throws `ArgumentError` if invalid
/// 
/// ## Error Handling
/// 
/// The provider simulates network behavior:
/// - 200ms delay for profile updates
/// - 150ms delay for block/unblock operations
/// - 5% chance of random failure (simulates network errors)
/// 
/// Always wrap async operations in try-catch blocks:
/// 
/// ```dart
/// try {
///   await provider.updateProfile(bio: newBio);
/// } on ArgumentError catch (e) {
///   // Validation error
///   print('Validation error: $e');
/// } catch (e) {
///   // Network or other error
///   print('Error: $e');
/// }
/// ```
