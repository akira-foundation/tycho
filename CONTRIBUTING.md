# Contributing to Tycho

Tycho is a private repository. Access to the `akira-foundation` organisation is required to contribute.

## Bugs and feature requests

Open an issue at https://github.com/akira-foundation/tycho/issues. Include:

- What you expected to happen.
- What actually happened.
- A minimal reproduction.
- Versions: Tycho, Xcode and the OS (iOS 27 or macOS 27).

## Working on a pull request

1. Create a branch from `main` named `<type>/<issue-number>-<kebab-title>`, for example `feat/12-board-drag`.
2. Build with Xcode 27. Add tests for the change.
3. Run `make lint && make test` before pushing. Run `make build` when the app target changes.
4. Use Conventional Commits (`feat(board): add column collapse`). The changelog is generated from
   them via [git-cliff](https://git-cliff.org). Mark breaking changes with `!`.
5. Open the pull request against `main`. Keep the diff focused: refactors, feature work and
   dependency bumps belong in separate pull requests.

## Style

- swift-format and SwiftLint are the source of truth; `make format` rewrites the sources.
- No comments that narrate the code. Names should carry the meaning.
- No drive-by refactors in feature pull requests.
- No emojis in code, copy, commit messages or pull request descriptions.

## License

By contributing, you agree that your contributions will be dual-licensed
under MIT and Apache-2.0, as described in [LICENSE-MIT](LICENSE-MIT) and
[LICENSE-APACHE](LICENSE-APACHE).
