# Docker Container(s)

This Docker Container is set up all the necessary development tools for the
cmake environment to compile and test various projects

The container is published as `gitlab.com/retleksystems/cmake/sw-dev` on
[gitlab.com](https://gitlab.com).

It also installs a Dependencies directory to reduce the download time of
common dependent projects.
## Rebuilding

Taken care of by gitlab-ci - when a new tag is generated.

## ESP-IDF environment(s)

The esp-idf environment is an install of the esp-idf (version) tools and code on top of the base sw-dev docker image.
There are slight modifications to the [ESP-IDF docker files](https://github.com/espressif/esp-idf/blob/v4.4.3/tools/docker).
