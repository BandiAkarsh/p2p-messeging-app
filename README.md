# EcoMesh - Green P2P Messenger

## Architecture Overview

Extreme modular microservice architecture where every component can be swapped without affecting others.

### Tech Stack
- **Mobile**: Flutter (Green, compiled, 20MB app size)
- **Web**: Flutter Web (shared 90% code)
- **AI**: Cloudflare Workers AI (10K neurons/day free)
- **P2P**: GUN.js + WebRTC
- **Storage**: Isar (local) + Cloudflare D1 (sync)

### Modules
- `packages/core` - Interfaces and models (shared contracts)
- `packages/adapters` - Swappable implementations
- `packages/services` - Business logic
- `apps/mobile` - iOS/Android app
- `apps/web` - Web client
- `workers/` - Cloudflare edge functions

### Quick Start
```bash
# Install dependencies
npm install

# Start development
docker-compose up -d          # Start workers
npm run dev:mobile            # Start mobile app
npm run dev:web              # Start web app

# Build for production
npm run build:all
```

### Deployment
GitHub Actions handle CI/CD. Automatic deployment paused for build verification.
