# Contributing to this project

First off, thanks for taking the time to contribute!

The following is a set of guidelines for contributing to the Superside project.

## Submission Guidelines

Before you submit your Pull Request (PR) consider the following guidelines:

1. Search for an open or closed PR that relates to your submission. You don't want to duplicate existing efforts.
2. Create a branch with the name: `<type>/<issue-id>-[<short-description>]` (i.e: `feature/DE-0000`, `bugfix/DE-0000-add-missing-dependency`, etc).
3. Commit your changes using a descriptive commit message that follows our commit message conventions. Adherence to these conventions is necessary because release notes are automatically generated from these messages.
4. Run the full test suite and ensure that all tests pass.
5. Create a PR and complete the appropriate PR template.
6. Request a person to review your PR.
7. Check the status of the Continuous Integration (CI) pipelines.
8. Fix your code according to the code reviewer's feedback.
9. After approval, merge your PR into the main/master branch.

## PR titles convention

As we mainly work remotely and async, we encourage you to follow this convention just to keep the team posted about your work.

When you just started coding your changes, please open a PR with the following title structure:

```text
[WIP] [DE-XXXX] <short-description>
```

Where `WIP` means Work In Progress, `DE-XXXX` is the issue ID related to your PR, and `<short-description>` might be something like `Add missing dependency`.
This way, any member of the team can easily notice that you're working on your changes, but they aren't ready yet, thus, the PR is not ready to be reviewed.

When you're ready to change your PR status, please modify the title to match the following structure:

```text
[RFC] [DE-XXXX] <short-description>
```

Where `RFC` means Request For Comments, and the team understands that is ready for review.

## Commit message conventions

This convention dovetails with [SemVer](https://semver.org/spec/v2.0.0.html) and provides an easy set of rules for creating an explicit commit history, by describing the features, fixes, and breaking changes made in commit messages.
_This specification is inspired by the [Conventional Commits 1.0.0 format](https://www.conventionalcommits.org/en/v1.0.0/), though you're encouraged to read it from the source._

Each commit message consists of a **header**, an optional **body**, and an optional set of **trailers**.

```txt
<header>
<BLANK LINE>
<body>
<BLANK LINE>
<trailer(s)>
```

The `header` is mandatory and must conform to the header format.

### Header

```txt
<type>[(<scope>)][!]: <description>
  │       │       |      │
  │       │       |      └─⫸ Summary in present tense. Not capitalized. No period at the end.
  |       |       │
  │       │       └─⫸ To draw attention to breaking change. Optional.
  │       │
  │       └─⫸ Commit Scope. Optional.
  │
  └─⫸ Commit Type.
```

The `<type>` and `<description>` fields are mandatory, the `(<scope>)` field is optional.

#### Type

Must be one of the following:

- **fix**: A bug fix.
- **chore**: Changes to the build process or auxiliary tools and libraries.
- **cicd**: Changes to our CI/CD configuration files and scripts.
- **docs**: Documentation only changes.
- **feat**: A new feature.
- **hotfix**: Deploy a bugfix faster.
- **perf**: A code change that improves performance.
- **refactor**: A code change that neither fixes a bug nor adds a feature.
- **release**: A release of the project.

#### Scope

The following is the list of supported scopes:

- `cicd`
- `docker`
- `infra`
- none/empty string: useful for `test` changes that are done across all packages (i.e `test: add the X test`)

#### Description

Use the description field to provide a succinct description of the change:

- use the imperative, present tense: "change" not "changed" nor "changes"
- don't capitalize the first letter
- no dot (.) at the end

### Body

The body is a more detailed explanatory text of the header. Wrap it to about 72 characters or so.

### Trailer(s)

- `BREAKING CHANGE: <description>`: a commit that has a footer `BREAKING CHANGE:`, or appends a `!` after the type/scope, introduces a breaking API change (correlating with [`MAJOR`](https://semver.org/#summary) in `semantic versioning`). A `BREAKING CHANGE` can be part of commits of any type.

Trailers other than the above list may be provided and follow a convention similar to the [git trailer format](https://git-scm.com/docs/git-interpret-trailers).

### Good commit message examples

To view more examples, you can always read the [conventional commits examples](https://www.conventionalcommits.org/en/v1.0.0/#examples).

Commit message with body and trailer

```txt
feat(docker): add airflow triggerer service

Add airflow triggerer service in order to allow
deferrable operators usage in the ETL pipeline.

Signed-off-by: Hernán Vignolo vignolo.hernan@gmail.com
```

Commit message with no body

```txt
docs: readme typo
```

Commit message with both `!` and `BREAKING CHANGE` trailer

```txt
chore!: drop support for python 2.7

BREAKING CHANGE: remove Python 2.7 features
```

**For merge commits**, make sure to leave the default commit message and change nothing else in the diff after resolving conflicts.
