# Swift Project Guidelines

## Table of Contents
1. [Project Structure](#project-structure)
2. [Code Organization](#code-organization)
3. [Naming Conventions](#naming-conventions)
4. [Documentation](#documentation)
5. [SwiftUI Best Practices](#swiftui-best-practices)
6. [Testing](#testing)
7. [Git Workflow](#git-workflow)
8. [Performance Considerations](#performance-considerations)

## Project Structure

### Directory Organization
```
ProjectName/
├── Models/            # Data models and business logic
├── Views/             # UI components
│   ├── Components/    # Reusable UI components
│   └── Screens/       # Full screens of the app
├── Util/              # Utility classes and extensions
├── Services/          # API clients, data persistence, etc.
├── Resources/         # Assets, fonts, etc.
└── Preview Content/   # SwiftUI preview assets
```

### File Organization
- One Swift type per file (with rare exceptions for closely related small types)
- File name should match the primary type name (e.g., `CoffeeStrength.swift` contains `CoffeeStrength` enum)
- Group related files in appropriate directories

## Code Organization

### Import Statements
- Import statements should be at the top of the file
- Sort imports alphabetically
- SwiftUI and Foundation imports should come first, followed by other frameworks

### Type Organization
- Organize types with a clear, consistent structure:
  1. Properties
  2. Initializers
  3. Public methods
  4. Private methods
  5. Extensions for protocol conformance

### Access Control
- Use the most restrictive access control level possible
- Mark helper methods as `private` or `fileprivate`
- Only expose what's necessary for other components to use

## Naming Conventions

### General Guidelines
- Use clear, descriptive names
- Prefer longer, more descriptive names over shorter, ambiguous ones
- Follow Apple's [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

### Specific Conventions
- **Types** (classes, structs, enums, protocols): UpperCamelCase
  ```swift
  struct CoffeeStrength {}
  enum BrewingStage {}
  protocol CoffeePreparation {}
  ```

- **Variables and functions**: lowerCamelCase
  ```swift
  let coffeeAmount: Double
  func calculateBrewingTime() {}
  ```

- **Enum cases**: lowerCamelCase
  ```swift
  enum CoffeeStrength {
      case light
      case medium
      case strong
  }
  ```

- **Constants**: lowerCamelCase
  ```swift
  let maximumBrewingTime = 240
  ```

- **Static properties**: lowerCamelCase
  ```swift
  static let defaultRatio = 16.0
  ```

## Documentation

### Code Comments
- Use comments to explain "why" not "what"
- Keep comments up-to-date when code changes

### Documentation Comments
- Use Swift's documentation comments (`///`) for public APIs
- Include parameter descriptions, return values, and thrown errors
- Example:
  ```swift
  /// Calculates the amount of water needed based on coffee amount and strength.
  /// - Parameters:
  ///   - coffeeAmount: Amount of coffee in grams
  ///   - strength: Desired coffee strength
  /// - Returns: Amount of water in milliliters
  func calculateWaterAmount(coffeeAmount: Double, strength: CoffeeStrength) -> Double {
      return coffeeAmount * strength.ratio
  }
  ```

### README and Documentation Files
- Maintain an up-to-date README with:
  - Project overview
  - Setup instructions
  - Key features
  - Dependencies
- Include additional documentation for complex features

## SwiftUI Best Practices

### View Structure
- Keep views small and focused on a single responsibility
- Extract reusable components into separate views
- Use view modifiers to keep view declarations clean

### State Management
- Use `@State` for simple view-local state
- Use `@Binding` for state passed from parent views
- Use `@ObservableObject` for complex shared state
- Consider using the environment for deeply shared state

### Performance
- Use `@ViewBuilder` for conditional view creation
- Avoid expensive operations in view body
- Use `equatable` for views with expensive body calculations
- Leverage `LazyVStack` and `LazyHStack` for large collections

### Accessibility
- Include meaningful accessibility labels
- Support Dynamic Type
- Test with VoiceOver
- Ensure sufficient color contrast

## Testing

### Unit Tests
- Write tests for all business logic
- Follow the AAA pattern (Arrange, Act, Assert)
- Use descriptive test names that explain the scenario and expected outcome
- Mock dependencies to isolate the code being tested

### UI Tests
- Test critical user flows
- Focus on user interactions rather than implementation details
- Use accessibility identifiers to locate UI elements

### Test Coverage
- Aim for high test coverage of models and business logic
- Prioritize testing complex logic and edge cases
- Include regression tests for fixed bugs

## Git Workflow

### Branching Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features or enhancements
- `bugfix/*`: Bug fixes
- `release/*`: Release preparation

### Commit Messages
- Use clear, descriptive commit messages
- Follow a consistent format:
  ```
  [Type]: Short summary (50 chars or less)

  More detailed explanation if necessary. Wrap at 72 characters.
  Explain the problem that this commit is solving.
  ```
- Types: `Feature`, `Fix`, `Docs`, `Style`, `Refactor`, `Test`, `Chore`

### Pull Requests
- Keep PRs focused on a single change
- Include a clear description of changes
- Reference related issues
- Ensure all tests pass before merging

## Performance Considerations

### Memory Management
- Avoid strong reference cycles (use `weak` or `unowned` when appropriate)
- Be mindful of memory usage in large collections
- Profile memory usage regularly

### Rendering Performance
- Minimize view updates
- Use `@State` and `@Binding` appropriately
- Consider using `EquatableView` for complex views
- Profile UI performance with Instruments

### Network Operations
- Implement proper caching
- Handle errors gracefully
- Show loading states
- Cancel unnecessary requests