Docker Image for Siege Load Testing
---
Docker image containing [Siege](https://github.com/JoeDog/siege)- http load tester and benchmarking utility.

## Overview

The Dockerfile has a default `ENTRYPOINT` of siege and all arguments passed after the container image will pass to
siege. The default argument is `--help`.

## Example

```shell
docker run \
  --rm \
  -t \
  -u 65532:65532 \
  z7sv/siege-docker:latest \
  https://example.com
```
