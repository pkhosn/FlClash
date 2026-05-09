# V2ET on FlClash Migration Plan

## Goal
Keep V2ET UI behavior while replacing backend/runtime logic with FlClash core capability.

## Principles
- Keep current UI unchanged during backend migration.
- Replace backend by adapter layer, not direct page-to-core calls.
- Migrate in small compilable steps.

## Stage 1 (current)
- Introduce `v2et_bridge` abstract contracts.
- Keep existing FlClash app behavior unchanged.

## Stage 2
- Implement bridge by wrapping FlClash managers/providers.
- Wire login/session/subscription storage.

## Stage 3
- Port V2ET pages onto FlClash app shell.
- Route V2ET actions through bridge only.

## Stage 4
- Platform verification: Windows first, then all platforms in matrix build.

## Acceptance for each stage
- App compiles.
- Existing functions do not regress.
- New V2ET path is testable in Actions artifacts.
