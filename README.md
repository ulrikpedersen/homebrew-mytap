# EPICS HomeBrew Tap

This is a [homebrew](https://brew.sh/) "tap" which enables easy rebuild and installation of many popular EPICS software packages on Apple's MacOS.

EPICS base and support modules are all installed 'keg-only' as this approach best matches the common way of installing EPICS modules with the way homebrew installs packages. As a result EPICS modules in a typical homebrew installation can be found at `/usr/local/opt/<module>`. e.g. `EPICS_BASE=/usr/local/opt/epics-base`.

Some extensions, such as medm, are installed in the central homebrew installation prefix and as a result automatically available on the path.

