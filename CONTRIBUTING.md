# Contributing

Contributions to code, tests and documentation are welcome. Keep each change
focused on one problem. Discuss large changes with the maintainers before
implementation. Be respectful and constructive in discussions.

## Report a problem

Search the repository's issues and pull requests first. For a bug, include the
steps to reproduce it, the expected result and the actual result. Use synthetic
examples rather than personal data, credentials or private datasets.

Do not disclose vulnerabilities in public issues or pull requests. Follow
[HMRC's security reporting guidance](https://www.gov.uk/guidance/report-a-security-vulnerability-in-an-hmrc-online-service).

## Fork and branch

1. Fork this repository on GitHub if you do not have write access.
2. Clone your fork using the SSH URL shown by GitHub's Code button.
3. Add this repository's SSH URL as the `upstream` remote with `git remote add upstream`, followed by that URL.
4. Run `git fetch upstream`, then `git switch -c describe-your-change upstream/main`.
5. Follow the setup instructions in [README.md](README.md).

If you have write access, create a branch from the current `main` branch instead
of using a fork. Do not commit directly to `main`.

## Make and check your change

- Follow the existing source and test patterns.
- Add or update tests for changed behaviour and documentation for changed setup.
- Run the relevant checks described in the README and the repository's CI configuration.
- Use the [GOV.UK content guidance](https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/style-guides/) for clear, task-focused prose.
- Keep secrets, credentials, state files, database dumps and personal data out of commits and screenshots.
- Do not run deployment, cleanup or live integration commands just to check a documentation change. Confirm the target and obtain approval before changing shared resources.

If the repository provides pre-commit hooks, install them with
`pre-commit install`. Read the configuration before running all hooks: some
checks need infrastructure tools or access. Report any checks you cannot run.
Do not describe an unavailable check as passed.

## Open a pull request

1. Make small, logical commits with conventional subjects, such as `docs: clarify setup`. Put an existing ticket reference in the commit body.
2. Push your branch to your fork with `git push -u origin describe-your-change`.
3. Open a pull request against this repository's `main` branch.
4. Use the repository's pull request template where provided. Explain the problem, change and risk in short sentences.
5. Select one risk level. Apply the matching risk label if you have permission; otherwise ask a maintainer to apply it.
6. Respond to review comments and wait for the required checks and maintainer approval.

Fork workflows do not receive repository secrets. Maintainers handle checks
that need privileged access. Do not copy secrets to a fork or bypass workflow
restrictions. Check the deployment notes before pushing to an organisation
branch: some repositories deploy development environments automatically.

## Licence and attribution

Follow the [licence guidance](README.md#licence). Preserve existing copyright
notices. Identify the source and licence of third-party material you add.
A code licence does not grant rights to private data or permission to present a
fork as an official government service.
