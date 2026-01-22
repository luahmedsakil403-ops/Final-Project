import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('🔵 Starting registration for: $email');
      
      // SIMPLIFIED: Just create auth user first
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'email': email,
        },
      );

      print('🟡 Auth response received');
      
      if (authResponse.user == null && authResponse.session == null) {
        print('🔴 No user or session returned');
        throw Exception('Registration failed - please try again');
      }

      // Get user ID from response or current session
      String? userId;
      if (authResponse.user != null) {
        userId = authResponse.user!.id;
      } else if (_supabase.auth.currentSession != null) {
        userId = _supabase.auth.currentSession!.user.id;
      } else {
        throw Exception('Could not get user ID');
      }

      print('🟢 User ID obtained: $userId');

      // Save to local storage immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      await prefs.setString('user_email', email);
      await prefs.setString('user_name', name);
      await prefs.setBool('is_logged_in', true);
      
      print('✅ Local storage saved for: $email');

      // Try to create profile in background (don't wait for it)
      _createUserProfileInBackground(userId, name, email);

    } catch (e) {
      print('🔴 Registration error: $e');
      print('🔴 Error type: ${e.runtimeType}');
      
      // Try to login instead (maybe user already exists)
      try {
        print('🟡 Trying to login instead...');
        await login(email: email, password: password);
        return; // Login successful
      } catch (loginError) {
        print('🔴 Login also failed: $loginError');
      }
      
      // More specific error messages
      if (e.toString().contains('Database error')) {
        throw Exception('Server error. Please try again in a few minutes.');
      } else if (e.toString().contains('already registered')) {
        throw Exception('Email already registered. Please login instead.');
      } else if (e.toString().contains('network')) {
        throw Exception('Network error. Check your internet connection.');
      } else {
        throw Exception('Registration failed: ${e.toString()}');
      }
    }
  }

  Future<void> _createUserProfileInBackground(String userId, String name, String email) async {
    try {
      // Wait a bit for auth to propagate
      await Future.delayed(Duration(seconds: 2));
      
      print('🟡 Creating user profile for: $userId');
      
      // Check if profile already exists
      final existing = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle()
          .timeout(Duration(seconds: 10));

      if (existing == null) {
        // Create profile
        await _supabase
            .from('user_profiles')
            .insert({
              'id': userId,
              'name': name,
              'created_at': DateTime.now().toUtc().toIso8601String(),
            })
            .timeout(Duration(seconds: 10));
        
        print('✅ User profile created for: $userId');
      } else {
        print('🟡 User profile already exists for: $userId');
      }
      
    } catch (e) {
      print('⚠️ Background profile creation failed: $e');
      // This is not critical - user can still use the app
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔵 Attempting login for: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', response.user!.id);
      await prefs.setString('user_email', email);
      await prefs.setBool('is_logged_in', true);
      
      print('✅ Login successful for: $email');

    } catch (e) {
      print('🔴 Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      
      if (isLoggedIn) {
        // Verify session is still valid
        final session = _supabase.auth.currentSession;
        return session != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_id');
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Logout error: $e');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    }
  }
}