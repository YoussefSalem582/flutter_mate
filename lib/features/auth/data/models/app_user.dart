/// User model for the application
class AppUser {
  final String id;
  final String email;
  final String username;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final AuthProvider provider;
  final UserPreferences preferences;
  final SubscriptionTier tier;
  final DateTime? subscriptionExpiresAt;

  // Learning Stats
  final int lessonsCompleted;
  final int totalXP;
  final int currentStreak;
  final Map<String, double> categoryProgress;

  // Reputation (for community features)
  final int reputationPoints;
  final int questionsAsked;
  final int answersGiven;
  final List<String> badges;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.emailVerified = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.provider = AuthProvider.email,
    required this.preferences,
    this.tier = SubscriptionTier.free,
    this.subscriptionExpiresAt,
    this.lessonsCompleted = 0,
    this.totalXP = 0,
    this.currentStreak = 0,
    this.categoryProgress = const {},
    this.reputationPoints = 0,
    this.questionsAsked = 0,
    this.answersGiven = 0,
    this.badges = const [],
  });

  /// Create from Firebase User
  factory AppUser.fromFirebase(
    String uid,
    String email,
    Map<String, dynamic> userData,
  ) {
    return AppUser(
      id: uid,
      email: email,
      username: userData['username'] ?? 'User',
      displayName: userData['displayName'],
      photoURL: userData['photoURL'],
      phoneNumber: userData['phoneNumber'],
      emailVerified: userData['emailVerified'] ?? false,
      createdAt: DateTime.parse(userData['createdAt']),
      lastLoginAt: DateTime.now(),
      provider: AuthProvider.values.firstWhere(
        (e) => e.name == userData['provider'],
        orElse: () => AuthProvider.email,
      ),
      preferences: UserPreferences.fromMap(
        userData['preferences'] ?? {},
      ),
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == userData['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      lessonsCompleted: userData['lessonsCompleted'] ?? 0,
      totalXP: userData['totalXP'] ?? 0,
      currentStreak: userData['currentStreak'] ?? 0,
      categoryProgress: _parseMap(userData['categoryProgress']),
      reputationPoints: userData['reputationPoints'] ?? 0,
      questionsAsked: userData['questionsAsked'] ?? 0,
      answersGiven: userData['answersGiven'] ?? 0,
      badges: _parseList(userData['badges']),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'provider': provider.name,
      'preferences': preferences.toMap(),
      'tier': tier.name,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'lessonsCompleted': lessonsCompleted,
      'totalXP': totalXP,
      'currentStreak': currentStreak,
      'categoryProgress': categoryProgress,
      'reputationPoints': reputationPoints,
      'questionsAsked': questionsAsked,
      'answersGiven': answersGiven,
      'badges': badges,
    };
  }

  /// Copy with method for updates
  AppUser copyWith({
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? emailVerified,
    DateTime? lastLoginAt,
    UserPreferences? preferences,
    SubscriptionTier? tier,
    int? lessonsCompleted,
    int? totalXP,
    int? currentStreak,
    Map<String, double>? categoryProgress,
    int? reputationPoints,
    int? questionsAsked,
    int? answersGiven,
    List<String>? badges,
  }) {
    return AppUser(
      id: id,
      email: email,
      username: username,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      provider: provider,
      preferences: preferences ?? this.preferences,
      tier: tier ?? this.tier,
      subscriptionExpiresAt: subscriptionExpiresAt,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      totalXP: totalXP ?? this.totalXP,
      currentStreak: currentStreak ?? this.currentStreak,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      reputationPoints: reputationPoints ?? this.reputationPoints,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      answersGiven: answersGiven ?? this.answersGiven,
      badges: badges ?? this.badges,
    );
  }

  /// Helper method to safely parse Map from Firestore
  static Map<String, double> _parseMap(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return Map<String, double>.from(
        data.map((key, value) => MapEntry(
              key.toString(),
              (value is num) ? value.toDouble() : 0.0,
            )),
      );
    }
    return {};
  }

  /// Helper method to safely parse List from Firestore
  static List<String> _parseList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return [];
  }
}

/// Authentication provider enum
enum AuthProvider {
  email,
  google,
  apple,
  anonymous,
}

/// Subscription tier enum
enum SubscriptionTier {
  free,
  premium,
  pro,
}

/// User preferences model
class UserPreferences {
  final bool darkMode;
  final String language;
  final bool notifications;
  final bool emailUpdates;
  final int dailyGoalMinutes;
  final List<String> favoriteCategories;

  UserPreferences({
    this.darkMode = false,
    this.language = 'en',
    this.notifications = true,
    this.emailUpdates = false,
    this.dailyGoalMinutes = 30,
    this.favoriteCategories = const [],
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'en',
      notifications: map['notifications'] ?? true,
      emailUpdates: map['emailUpdates'] ?? false,
      dailyGoalMinutes: map['dailyGoalMinutes'] ?? 30,
      favoriteCategories: List<String>.from(map['favoriteCategories'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'darkMode': darkMode,
      'language': language,
      'notifications': notifications,
      'emailUpdates': emailUpdates,
      'dailyGoalMinutes': dailyGoalMinutes,
      'favoriteCategories': favoriteCategories,
    };
  }

  UserPreferences copyWith({
    bool? darkMode,
    String? language,
    bool? notifications,
    bool? emailUpdates,
    int? dailyGoalMinutes,
    List<String>? favoriteCategories,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
      emailUpdates: emailUpdates ?? this.emailUpdates,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
    );
  }
}
