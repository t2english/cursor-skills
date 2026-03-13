#!/usr/bin/env bash
set -euo pipefail

# Cursor Skills Installer
# Install, update, remove, and manage Cursor skills from this repository.

SKILLS_TARGET="$HOME/.cursor/skills"
BACKUP_DIR="$SKILLS_TARGET/.backup"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_SRC="$SCRIPT_DIR/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Counters
INSTALLED=0
UPDATED=0
REMOVED=0
SKIPPED=0

print_header() {
  echo -e "\n${BOLD}${CYAN}╔══════════════════════════════════════╗${NC}"
  echo -e "${BOLD}${CYAN}║     Cursor Skills Installer v2.0     ║${NC}"
  echo -e "${BOLD}${CYAN}╚══════════════════════════════════════╝${NC}\n"
}

info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✓${NC}  $1"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
error()   { echo -e "${RED}✗${NC}  $1"; }

discover_skills() {
  local skills=()
  while IFS= read -r skill_md; do
    local skill_dir
    skill_dir="$(dirname "$skill_md")"
    local skill_name
    skill_name="$(basename "$skill_dir")"
    skills+=("$skill_name")
  done < <(find "$SKILLS_SRC" -mindepth 3 -maxdepth 3 -name "SKILL.md" 2>/dev/null | sort)
  echo "${skills[@]}"
}

get_skill_path() {
  local name="$1"
  local result
  result="$(find "$SKILLS_SRC" -mindepth 2 -maxdepth 2 -type d -name "$name" 2>/dev/null | head -1)"
  echo "$result"
}

get_skill_category() {
  local name="$1"
  local skill_path
  skill_path="$(get_skill_path "$name")"
  if [[ -n "$skill_path" ]]; then
    local cat_dir
    cat_dir="$(basename "$(dirname "$skill_path")")"
    echo "$cat_dir"
  fi
}

get_category_skills() {
  local category="$1"
  local skills=()
  local cat_dir="$SKILLS_SRC/$category"
  if [[ -d "$cat_dir" ]]; then
    while IFS= read -r skill_dir; do
      skills+=("$(basename "$skill_dir")")
    done < <(find "$cat_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
  fi
  echo "${skills[@]}"
}

is_installed() {
  local name="$1"
  [[ -d "$SKILLS_TARGET/$name" && -f "$SKILLS_TARGET/$name/SKILL.md" ]]
}

backup_skill() {
  local name="$1"
  if [[ -d "$SKILLS_TARGET/$name" ]]; then
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/${name}-${timestamp}"
    mkdir -p "$BACKUP_DIR"
    cp -r "$SKILLS_TARGET/$name" "$backup_path"
    info "Backup: ${name} → .backup/${name}-${timestamp}/"
  fi
}

copy_skill() {
  local name="$1"
  local src_path
  src_path="$(get_skill_path "$name")"

  if [[ -z "$src_path" ]]; then
    error "Skill not found: ${name}"
    return 1
  fi

  mkdir -p "$SKILLS_TARGET/$name"

  if command -v rsync &>/dev/null; then
    rsync -a --delete "$src_path/" "$SKILLS_TARGET/$name/"
  else
    rm -rf "$SKILLS_TARGET/$name"
    cp -r "$src_path" "$SKILLS_TARGET/$name"
  fi
}

install_skill() {
  local name="$1"
  local dry_run="${2:-false}"
  local force="${3:-false}"

  if [[ "$dry_run" == "true" ]]; then
    if is_installed "$name"; then
      info "[dry-run] Would update: ${BOLD}${name}${NC}"
    else
      info "[dry-run] Would install: ${BOLD}${name}${NC}"
    fi
    return 0
  fi

  if is_installed "$name" && [[ "$force" != "true" ]]; then
    backup_skill "$name"
    copy_skill "$name"
    success "Updated: ${BOLD}${name}${NC}"
    ((UPDATED++))
  else
    copy_skill "$name"
    success "Installed: ${BOLD}${name}${NC}"
    ((INSTALLED++))
  fi
}

remove_skill() {
  local name="$1"
  local dry_run="${2:-false}"

  if ! is_installed "$name"; then
    warn "Skill not installed: ${name}"
    return 0
  fi

  if [[ "$dry_run" == "true" ]]; then
    info "[dry-run] Would remove: ${BOLD}${name}${NC}"
    return 0
  fi

  read -rp "Remove skill '${name}'? [y/N] " confirm
  if [[ "$confirm" =~ ^[yY]$ ]]; then
    backup_skill "$name"
    rm -rf "$SKILLS_TARGET/$name"
    success "Removed: ${BOLD}${name}${NC}"
    ((REMOVED++))
  else
    info "Skipped: ${name}"
    ((SKIPPED++))
  fi
}

list_skills() {
  local all_skills
  read -ra all_skills <<< "$(discover_skills)"

  echo -e "${BOLD}Available Skills:${NC}\n"
  printf "  ${BOLD}%-30s %-22s %-10s${NC}\n" "SKILL" "CATEGORY" "STATUS"
  printf "  %-30s %-22s %-10s\n" "─────────────────────────────" "─────────────────────" "─────────"

  for name in "${all_skills[@]}"; do
    local category
    category="$(get_skill_category "$name")"
    local status
    if is_installed "$name"; then
      status="${GREEN}✓ installed${NC}"
    else
      status="${YELLOW}○ not installed${NC}"
    fi
    printf "  %-30s %-22s " "$name" "$category"
    echo -e "$status"
  done

  echo ""
  local total=${#all_skills[@]}
  local installed_count=0
  for name in "${all_skills[@]}"; do
    is_installed "$name" && ((installed_count++))
  done
  echo -e "  ${BOLD}Total:${NC} ${installed_count}/${total} installed"
}

init_linear() {
  local template="$SCRIPT_DIR/.cursor/linear.json.example"
  local target=".cursor/linear.json"

  if [[ ! -f "$template" ]]; then
    error "Template not found: .cursor/linear.json.example"
    return 1
  fi

  if [[ -f "$target" ]]; then
    warn "File already exists: ${target}"
    read -rp "Overwrite? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
      info "Skipped."
      return 0
    fi
  fi

  mkdir -p .cursor
  read -rp "Project name for Linear: " project_name
  if [[ -z "$project_name" ]]; then
    error "Project name cannot be empty."
    return 1
  fi

  cat > "$target" <<EOF
{
  "team": "OK IA",
  "project": "${project_name}"
}
EOF

  success "Created: ${target} (project: ${project_name})"
}

print_summary() {
  echo -e "\n${BOLD}── Summary ──${NC}"
  [[ $INSTALLED -gt 0 ]] && echo -e "  ${GREEN}✓${NC} Installed: ${INSTALLED}"
  [[ $UPDATED -gt 0 ]]   && echo -e "  ${BLUE}↻${NC} Updated:   ${UPDATED}"
  [[ $REMOVED -gt 0 ]]   && echo -e "  ${RED}✗${NC} Removed:   ${REMOVED}"
  [[ $SKIPPED -gt 0 ]]   && echo -e "  ${YELLOW}○${NC} Skipped:   ${SKIPPED}"
  local total=$((INSTALLED + UPDATED + REMOVED))
  if [[ $total -eq 0 && $SKIPPED -eq 0 ]]; then
    info "No changes made."
  fi
  echo ""
}

usage() {
  echo -e "${BOLD}Usage:${NC} $0 [OPTIONS]"
  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo "  --all                 Install all available skills"
  echo "  --skills NAME[,NAME]  Install specific skills (comma-separated)"
  echo "  --category NAME       Install all skills in a category"
  echo "  --update              Update all installed skills"
  echo "  --remove NAME         Remove a skill"
  echo "  --list                List available skills and install status"
  echo "  --dry-run             Show what would be done without executing"
  echo "  --force               Force overwrite without backup"
  echo "  --init-linear         Initialize .cursor/linear.json for current project"
  echo "  --help                Show this help message"
  echo ""
  echo -e "${BOLD}Examples:${NC}"
  echo "  $0 --all                                    # Install everything"
  echo "  $0 --skills codenavi,coding-guidelines       # Install specific skills"
  echo "  $0 --category development                    # Install a category"
  echo "  $0 --update                                  # Update installed skills"
  echo "  $0 --remove codenavi                         # Remove a skill"
  echo "  $0 --all --dry-run                           # Preview installation"
  echo ""
  echo -e "${BOLD}Categories:${NC} development, documentation, github, learning, operations, orchestration, project-management, quality, security"
}

# --- Main ---

if [[ $# -eq 0 ]]; then
  print_header
  usage
  exit 0
fi

ACTION=""
SKILL_NAMES=""
CATEGORY_NAME=""
DRY_RUN="false"
FORCE="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --all)         ACTION="install_all"; shift ;;
    --skills)      ACTION="install_selected"; SKILL_NAMES="$2"; shift 2 ;;
    --category)    ACTION="install_category"; CATEGORY_NAME="$2"; shift 2 ;;
    --update)      ACTION="update"; shift ;;
    --remove)      ACTION="remove"; SKILL_NAMES="$2"; shift 2 ;;
    --list)        ACTION="list"; shift ;;
    --dry-run)     DRY_RUN="true"; shift ;;
    --force)       FORCE="true"; shift ;;
    --init-linear) ACTION="init_linear"; shift ;;
    --help|-h)     print_header; usage; exit 0 ;;
    *)             error "Unknown option: $1"; usage; exit 1 ;;
  esac
done

print_header

case "$ACTION" in
  install_all)
    info "Installing all skills..."
    [[ "$DRY_RUN" == "true" ]] && warn "Dry run mode — no changes will be made."
    echo ""
    read -ra all_skills <<< "$(discover_skills)"
    for name in "${all_skills[@]}"; do
      install_skill "$name" "$DRY_RUN" "$FORCE"
    done
    [[ "$DRY_RUN" != "true" ]] && print_summary
    ;;

  install_selected)
    IFS=',' read -ra names <<< "$SKILL_NAMES"
    info "Installing ${#names[@]} skill(s)..."
    [[ "$DRY_RUN" == "true" ]] && warn "Dry run mode — no changes will be made."
    echo ""
    for name in "${names[@]}"; do
      name="$(echo "$name" | xargs)"
      install_skill "$name" "$DRY_RUN" "$FORCE"
    done
    [[ "$DRY_RUN" != "true" ]] && print_summary
    ;;

  install_category)
    read -ra cat_skills <<< "$(get_category_skills "$CATEGORY_NAME")"
    if [[ ${#cat_skills[@]} -eq 0 ]]; then
      error "No skills found in category: ${CATEGORY_NAME}"
      echo -e "  Available: development, documentation, github, learning, operations, orchestration, project-management, quality, security"
      exit 1
    fi
    info "Installing category '${CATEGORY_NAME}' (${#cat_skills[@]} skills)..."
    [[ "$DRY_RUN" == "true" ]] && warn "Dry run mode — no changes will be made."
    echo ""
    for name in "${cat_skills[@]}"; do
      install_skill "$name" "$DRY_RUN" "$FORCE"
    done
    [[ "$DRY_RUN" != "true" ]] && print_summary
    ;;

  update)
    info "Updating installed skills..."
    [[ "$DRY_RUN" == "true" ]] && warn "Dry run mode — no changes will be made."
    echo ""
    if [[ -d "$SCRIPT_DIR/.git" ]]; then
      info "Pulling latest changes..."
      git -C "$SCRIPT_DIR" pull --ff-only 2>/dev/null || warn "Could not pull (offline or no remote)."
      echo ""
    fi
    read -ra all_skills <<< "$(discover_skills)"
    local_updated=0
    for name in "${all_skills[@]}"; do
      if is_installed "$name"; then
        install_skill "$name" "$DRY_RUN" "$FORCE"
        ((local_updated++))
      fi
    done
    if [[ $local_updated -eq 0 ]]; then
      warn "No installed skills found to update."
    fi
    [[ "$DRY_RUN" != "true" ]] && print_summary
    ;;

  remove)
    remove_skill "$SKILL_NAMES" "$DRY_RUN"
    [[ "$DRY_RUN" != "true" ]] && print_summary
    ;;

  list)
    list_skills
    ;;

  init_linear)
    init_linear
    ;;

  *)
    error "No action specified. Use --help for usage."
    exit 1
    ;;
esac
