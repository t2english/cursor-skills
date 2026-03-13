# README Template

Use this template when creating a README for a new project or performing a
major update to an existing one.

## Template

```markdown
# <Project Name>

<One-line description of what the project does and why it exists.>

## Quick Start

```bash
# 1. Clone
git clone <repo-url>
cd <project-name>

# 2. Install dependencies
<package-manager> install

# 3. Configure
cp .env.example .env
# Edit .env with your values

# 4. Run
<package-manager> dev
```

## Architecture

<Brief description of the system architecture. Include a diagram for
complex projects (Mermaid, ASCII, or image).>

## Development

### Prerequisites

- <Runtime> >= <version>
- <Package manager> >= <version>
- <Database> (if applicable)

### Setup

```bash
<package-manager> install
<package-manager> db:migrate   # if applicable
<package-manager> dev
```

### Testing

```bash
<package-manager> test           # unit tests
<package-manager> test:e2e       # end-to-end tests
<package-manager> test:coverage  # coverage report
```

### Project Structure

```
src/
  ├── <directory>/   # <purpose>
  ├── <directory>/   # <purpose>
  └── <directory>/   # <purpose>
```

## Deployment

<How to deploy, which environments exist, and any deployment-specific
configuration or commands.>

## Contributing

1. Create a branch: `<type>/<description>` (e.g., `feat/add-auth`)
2. Follow existing code conventions
3. Write tests for new functionality
4. Open a PR against `main`

## License

<License type and link>
```

## Guidelines

- **Quick Start under 5 steps**: A new developer should be running the project
  within 5 commands. Move detailed configuration to a separate doc.
- **Keep it current**: The README is the first thing people read. Outdated
  instructions erode trust faster than missing instructions.
- **Architecture for complex projects**: If the project has more than 3
  services or significant infrastructure, include a diagram.
- **Don't duplicate**: Link to detailed docs instead of inlining them.
  The README is a landing page, not a manual.
- **Prerequisites with versions**: Always specify minimum versions for
  runtimes, package managers, and databases.
