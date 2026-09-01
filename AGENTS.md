# AI Agent Operating Contract

This file is a generic entrypoint for AI agents working in this repository. It must remain capability-neutral: do not treat any one skill, workflow, or agent as the only supported future capability.

## Discover available instructions

Before acting, inspect the current project and relevant parent directories for instruction and capability files. The list is extensible and may grow over time; do not assume it is complete.

Look for:

- `AGENTS.md` files in the current and parent directories.
- `.agents/skills/*/SKILL.md`.
- `.agents/workflows/*`.
- `.agents/rules/*`.
- Environment-specific instructions such as `.cursor/rules/*`, `.trae/rules/*`, `CLAUDE.md`, `GEMINI.md`, and `.github/copilot-instructions.md`.

Load only the instructions relevant to the current request. A skill’s description and trigger determine whether it applies; do not invoke unrelated skills.

## Instruction precedence

When instructions conflict, apply this order:

1. The user’s current request.
2. The closest applicable project instruction.
3. Parent-directory or global instructions.
4. General agent behavior.

Follow explicit safety and scope boundaries from the applicable skill. Ask the user when an unresolved decision materially changes the requested outcome; do not invent requirements.

## Change discipline

Inspect before modifying. Keep changes within the user’s requested scope. Preserve unrelated work already present in the repository. Before reporting completion, verify the requested outcome and identify files changed and checks performed.

## Project-specific capability discovery

Project-specific skills and rules are stored under `.agents/`. Future capabilities should be added there with their own focused instructions and workflows. This generic contract should not be edited merely because a new skill or rule is introduced.
