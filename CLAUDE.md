# CLAUDE.md - Nomo UI Kit Generator

This file provides guidance to Claude Code (claude.ai/code) when working with the Nomo UI Kit Generator package.

## Overview

This package provides build_runner generators specifically for the Nomo UI Kit development. It should only be used when developing the NomoUIKit or a fork of it.

## Generator Types

### 1. Theme Data Builder (`theme_data_builder`)
- **Purpose**: Generates theme data classes from annotations
- **Input**: Dart files with theme-related annotations
- **Output**: `*.theme_data.g.dart` files
- **Location**: Generates directly in source alongside annotated files

### 2. Theme Utils Builder (`theme_utils_builder`)
- **Purpose**: Generates theme utility functions
- **Input**: Theme data files
- **Output**: `*.theme_utils.g.part` files
- **Location**: Generates to cache, combined by source_gen

### 3. Reflection Builder (`reflection_builder`)
- **Purpose**: Generates reflection data (e.g., icon mappings)
- **Input**: Classes with reflection annotations
- **Output**: `*.reflection.g.part` files
- **Location**: Generates to cache, combined by source_gen

## Development Commands

### Testing the Generator
```bash
# From generator package root
dart test

# Build the generator
dart pub get
```

### Using in Nomo UI Kit
```bash
# From nomo-ui-kit package root
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Architecture

### Key Files
- `lib/annotations.dart` - Annotation definitions used by UI Kit
- `lib/builder.dart` - Theme data builder factory
- `lib/util_builder.dart` - Utils and reflection builder factories
- `lib/src/model_visitor.dart` - AST visitor for parsing annotations
- `lib/src/theme_data_generator.dart` - Core theme generation logic
- `lib/src/theme_util_generator.dart` - Utility function generation
- `lib/src/reflection_generator.dart` - Reflection data generation

### Build Configuration
The `build.yaml` file defines:
- Builder names and factories
- Build extensions (input → output mappings)
- Build order (theme_data runs before theme_utils)
- Application rules (auto_apply: dependents)

## How It Works

### Theme Data Generation Flow
1. Scans for classes with theme annotations
2. Extracts properties and their types
3. Generates nullable and non-nullable data classes
4. Creates constructor with default values
5. Implements copyWith methods
6. Generates theme extension methods

### Generated Code Structure
```dart
// For a component like NomoButton
class NomoButtonColorDataNullable {
  // Nullable properties
}

class NomoButtonColorData implements NomoButtonColorDataNullable {
  // Non-nullable properties with defaults
}

class NomoButtonSizingDataNullable {
  // Nullable sizing properties
}

class NomoButtonSizingData implements NomoButtonSizingDataNullable {
  // Non-nullable sizing with defaults
}

class NomoButtonThemeData {
  // Combines color and sizing data
}
```

## Adding New Features

### Adding a New Annotation
1. Define annotation in `lib/annotations.dart`
2. Update model visitor to recognize it
3. Implement generation logic
4. Test with example usage

### Modifying Generation Logic
1. Locate relevant generator class
2. Update generation methods
3. Test output in nomo-ui-kit
4. Ensure backwards compatibility

## Common Issues

### Generator Not Running
- Check `build.yaml` is properly configured
- Ensure generator is listed in dependencies (not dev_dependencies)
- Verify annotation usage is correct

### Invalid Generated Code
- Check for proper null safety handling
- Ensure imports are correctly generated
- Verify type mappings are accurate

### Build Order Issues
- Theme data must generate before theme utils
- Check `runs_before` in build.yaml
- Ensure `required_inputs` are specified

## Best Practices

1. **Backwards Compatibility**: Don't break existing generated code
2. **Null Safety**: Always generate both nullable and non-nullable variants
3. **Imports**: Generate minimal, correct imports
4. **Formatting**: Generated code should be properly formatted
5. **Comments**: Include generation markers and warnings

## Testing

When making changes:
1. Test generator unit tests
2. Run generator on nomo-ui-kit
3. Verify generated code compiles
4. Check example app still works
5. Ensure no regression in existing components