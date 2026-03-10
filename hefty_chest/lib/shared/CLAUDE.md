# Shared Layer

Reusable widgets and theme. Feature-agnostic — never import from `lib/features/`.

## What Belongs Here

- Theme configuration (`app_colors.dart`, `heft_theme.dart`)
- Reusable widgets used by 2+ features (nav bar, dialogs, pickers)
- Formatting utilities (`formatters.dart`)

## What Does NOT Belong Here

- Feature-specific widgets → put in `lib/features/{name}/widgets/`
- Business logic or providers → put in `lib/features/{name}/providers/`
- RPC clients or config → put in `lib/core/`

## Rules

- Widgets are pure UI: no providers, no RPC calls. Pass data and callbacks via constructor.
- All colors via `AppColors.*` constants. No hardcoded `Color(0xFF...)`.
- Use `forui` components (`FButton`, `FTextField`, `FProgress`, `FDialog`).
- Shared widgets must be prop-driven and self-contained.

## Allowed Imports

- `lib/core/*` (config, logging)
- `lib/gen/*` (proto types, if needed for display)
- NEVER import from `lib/features/*`
