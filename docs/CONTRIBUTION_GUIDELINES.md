# Savvy Bee Mobile - Contribution Guidelines

Welcome to the Savvy Bee mobile application! This document provides comprehensive guidelines for contributing to the project, ensuring code quality, consistency, and maintainability.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Workflow](#development-workflow)
3. [Code Standards](#code-standards)
4. [Git Workflow](#git-workflow)
5. [Pull Request Process](#pull-request-process)
6. [Code Review Guidelines](#code-review-guidelines)
7. [Testing Requirements](#testing-requirements)
8. [Documentation Standards](#documentation-standards)
9. [Issue Reporting](#issue-reporting)
10. [Feature Requests](#feature-requests)
11. [Release Process](#release-process)
12. [Guidelines](#guidelines)
13. [Security Guidelines](#security-guidelines)
14. [Performance Guidelines](#performance-guidelines)
15. [Troubleshooting](#troubleshooting)

## Getting Started

### Prerequisites

Before contributing to Savvy Bee Mobile, ensure you have:

1. **Flutter SDK** (version 3.16.0 or higher)
2. **Dart SDK** (version 3.2.0 or higher)
3. **Git** (version 2.30.0 or higher)
4. **Code Editor** (VS Code, Android Studio, or IntelliJ)
5. **GitHub Account** with 2FA enabled

### Development Environment Setup

1. **Fork and Clone the Repository**
   ```bash
   # Fork the repository on GitHub
   # Then clone your fork
   git clone https://github.com/Savvy-Bee/Savvy-Bee-FrontEnd.git
   cd Savvy-Bee-FrontEnd
   ```

2. **Set Up Upstream Remote**
   ```bash
   git remote add upstream https://github.com/Savvy-Bee/Savvy-Bee-FrontEnd.git
   git fetch upstream
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate Code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run Tests**
   ```bash
   flutter test
   ```

6. **Verify Setup**
   ```bash
   flutter doctor
   ```

### Project Structure Understanding

Familiarize yourself with the project structure:

```
lib/
├── core/                    # Core functionality
│   ├── network/            # API client, interceptors
│   ├── services/           # Storage, encryption, etc.
│   ├── utils/              # Utilities and helpers
│   └── constants/          # App constants
├── features/               # Feature modules
│   ├── auth/               # Authentication
│   ├── dashboard/          # Dashboard
│   ├── transactions/       # Transactions
│   ├── tools/              # Financial tools
│   ├── hive/               # Educational content
│   └── chat/               # AI chat assistant
└── main.dart               # App entry point
```

## Development Workflow

### 1. Issue Assignment

- Check the [Issues](https://github.com/original/Savvy-Bee-FrontEnd/issues) tab for available tasks
- Comment on the issue to indicate interest
- Wait for assignment before starting work
- For new features, create an issue first for discussion

### 2. Branch Creation

- Create feature branches from `develop` branch
- Use descriptive branch names following the convention: `feature/issue-number-description`
- Example: `feature/123-add-budget-calculator`

### 3. Development Process

1. **Create Feature Branch**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout -b feature/123-add-budget-calculator
   ```

2. **Make Changes**
   - Follow code standards (see [Code Standards](#code-standards))
   - Write tests for new functionality
   - Update documentation as needed

3. **Commit Changes**
   - Use conventional commit messages
   - Keep commits atomic and focused
   - Reference issues in commit messages

4. **Push and Create PR**
   ```bash
   git push origin feature/123-add-budget-calculator
   # Create PR on GitHub
   ```

### 4. Code Quality Checks

- [ ] All tests pass (`flutter test`)
- [ ] Static analysis passes (`flutter analyze`)
- [ ] Code is formatted (`flutter format .`)
- [ ] No linting errors
- [ ] Documentation is updated
- [ ] Security guidelines are followed

## Code Standards

### Flutter/Dart Standards

#### 1. Code Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// ✅ Good
class UserProfile {
  final String userId;
  final String userName;
  
  const UserProfile({
    required this.userId,
    required this.userName,
  });
}

// ❌ Bad
class userProfile {
  String UserID;
  String user_name;
}
```

#### 2. Widget Structure

```dart
// ✅ Good - Separate widget classes
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DashboardAppBar(),
      body: const DashboardBody(),
      bottomNavigationBar: const DashboardNavigation(),
    );
  }
}

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Dashboard'),
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
```

#### 3. State Management with Riverpod

```dart
// ✅ Good - Proper Riverpod usage
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User>>((ref) {
  return UserNotifier(ref.read(authRepositoryProvider));
});

class UserNotifier extends StateNotifier<AsyncValue<User>> {
  UserNotifier(this._authRepository) : super(const AsyncValue.loading());
  
  final AuthRepository _authRepository;
  
  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
```

### Architecture Guidelines

#### 1. Clean Architecture

```
lib/
├── core/                    # Core business logic
├── features/               # Feature modules
│   ├── feature_name/
│   │   ├── data/          # Data layer (repositories, models)
│   │   ├── domain/        # Domain layer (entities, use cases)
│   │   └── presentation/  # Presentation layer (UI, providers)
```

#### 2. Dependency Injection

```dart
// ✅ Good - Using service locator
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.read(apiClientProvider),
    storageService: ref.read(storageServiceProvider),
  );
});
```

#### 3. Repository Pattern

```dart
abstract class AuthRepository {
  Future<ApiResponse<User>> login(String email, String password);
  Future<ApiResponse<User>> register(RegisterRequest request);
  Future<void> logout();
  Future<User?> getCurrentUser();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.apiClient,
    required this.storageService,
  });
  
  final ApiClient apiClient;
  final StorageService storageService;
  
  @override
  Future<ApiResponse<User>> login(String email, String password) async {
    // Implementation
  }
}
```

## Git Workflow

### Branch Strategy

We use **Git Flow** with the following branches:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: Feature development branches
- `hotfix/*`: Critical bug fixes
- `release/*`: Release preparation

### Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks

#### Examples:

```bash
feat(auth): add biometric authentication
fix(dashboard): resolve chart rendering issue
docs(api): update API documentation
style(transactions): format transaction list widget
test(auth): add unit tests for login flow
chore(deps): update Flutter dependencies
```

### Branch Naming Convention

```
feature/issue-number-description
hotfix/issue-number-description
release/version-number
```

Examples:
```bash
git checkout -b feature/123-add-budget-calculator
git checkout -b hotfix/456-fix-login-crash
git checkout -b release/v1.2.0
```

## Pull Request Process

### 1. Before Creating PR

- [ ] Code follows project standards
- [ ] All tests pass locally
- [ ] Code is properly formatted
- [ ] Documentation is updated
- [ ] No sensitive data in commits
- [ ] Branch is up-to-date with develop

### 2. PR Template

Use the following template when creating PRs:

```markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Related Issues
Closes #(issue number)

## Changes Made
- List of specific changes
- Another change
- Third change

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Performance impact assessed

## Screenshots/Videos
Include screenshots or videos if UI changes are made.

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published
```

### 3. PR Size Guidelines

- **Small PRs**: < 200 lines (preferred)
- **Medium PRs**: 200-500 lines
- **Large PRs**: > 500 lines (require additional review)

Break large features into smaller, reviewable chunks.

## Code Review Guidelines

### For Authors

1. **Self-Review First**: Review your own code before requesting review
2. **Provide Context**: Include clear descriptions and context
3. **Be Responsive**: Address feedback promptly
4. **Test Thoroughly**: Ensure all tests pass and edge cases are covered
5. **Update Documentation**: Keep docs in sync with code changes

### For Reviewers

1. **Be Constructive**: Provide helpful, actionable feedback
2. **Focus on Quality**: Look for bugs, performance issues, security concerns
3. **Check Standards**: Ensure code follows project standards
4. **Test Coverage**: Verify adequate test coverage
5. **Documentation**: Check that documentation is updated

### Review Checklist

#### Code Quality
- [ ] Code follows style guidelines
- [ ] Functions are appropriately sized
- [ ] Error handling is comprehensive
- [ ] No code duplication
- [ ] Performance considerations addressed

#### Architecture
- [ ] Follows clean architecture principles
- [ ] Proper separation of concerns
- [ ] Appropriate use of design patterns
- [ ] Dependencies are properly managed

#### Testing
- [ ] Unit tests for new functionality
- [ ] Integration tests for complex features
- [ ] Edge cases are tested
- [ ] Test coverage meets requirements

#### Security
- [ ] No hardcoded secrets or credentials
- [ ] Input validation is implemented
- [ ] Authentication/authorization is proper
- [ ] Data encryption where appropriate

#### Documentation
- [ ] Code is well-commented
- [ ] API documentation is updated
- [ ] README is current
- [ ] Architecture docs are updated

## Documentation Standards

### 1. Code Documentation

#### Function Documentation
```dart
/// Authenticates a user with email and password.
/// 
/// Returns [ApiResponse] containing user data on success, or error message
/// on failure. Throws [NetworkException] if network error occurs.
/// 
/// Example:
/// ```dart
/// final response = await authRepository.login('user@example.com', 'password');
/// if (response.success) {
///   print('Login successful: ${response.data?.name}');
/// }
/// ```
Future<ApiResponse<User>> login(String email, String password) async {
  // Implementation
}
```

#### Class Documentation
```dart
/// Manages user authentication state and provides authentication methods.
/// 
/// This repository handles user login, logout, and session management.
/// It communicates with the authentication API and manages user tokens.
class AuthRepository {
  /// Creates an instance of [AuthRepository].
  /// 
  /// Requires [apiClient] for API communication and [storageService]
  /// for secure token storage.
  AuthRepository({
    required this.apiClient,
    required this.storageService,
  });
}
```

### 2. README Updates

Update README when:
- New features are added
- Setup instructions change
- Dependencies are updated
- Configuration changes

### 3. API Documentation

Document all API endpoints:

```dart
/// Authentication API endpoints
abstract class ApiEndpoints {
  /// User login endpoint
  /// 
  /// POST /auth/login
  /// 
  /// Request body:
  /// ```json
  /// {
  ///   "email": "user@example.com",
  ///   "password": "password123"
  /// }
  /// ```
  /// 
  /// Response:
  /// ```json
  /// {
  ///   "success": true,
  ///   "token": "jwt_token_here",
  ///   "data": {
  ///     "id": "user_id",
  ///     "email": "user@example.com",
  ///     "name": "User Name"
  ///   }
  /// }
  /// ```
  static const String login = '/auth/login';
}
```

## Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
## Bug Description
Clear description of the bug.

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Screenshots
If applicable, add screenshots.

## Environment
- Device: [e.g., iPhone 13, Samsung Galaxy S21]
- OS: [e.g., iOS 15.0, Android 12]
- App Version: [e.g., 1.0.0]
- Flutter Version: [e.g., 3.16.0]

## Additional Context
Any other relevant information.
```

### Feature Requests

Use the feature request template:

```markdown
## Feature Description
Clear description of the proposed feature.

## Problem Statement
What problem does this feature solve?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Any alternative solutions considered.

## Additional Context
Screenshots, mockups, or other relevant information.
```

## Security Guidelines

### 1. Sensitive Data

- Never commit API keys, passwords, or tokens
- Use environment variables for configuration
- Encrypt sensitive data before storage
- Use secure communication (HTTPS)

### 2. Authentication

- Implement proper authentication flows
- Validate all user inputs
- Use secure token storage
- Implement proper session management

### 3. Data Protection

```dart
// ✅ Good - Secure data handling
class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage();
  
  static Future<void> storeToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
}
```

## Performance Guidelines

### 1. Widget Performance

- Use `const` constructors where possible
- Implement proper widget keys
- Avoid unnecessary rebuilds
- Use `ListView.builder` for large lists

### 2. State Management

```dart
// ✅ Good - Efficient state management
final userTransactionsProvider = FutureProvider.family<List<Transaction>, String>((ref, userId) {
  return ref.read(transactionRepositoryProvider).getUserTransactions(userId);
});

// Use specific selectors to minimize rebuilds
final userBalance = ref.watch(userProvider.select((user) => user.balance));
```

### 3. Network Optimization

- Implement proper caching strategies
- Use pagination for large datasets
- Compress data when possible
- Handle offline scenarios gracefully

## Troubleshooting

### Common Issues

#### 1. Build Failures

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

#### 2. Dependency Issues

```bash
# Update dependencies
flutter pub upgrade

# Check for dependency conflicts
flutter pub deps
```

### Getting Help

1. **Check Documentation**: Review existing docs first
2. **Search Issues**: Look for similar problems
3. **Ask Questions**: Use GitHub Discussions
4. **Contact Maintainers**: Tag maintainers for urgent issues

## Guidelines

### Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Provide constructive feedback
- Focus on the code, not the person
- Help maintain a positive environment

### Recognition

Contributors are recognized in:
- Release notes
- Contributors file
- Project documentation
- Special mentions for significant contributions

---

## Quick Reference

### Essential Commands

```bash
# Setup
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Development
flutter run
flutter test
flutter analyze
flutter format .

# Build
flutter build apk
flutter build ios
flutter build web
```

### Key Files

- `lib/main.dart`: App entry point
- `pubspec.yaml`: Dependencies and metadata
- `analysis_options.yaml`: Linting rules
- `test/`: Test directory
- `android/`: Android-specific code
- `ios/`: iOS-specific code

### Contact Information

- **Project Maintainers**: [List of maintainers]
- **Discord/Slack**: [Community channels]
- **Email**: [Support email]

---

Cheers 🥂