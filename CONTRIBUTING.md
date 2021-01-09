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
   1. Pushes the built release image with the correct tag for the major release stream (e.g. `latest-v4-cli`)

As branches are merged to `master` we automatically trigger builds in out major notifiers against the new `master` 
version, which is useful for assessing the possible impact of a release on our notifiers.  Some judgement should be 
applied here on whther the triggered builds need to run to completion (typically they don't) and whether the 
`maze-runner-master` branches that are built for each notifier pipeline are sufficiently up-to-date.

#### Performing the release

1. On Github, 'Draft a new release':
   1. Tag version - of the form v3.6.0
   1. Target - generally `master` unless the release is a minor/patch for a previous major version for which we have a branch.
   1. Release title - as the Tag version
   1. Description - copy directly from `CHANGLEOG.md`, ensuring that the formatting looks correct in the preview.

#### After the release

1. Ensure that any integration branches that exist are brought up-to-date.
