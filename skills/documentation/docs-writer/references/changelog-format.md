# Changelog Format

Follow [Keep a Changelog](https://keepachangelog.com/) conventions with
conventional commit grouping.

## Template

```markdown
# Changelog

## [Unreleased]

### Added
- <New features or capabilities>

### Changed
- <Changes to existing functionality>

### Fixed
- <Bug fixes>

### Removed
- <Removed features or deprecated functionality>

### Security
- <Security-related changes or vulnerability fixes>

## [X.Y.Z] - YYYY-MM-DD

### Breaking Changes
- <List breaking changes prominently at the top>

### Added
- <New feature description> (reference: #issue or PR)

### Changed
- <Enhancement to existing feature>

### Fixed
- <Bug fix description> (reference: #issue or PR)

### Removed
- <Deprecated feature removed>
```

## Generating from Git

```bash
# Find last tag
git describe --tags --abbrev=0

# List commits since last tag
git log --oneline <last-tag>..HEAD

# Group by conventional commit prefix:
#   feat:     → Added
#   fix:      → Fixed
#   perf:     → Changed (Performance)
#   refactor: → Changed
#   docs:     → Changed (Documentation)
#   chore:    → Changed (Maintenance)
#   BREAKING CHANGE: → Breaking Changes (always at top)
```

## Guidelines

- **Human-readable summaries**: Rewrite commit messages into clear descriptions.
  Don't paste raw commit messages.
- **Breaking changes first**: Always list breaking changes at the top of a
  release section, before other categories.
- **Link to issues/PRs**: Reference the issue or PR number for traceability.
- **Contributors**: Include contributor names if multiple authors contributed
  to the release.
- **Dates**: Use ISO 8601 format (YYYY-MM-DD).
- **Semver**: Follow semantic versioning (MAJOR.MINOR.PATCH).
  - MAJOR: breaking changes
  - MINOR: new features (backward compatible)
  - PATCH: bug fixes (backward compatible)
- **Unreleased section**: Keep an `[Unreleased]` section at the top for
  changes not yet tagged.
