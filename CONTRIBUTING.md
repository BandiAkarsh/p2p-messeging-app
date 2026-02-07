# Contributing to EcoMesh 🤝

Thank you for your interest in contributing to EcoMesh! This document provides guidelines for contributing to the project.

---

## 🌟 Why Contribute?

EcoMesh is an **open-source, privacy-focused P2P messenger** built with enterprise-grade security. By contributing, you help:

- 🔒 Improve digital privacy for everyone
- 🌍 Make secure communication accessible
- 📚 Advance open-source cryptography
- 🚀 Build production-ready Flutter applications

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.27+
- Dart 3.0+
- Node.js 20+
- Docker & Docker Compose
- Git

### Setup Development Environment

```bash
# 1. Fork the repository
# Click "Fork" button on GitHub

# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/ecomesh-messenger.git
cd ecomesh-messenger

# 3. Add upstream remote
git remote add upstream https://github.com/BandiAkarsh/ecomesh-messenger.git

# 4. Install dependencies
pnpm install

# 5. Setup Flutter packages
cd apps/mobile && flutter pub get
cd ../web && flutter pub get
cd ../..

# 6. Start development environment
docker-compose up -d
```

---

## 🌿 Areas of Contribution

### 🔒 **Security** (High Priority)

- Security audits and penetration testing
- Cryptographic algorithm improvements
- Vulnerability assessments
- Security documentation

**Skills needed**: Cryptography, ethical hacking, security auditing

### 🎨 **UI/UX Design**

- Improve glassmorphism design
- Accessibility improvements
- Dark/light theme refinements
- Animation enhancements

**Skills needed**: Flutter UI, Material Design, Figma

### 📱 **Mobile Development**

- iOS-specific features
- Android optimizations
- Platform-specific UI
- Performance improvements

**Skills needed**: Flutter, iOS/Android native development

### 🌐 **Web Development**

- Progressive Web App (PWA) features
- WebRTC optimizations
- Browser compatibility
- Service worker improvements

**Skills needed**: Flutter Web, WebRTC, JavaScript

### 🧪 **Testing**

- Unit tests
- Integration tests
- Security tests
- Performance benchmarks

**Skills needed**: Testing frameworks, QA methodologies

### 📖 **Documentation**

- API documentation
- Code comments
- User guides
- Tutorial creation

**Skills needed**: Technical writing, documentation tools

### 🌍 **Localization**

- Translate app to other languages
- RTL language support
- Cultural adaptations

**Skills needed**: Native language speakers, i18n experience

---

## 📋 Contribution Workflow

### 1. Find or Create an Issue

- Check [existing issues](https://github.com/BandiAkarsh/ecomesh-messenger/issues)
- Create a new issue describing your proposal
- Wait for approval before starting work

### 2. Create a Branch

```bash
# Sync with upstream
git fetch upstream
git checkout main
git merge upstream/main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

**Branch Naming Convention**:

- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation
- `security/description` - Security improvements
- `refactor/description` - Code refactoring

### 3. Make Changes

**Code Standards**:

- Follow Dart/Flutter style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused

**Security Requirements**:

- Never commit private keys or secrets
- Use secure coding practices
- Validate all inputs
- Handle errors gracefully

**Example Commit Messages**:

```
feat(auth): Add biometric authentication

- Implement fingerprint/face ID login
- Add secure key storage
- Update SecurityManager configuration

Fixes #123
```

```
fix(crypto): Correct PBKDF2 salt usage

- Fix salt concatenation bug
- Update test cases
- Add validation checks

Closes #456
```

### 4. Test Your Changes

```bash
# Run all tests
flutter test
cd workers/signaling && pnpm test
cd workers/ai-worker && pnpm test

# Check code quality
flutter analyze
dart format --set-exit-if-changed .

# Build verification
flutter build web --release
flutter build apk --release
```

### 5. Submit Pull Request

```bash
# Push your branch
git push origin feature/your-feature-name

# Create PR on GitHub
```

**PR Requirements**:

- Clear title and description
- Reference related issues
- Include screenshots for UI changes
- Add tests for new features
- Update documentation if needed
- Ensure CI passes

---

## 🔒 Security Contributions

### Reporting Vulnerabilities

**DO NOT** create public issues for security bugs!

Instead:

1. Email: **akarshbandi82@gmail.com**
2. Subject: `[SECURITY] Brief description`
3. Include:
   - Detailed vulnerability description
   - Steps to reproduce
   - Potential impact
   - Suggested fix (optional)

**Response Timeline**:

- Acknowledgment: Within 48 hours
- Initial assessment: Within 7 days
- Fix deployment: Within 90 days
- Public disclosure: After fix deployed

### Security Audits

We welcome security audits! Areas of focus:

- Cryptographic implementation review
- Memory safety analysis
- Network security assessment
- Storage security evaluation

---

## 📝 Code Review Process

### What Reviewers Look For

✅ **Functionality**: Does it work as intended?  
✅ **Code Quality**: Is it clean and maintainable?  
✅ **Security**: Are there any vulnerabilities?  
✅ **Performance**: Is it optimized?  
✅ **Tests**: Are there adequate tests?  
✅ **Documentation**: Is it well documented?

### Review Etiquette

- Be respectful and constructive
- Explain reasoning for suggestions
- Approve when ready, request changes when needed
- Respond to feedback promptly

---

## 🎯 First-Time Contributors

### Good First Issues

Look for issues labeled:

- `good first issue`
- `beginner friendly`
- `documentation`
- `help wanted`

### Getting Help

- **Discord**: [Join our community](https://discord.gg/your-invite)
- **GitHub Discussions**: Ask questions
- **Email**: akarshbandi82@gmail.com

### Mentorship

New to open source? I'm happy to mentor!

- Code reviews with detailed feedback
- Pair programming sessions
- Architecture discussions
- Career advice

---

## 🏆 Recognition

### Contributors

All contributors will be:

- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Invited to contributor Discord channel
- Considered for maintainer role (after 5+ quality contributions)

### Special Recognition

- 🏆 **Security Researcher**: For vulnerability reports
- 🎨 **Designer**: For UI/UX contributions
- 🚀 **Performance**: For optimization improvements
- 📚 **Documentation**: For excellent docs

---

## 📜 Code of Conduct

### Our Standards

**Positive behavior**:

- Being respectful and inclusive
- Accepting constructive criticism
- Focusing on what's best for the community
- Showing empathy towards others

**Unacceptable behavior**:

- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information

### Enforcement

Violations may result in:

1. Warning
2. Temporary ban
3. Permanent ban

Report violations to: akarshbandi82@gmail.com

---

## 🔧 Development Tips

### Useful Commands

```bash
# Run specific test
flutter test test/identity_test.dart

# Hot reload
flutter run --hot

# Analyze code
flutter analyze

# Format code
dart format .

# Check dependencies
cd apps/web && flutter pub outdated

# Clean build
flutter clean && flutter pub get
```

### Project Structure

```
ecomesh-messenger/
├── apps/
│   ├── mobile/     # iOS/Android app
│   └── web/        # Web app
├── packages/
│   ├── core/       # Domain models
│   ├── adapters/   # Implementations
│   └── services/   # Business logic
└── workers/
    ├── signaling/  # WebRTC signaling
    └── ai-worker/  # AI features
```

---

## 📞 Contact

**Project Maintainer**: Bandi Akarsh

- 📧 **Email**: akarshbandi82@gmail.com
- 🐙 **GitHub**: [@BandiAkarsh](https://github.com/BandiAkarsh)
- 💼 **LinkedIn**: [Connect with me](https://linkedin.com/in/akarshbandi)

**Response Time**: Usually within 24-48 hours

---

## 🙏 Thank You!

Every contribution, no matter how small, helps make EcoMesh better. Whether you're:

- 🐛 Fixing a bug
- ✨ Adding a feature
- 📝 Improving docs
- 🧪 Writing tests
- 🎨 Designing UI

**You're helping build a more private and secure future!**

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

<p align="center">
  <b>Happy Contributing! 🚀</b><br>
  <i>Together we can build something amazing</i>
</p>
