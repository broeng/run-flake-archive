# Run flake from archive

Simple nix flake based script acting as a "trampoline" for running flakes contained in various
hosted archives, instead of git repositories.

Given an URL to an archive (e.g. tarball) hosted somewhere, and containing a flake.nix in the root,
it will download the archive, initialize an empty git repository locally, and add the contents of
the archive, including flake.nix, to the repository, and run the default target of the flake.

Will optionally accept a username and password for Basic auth through the environment variables
`CURL_USERNAME` and `CURL_PASSWORD`.

## Usage

Downloading and running the `flake.nix` located at the root of the `my-artifact.tgz` archive:

```
nix run github:broeng/run-flake-archive -- https://repository.domaint.tld/my-artifact.tgz
```

As the archive will be unpackaged and added to the temporary git repository, the flake is
able to reference any other files included in the archive.

## Why?

It's not always convenient, that a flake has to be hosted in a git repository, this provides
an alternative.

We use it internally to run some services in kubernetes based on the `nixos/nix` docker image,
instead of prebuilding and storing containers.

For a simple docker example, we can launch a service with this:

```
sudo docker run -t -i \
  --env-file env-secrets \
  nixos/nix:latest \
  /bin/sh -c \
  "nix run --extra-experimental-features flakes --extra-experimental-features nix-command github:broeng/run-flake-archive -- https://repository.domain.tld/my-service-artifact.tar"
```
