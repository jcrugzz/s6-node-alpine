# s6-node-alpine

A simple alpine container based on my fork of
[`base-alpine`](https://github.com/just-containers/base-alpine) until their
build is working properly to provide the s6 process runner and use the same
installation method as [`alpine-node`](https://github.com/mhart/alpine-node)
to install node.

We also build various flavors of this image, all post-fixed with the node
version as well as the optional "types". e.g `jcrugzz/s6-node-alpine:12.13.1`
and `jcrugzz/s6-node-alpine:12.13.1-intl`

## Types

The types include:

### `-intl`

For those who need internationalization data built into node binary.

### `-native`

Does not remove the native dependencies that node needs to build (makes the
container slightly larger)

### `-native-intl`

Does not remove the native dependencies that node needs to build (makes the
container slightly larger) and bakes in the internationalization data.

Each of these builds for a given node version can be found as a tag in this
repo.
