# Workspace Agent Rules - Log404

## 1. Git Repository Scoping Constraint
- All Git operations (`git add`, `git commit`, `git push`, `git pull`, `git status`) MUST be executed STRICTLY within the `/Users/juhee/IdeaProjects/Log404` workspace directory.
- `git push` must exclusively target `origin main` for `https://github.com/juhee77/Log404.git`.
- Absolute prohibition: NEVER execute any Git commands or push operations to external projects (e.g., `TripGather` or any directory outside `Log404`).

## 2. Asset & Design Aesthetic Guidelines
- Always use procedural 2.5D vector graphics fallback or approved 2D game assets.
- Never use photographic or AI images that clash with 2.5D game art style.

## 3. Engine & Platform Optimization
- Keep Godot 4 mobile layout scaling set to `stretch/mode="canvas_items"`, `stretch/aspect="expand"`.
- Maintain unified 2.5D scroll positioning across all rooms and objects.
