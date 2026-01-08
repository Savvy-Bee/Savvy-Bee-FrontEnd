# Savvy Bee Mobile - Configuration Requirements

This document outlines all configuration requirements for the Savvy Bee mobile application, including environment variables, API keys, service configurations, and platform-specific settings.

## Table of Contents

1. [Environment Variables](#environment-variables)
2. [API Configuration](#api-configuration)
3. [Third-Party Services](#third-party-services)
4. [Platform-Specific Configuration](#platform-specific-configuration)
5. [Security Configuration](#security-configuration)
6. [Build Configuration](#build-configuration)
7. [Development Configuration](#development-configuration)
8. [Production Configuration](#production-configuration)

## Environment Variables

### Required Environment Variables

Create a `.env` file in the project root with the following variables:

```bash
# Encryption Configuration
ENCRYPTION_KEY=h3hej3u29ml3igh4jm3.3jriuflwi4fj

# Mono Bank Integration
MONO_SECRET=test_sk_j9hfeaeyl0gaevt9v37v
MONO_PUBLIC=test_pk_u7qxf0kjlnwa8o4dg64w

# API Configuration
API_BASE_URL=https://api.savvybee.ng/api/v1/
```

## API Configuration

### Base API Configuration

The application uses a centralized API client configuration in `/lib/core/network/api_client.dart`:

```dart
class ApiClient {...}
```

### API Endpoints Configuration

API endpoints are defined in `/lib/core/network/api_endpoints.dart`:

```dart
class ApiEndpoints {...}
```

## Platform-Specific Configuration

### Android Configuration

Refer to the `android/` directory for Android-Specific configuration files.

### iOS Configuration

Refer to the `ios/` directory for iOS-Specific configuration files.

## Security Configuration

### Authentication Configuration

## Build Configuration

### pubspec.yaml Configuration

Refer to the `pubspec.yaml` file for the complete configuration.
