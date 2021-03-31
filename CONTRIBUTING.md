### Release guide

#### Preparation

Ensure that:
1. All PRs to be included in the release have been merged.
1. `CHANGELOG.md` details all changes relevant to end users and that PR links are correct.
1. The release date in `CHANGELOG.md` is correct.
1. The `VERSION` in `maze.rb` is correct for the release and that `Gemfile.lock` is up-to-date (run `bundle install`).
1. The last merge to `master` (or relevant major version branch) built and ran all tests successfully.

If the release will create a new major version, also ensure that:
1. The `Push Docker image for tag` step in `.buildkite/pipeline.yml`
   1. Will recognise the new tag in the `if` condition.
   1. Pushes the built release image with the correct tag for the major release stream (e.g. `latest-v6-cli`)

#### Performing the release

1. On Github, 'Draft a new release':
   1. Tag version - of the form v5.0.1
   1. Target - generally `master` unless the release is a minor/patch for a previous major version for which we have a branch.
   1. Release title - as the Tag version
   1. Description - copy directly from `CHANGLEOG.md`, ensuring that the formatting looks correct in the preview.

#### After the release

1. Ensure that any integration branches that exist are brought up-to-date.
