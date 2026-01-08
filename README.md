# Savvy Bee Mobile - Comprehensive Documentation

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Core Features](#core-features)
6. [Development Setup](#development-setup)
7. [Build & Deployment](#build--deployment)
8. [Testing Strategy](#testing-strategy)
9. [API Documentation](#api-documentation)
10. [State Management](#state-management)
11. [Security Considerations](#security-considerations)
12. [Performance Optimization](#performance-optimization)
13. [Contributing Guidelines](#contributing-guidelines)
14. [Troubleshooting](#troubleshooting)

---

## Project Overview

Savvy Bee is a comprehensive financial literacy and management mobile application built with Flutter. The app combines educational content, financial tools, and banking services to help users improve their financial health through gamified learning experiences.

### Key Objectives
- **Financial Education**: Interactive courses and quizzes on financial literacy
- **Financial Management**: Budget tracking, goal setting, and spending analysis
- **Banking Integration**: Secure bank connections and transaction management
- **Gamification**: Achievement systems, leaderboards, and streak tracking
- **Personalized Experience**: AI-powered chat assistance and financial archetype analysis

### Target Audience
- Primary: Young adults (16-35) seeking financial literacy
- Secondary: Anyone looking to improve their financial health
- Geographic focus: Initially Nigeria, with expansion plans

---

## System Architecture

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────┬─────────────┬─────────────┬──────────────┐ │
│  │   Flutter   │   Riverpod  │   GoRouter  │   Custom     │ │
│  │   Widgets   │   State     │ Navigation  │   UI         │ │
│  │             │ Management  │             │   Components │ │
│  └─────────────┴─────────────┴─────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Business Logic Layer                     │
│  ┌─────────────┬─────────────┬─────────────┬──────────────┐ │
│  │   Features  │   Domain    │   Data      │   Service    │ │
│  │   (Auth,    │   Models    │   Reposito- │   Locator    │ │
│  │   Hive,     │             │   ries      │              │ │
│  │   Tools)    │             │             │              │ │
│  └─────────────┴─────────────┴─────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Access Layer                        │
│  ┌─────────────┬─────────────┬─────────────┬──────────────┐ │
│  │   API       │   Local     │   Firebase  │   Mono       │ │
│  │   Client    │   Storage   │   Firestore │   Integration│ │
│  │   (Dio)     │   (Shared   │             │              │ │
│  │             │   Prefs)    │             │              │ │
│  └─────────────┴─────────────┴─────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    External Services                        │
│  ┌─────────────┬─────────────┬─────────────┬──────────────┐ │
│  │   Backend   │   Banking   │   Cloud     │   Analytics  │ │
│  │   API       │   APIs      │   Services  │              │ │
│  │             │             │             │              │ │
│  └─────────────┴─────────────┴─────────────┴──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Clean Architecture Implementation

The project follows Clean Architecture principles with clear separation of concerns:

1. **Presentation Layer**: UI components, providers, and navigation
2. **Domain Layer**: Business logic, models, and repository interfaces
3. **Data Layer**: Repository implementations, API clients, and local storage

---

## Technology Stack

### Core Technologies
- **Flutter**: 3.8.1+ - Cross-platform mobile framework
- **Dart**: Latest stable version
- **Riverpod**: 2.5.1+ - State management
- **GoRouter**: 13.2.0+ - Navigation management

### Key Dependencies

#### State Management & Navigation
```yaml
flutter_riverpod: ^2.5.1
riverpod: ^2.6.1
go_router: ^13.2.0
```

#### Networking & Data
```yaml
dio: ^5.4.1
cloud_firestore: ^6.1.0
firebase_core: ^4.2.1
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0
```

#### UI & UX
```yaml
flutter_screenutil: ^5.9.3
flutter_svg: ^2.2.1
cached_network_image: ^3.4.1
smooth_page_indicator: ^1.2.1
loading_animation_widget: ^1.3.0
```

#### Utilities
```yaml
flutter_dotenv: ^6.0.0
intl: ^0.20.2
url_launcher: ^6.3.2
crypto: ^3.0.7
encrypt: ^5.0.3
```

#### Banking Integration
```yaml
mono_connect: ^2.1.0
```

#### Media & Files
```yaml
camera: ^0.11.2+1
image_picker: ^1.2.0
file_picker: ^10.3.3
```

---

## Project Structure

```
lib/
├── core/                           # Core functionality
│   ├── network/                    # API client and endpoints
│   ├── routing/                    # Navigation configuration
│   ├── services/                   # Service locator and storage
│   ├── theme/                      # App theming and styling
│   ├── utils/                      # Utility functions and extensions
│   └── widgets/                    # Reusable UI components
├── features/                       # Feature-based architecture
│   ├── auth/                       # Authentication feature
│   ├── dashboard/                  # Financial dashboard
│   ├── hive/                       # Educational content (courses, quizzes)
│   ├── home/                       # Home screen
│   ├── chat/                       # AI chat assistance
│   ├── profile/                    # User profile management
│   ├── spend/                      # Spending and banking
│   ├── tools/                      # Financial tools (budget, goals, debt)
│   ├── onboarding/                 # User onboarding
│   └── premium/                    # Premium features
└── main.dart                       # Application entry point
```

### Feature Structure Pattern
Each feature follows a consistent structure:
```
features/[feature_name]/
├── data/
│   ├── repositories/               # Data access implementations
│   └── datasources/                # Local/remote data sources
├── domain/
│   ├── models/                     # Domain models
│   ├── repositories/               # Repository interfaces
│   └── usecases/                   # Business logic (if needed)
└── presentation/
    ├── providers/                  # Riverpod providers
    ├── screens/                    # UI screens
    └── widgets/                    # Feature-specific widgets
```

---

## Core Features

### 1. Authentication & User Management
- **Multi-method Auth**: Email/password, social login
- **Financial Archetype Analysis**: Personalized financial personality assessment
- **Profile Management**: Avatar selection, personal information, security settings
- **Bank Connection**: Secure integration with Nigerian banks via Mono

### 2. Educational Content (Hive)
- **Interactive Courses**: Budgeting, savings, financial literacy
- **Gamified Quizzes**: Multiple question types with immediate feedback
- **Progress Tracking**: Course completion, quiz scores, streak management
- **Achievement System**: Badges, leaderboards, league promotions

### 3. Financial Tools
- **Budget Management**: Income setting, category-based budgeting, spending analysis
- **Goal Setting**: Create and track financial goals with visual progress
- **Debt Management**: Track and plan debt repayment strategies
- **Financial Health Score**: Comprehensive financial wellness assessment

### 4. Banking & Spending
- **Wallet Creation**: Secure wallet with KYC verification
- **Money Transfers**: Send/receive money with transaction history
- **Bill Payments**: Airtime, internet, electricity, cable TV payments
- **Transaction Analytics**: Spending categorization and insights

### 5. AI-Powered Chat
- **Personalized Assistance**: Context-aware financial advice
- **Multi-personality Support**: Different AI personalities for varied interactions
- **Quick Actions**: Budget creation, goal setting, bill payments via chat

---

## Development Setup

Please refer to the [BUILD_DEPLOYMENT.md](/docs/BUILD_DEPLOYMENT.md) and [CONFIGURATION_GUIDELINES.md](/docs/CONFIGURATION_GUIDELINES.md) files for detailed build and deployment instructions.

### Prerequisites
- Flutter SDK: 3.8.1 or higher
- Dart SDK: Latest stable
- Android Studio / Xcode (for mobile development)
- Git

### Environment Setup

1. **Clone the Repository**
```bash
git clone https://github.com/Savvy-Bee/Savvy-Bee-FrontEnd.git
cd Savvy-Bee-FrontEnd
```

2. **Install Dependencies**
```bash
flutter pub get
```

3. **Environment Configuration**
Create a `.env` file in the root directory:
```env
# API Configuration
BASE_URL=https://api.savvybee.com
API_KEY=your_api_key_here

# Mono Configuration
MONO_PUBLIC_KEY=your_mono_public_key
MONO_SECRET_KEY=your_mono_secret_key
```

4. **Platform-Specific Setup**

#### Android
```bash
# Generate keystore for release builds
keytool -genkey -v -keystore android/app/savvybee-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias savvybee

# Configure google-services.json
# Place your Firebase configuration file in android/app/
```

#### iOS
```bash
cd ios
pod install
cd ..
```

5. **Run the Application**
```bash
# Development
flutter run --debug

# Production build
flutter run --release
```

---

## Build & Deployment

Please refer to the [BUILD_DEPLOYMENT.md](/docs/BUILD_DEPLOYMENT.md) file for detailed build and deployment instructions.

## Testing Strategy

### Test Structure
```
test/
├── unit/                           # Unit tests
├── widget/                         # Widget tests
└── integration/                    # Integration tests
```

### Testing Approach

#### Unit Tests
- Business logic validation
- Data model testing
- Utility function testing

#### Widget Tests
- UI component behavior
- User interaction flows
- State management integration

#### Integration Tests
- Complete user flows
- API integration
- Navigation flows

### Running Tests
```bash
# All tests
flutter test

# Specific test category
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# With coverage
flutter test --coverage
```

---

## API Documentation

Please refer to the [API_DOCUMENTATION.md](/docs/API_DOCUMENTATION.md) file for detailed API documentation.

## State Management

### Riverpod Architecture

#### Provider Types Used
- **StateProvider**: Simple state values
- **StateNotifierProvider**: Complex state logic
- **FutureProvider**: Async data fetching
- **StreamProvider**: Real-time data streams

#### State Management Pattern
```dart
// Example: Dashboard state management
final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getDashboardData();
});

// Example: User authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
```

### Best Practices
- Use `autoDispose` for memory efficiency
- Implement proper error handling with `AsyncValue`
- Leverage `select` for performance optimization
- Follow unidirectional data flow

---

## Security Considerations

### Data Protection
- **Local Storage**: Encrypted sensitive data using flutter_secure_storage
- **API Communication**: HTTPS with certificate pinning
- **Authentication**: JWT tokens with refresh mechanism
- **Input Validation**: Comprehensive form validation

### Banking Integration Security
- **Mono Integration**: Industry-standard banking APIs
- **KYC Verification**: Multi-step identity verification
- **Transaction Security**: PIN/biometric authentication
- **Fraud Detection**: Pattern analysis and alerts

### Privacy Compliance
- **Data Minimization**: Collect only necessary user data
- **Consent Management**: Clear privacy policy and consent flows
- **Data Retention**: Defined retention policies
- **Right to Deletion**: User data deletion capabilities

---

## Performance Optimization

### App Startup Optimization
- **Lazy Loading**: Feature-based code splitting
- **Asset Optimization**: Compressed images and fonts
- **Tree Shaking**: Remove unused code
- **Cold Start**: Minimize initial dependencies

### Runtime Performance
- **Widget Rebuilds**: Use `const` constructors and keys
- **List Performance**: Implement pagination and lazy loading
- **Image Caching**: Network image caching strategies
- **Memory Management**: Proper disposal of controllers and streams

### Network Optimization
- **Request Caching**: Implement response caching
- **Batch Requests**: Combine multiple API calls
- **Image Optimization**: Multiple sizes for different devices
- **Offline Support**: Local data persistence

---

## Contributing Guidelines

Please refer to the [CONTRIBUTION_GUIDELINES.md](/docs/CONTRIBUTION_GUIDELINES.md) file for detailed contribution guidelines.

## Troubleshooting

### Common Issues

#### Build Failures
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

#### iOS Pod Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### Dependency Conflicts
```bash
# Check dependency tree
flutter pub deps

# Update dependencies
flutter pub upgrade
```

### Performance Issues
- Use Flutter DevTools for profiling
- Check for unnecessary widget rebuilds
- Optimize images and assets
- Review network request patterns

### Memory Leaks
- Ensure proper disposal of controllers
- Use weak references where appropriate
- Monitor memory usage in DevTools
- Implement proper cleanup in dispose methods

---

## Support & Contact

### Development Team
- **Lead Developer**: [Name]
- **UI/UX Designer**: [Name]
- **Backend Team**: [Contact]
- **QA Team**: [Contact]

### Resources
- **Design System**: [Link to design system]
- **API Documentation**: [Link to API docs]
- **Backend Repository**: [Link to backend repo]
- **Issue Tracker**: [Link to issue tracker]

### Emergency Contacts
- **Production Issues**: [Emergency contact]
- **Security Issues**: [Security team contact]
- **Data Breach**: [Incident response team]

---

*Last Updated: January 2026*
*Version: 1.0.0*
*Maintained by: Savvy Bee Development Team*