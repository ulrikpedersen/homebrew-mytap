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

## Using the Docker container

Building the docker container with:
`docker build --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') -t brew-mytap:latest .`

Run the container interactively with:
`docker run --rm -it --name=mytap brew-mytap`

Or just use the container to run and test a single build or installation command:
`docker run --rm -it brew-mytap <command>`

For example to run the test-bot on a formula (e.g. autosave):
`docker run --rm -it brew-mytap brew test-bot --only-formulae --verbose --tap ulrikpedersen/mytap autosave`

