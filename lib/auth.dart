import 'package:flutter/foundation.dart';
import 'supabase_config.dart';

/// Where OAuth providers send the shopper back to after sign-in. Must be
/// listed under Authentication → URL Configuration → Redirect URLs in the
/// Supabase dashboard, or the provider will refuse the round trip.
const kAppRedirectUrl = 'https://palaniselvam123.github.io/namma-market/app/';

class UserProfile {
  final String id;
  final String fullName;
  final String phone;
  final String? email;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
  });

  factory UserProfile.fromRow(Map<String, dynamic> row) => UserProfile(
        id: row['id'] as String,
        fullName: row['full_name'] as String? ?? '',
        phone: row['phone'] as String? ?? '',
        email: row['email'] as String?,
      );

  /// Falls back to the part before the @ so the UI never shows a blank name.
  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    final mail = email;
    if (mail != null && mail.contains('@')) return mail.split('@').first;
    return 'Shopper';
  }

  String get initials {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

class AuthService extends ChangeNotifier {
  UserProfile? _profile;
  bool _ready = false;

  /// True once the initial session check has finished, so the app knows
  /// whether to show the sign-in screen or go straight to the shop.
  bool get ready => _ready;
  UserProfile? get profile => _profile;
  bool get isSignedIn => supabase.auth.currentUser != null;
  String? get userId => supabase.auth.currentUser?.id;

  Future<void> init() async {
    supabase.auth.onAuthStateChange.listen((state) async {
      if (state.session?.user == null) {
        _profile = null;
        notifyListeners();
      } else {
        await _loadProfile();
      }
    });

    if (supabase.auth.currentUser != null) {
      await _loadProfile();
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      final row = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (row == null) {
        // The sign-up trigger normally creates this; insert defensively so a
        // provider that skipped it can't leave the app without a profile.
        final inserted = await supabase
            .from('profiles')
            .insert({
              'id': user.id,
              'full_name': user.userMetadata?['full_name'] ??
                  user.userMetadata?['name'] ??
                  '',
              'phone': user.phone ?? '',
              'email': user.email,
            })
            .select()
            .single();
        _profile = UserProfile.fromRow(inserted);
      } else {
        _profile = UserProfile.fromRow(row);
      }
    } catch (_) {
      _profile = UserProfile(
        id: user.id,
        fullName: '',
        phone: user.phone ?? '',
        email: user.email,
      );
    }
    notifyListeners();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
    await _loadProfile();
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'phone': phone},
      emailRedirectTo: kAppRedirectUrl,
    );
    // With email confirmation switched off there is a session immediately;
    // with it on the shopper has to confirm before a session exists.
    if (supabase.auth.currentUser != null) {
      await supabase.from('profiles').upsert({
        'id': supabase.auth.currentUser!.id,
        'full_name': fullName,
        'phone': phone,
        'email': email,
      });
      await _loadProfile();
    }
  }

  Future<void> signInWithGoogle() => supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kAppRedirectUrl,
      );

  Future<void> signInWithApple() => supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kAppRedirectUrl,
      );

  Future<void> updateProfile({String? fullName, String? phone}) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    await supabase.from('profiles').update({
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
    }).eq('id', user.id);
    await _loadProfile();
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _profile = null;
    notifyListeners();
  }
}

final auth = AuthService();
