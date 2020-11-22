# EPICS HomeBrew Tap

This is a [homebrew](https://brew.sh/) "tap" which enables easy rebuild and installation of many popular EPICS software packages on Apple's MacOS.

EPICS base and support modules are all installed 'keg-only' as this approach best matches the common way of installing EPICS modules with the way homebrew installs packages. As a result EPICS modules in a typical homebrew installation can be found at `/usr/local/opt/<module>`. e.g. `EPICS_BASE=/usr/local/opt/epics-base`.

Some extensions, such as medm, are installed in the central homebrew installation prefix and as a result automatically available on the path.

## How do I install these formulae?
`brew install ulrikpedersen/mytap/<formula>`

Or `brew tap ulrikpedersen/mytap` and then `brew install <formula>`.

## How do I develop/test new formulae?

Whenever editing a formula file, run the basic syntax check. It is rather strict:
`brew style ulrikpedersen/mytap`

Alternatively run the brew test-bot syntax checker - same as runs on github actions:
`brew test-bot --only-tap-syntax --tap ulrikpedersen/mytap`

To test a new build of a formula:
 * Make the change to or add the formula.
 * Create and checkout a branch with the name of the formula.
 * Commit the formula file to the branch with the top line comment "<formula> <version> (<description>)" where description is "new formula" or "update version".
 * Test build with `brew install --debug --verbose <user/tap/formula>`
  * Sometimes you'll need to uninstall the tap first: `brew uninstall --force <formula>`
 * Edit, fix, commit, test...
 * Finally test with test-bot: `brew test-bot --only-formulae --verbose --tap ulrikpedersen/mytap <formula>`

When all is working, push branch to github, and raise PR into main branch. Wait for github actions to complete with all green ticks before merging.