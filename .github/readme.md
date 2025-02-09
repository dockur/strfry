<h1 align="center">strfry-docker<br />
<div align="center">
<a href="https://github.com/dockur/strfry"><img src="https://raw.githubusercontent.com/dockur/strfry/master/.github/logo.svg" title="Logo" style="max-width:100%;" width="128" /></a>
</div>
<div align="center">
  
[![Build]][build_url]
[![Version]][tag_url]
[![Size]][tag_url]
[![Package]][pkg_url]
[![Pulls]][hub_url]

</div></h1>

Docker image of [strfry](https://github.com/hoytech/strfry), a relay for the [nostr](https://github.com/nostr-protocol/nostr) protocol.

## Usage  🐳

Via Docker Compose:

```yaml
services:
  strfry:
    container_name: strfry
    image: dockurr/strfry
    ports:
        - 7777:7777
    volumes:
        - ./strfry-db:/app/strfry-db
        - ./strfry.conf:/etc/strfry.conf
    restart: always
```

Via Docker CLI:

```bash
docker run -it --rm -p 7777:7777 -v " ./strfry.conf:/etc/strfry.conf" dockurr/strfry
```

## Stars 🌟
[![Stars](https://starchart.cc/dockur/strfry.svg?variant=adaptive)](https://starchart.cc/dockur/strfry)

[build_url]: https://github.com/dockur/strfry/
[hub_url]: https://hub.docker.com/r/dockurr/strfry/
[tag_url]: https://hub.docker.com/r/dockurr/strfry/tags
[pkg_url]: https://github.com/dockur/strfry/pkgs/container/strfry

[Build]: https://github.com/dockur/strfry/actions/workflows/build.yml/badge.svg
[Size]: https://img.shields.io/docker/image-size/dockurr/strfry/latest?color=066da5&label=size
[Pulls]: https://img.shields.io/docker/pulls/dockurr/strfry.svg?style=flat&label=pulls&logo=docker
[Version]: https://img.shields.io/docker/v/dockurr/strfry/latest?arch=amd64&sort=semver&color=066da5
[Package]: https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fipitio.github.io%2Fbackage%2Fdockur%2Fstrfry%2Fstrfry.json&query=%24.downloads&logo=github&style=flat&color=066da5&label=pulls
