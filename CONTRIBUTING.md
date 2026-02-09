# Contributing to Recoup Monorepo

This repository is a container using Git Submodules for managing multiple services.

## Making Changes to Sub-repos

When you need to modify code in a sub-folder (e.g., api/), treat that folder as its own independent Git repository.

1. Change your working directory to the specific sub-repo: `cd api`

2. Create a new branch: `git checkout -b feature-branch`

3. Make your changes.

4. Commit: `git commit -m "Your message"`

5. Push to origin: `git push origin feature-branch`

6. Open the PR against the sub-repo's main branch.

**Important:** Do NOT open PRs on this parent repository.
