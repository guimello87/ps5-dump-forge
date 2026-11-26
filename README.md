# ps5-dump-forge (Docker)

Unofficial container image for [PS5 Dump Forge](https://github.com/quer3q/ps5-dump-forge)'s web UI
(`ps5-dump-forge serve`). Upstream publishes no image, so this repo builds one from each upstream
release tag (GPL-3.0; source: the upstream repo at the matching tag).

A GitHub Actions workflow checks daily for a new upstream release and pushes
`ghcr.io/guimello87/ps5-dump-forge:<version>` and `:latest`.

## Run

```sh
docker run -d --name ps5-dump-forge --net host --user 99:100 \
  -v /mnt/user/appdata/ps5-dump-forge/config:/config \
  -v /mnt/user/ps5/PS5:/games \
  ghcr.io/guimello87/ps5-dump-forge:latest
```

Web UI on port 8095. Extra roots: append `--root /other` (the container's arguments replace the
default `--root /games`). The UI has **no authentication** — LAN/Tailscale only.

Manual rebuild of a specific version: Actions → *build image* → Run workflow → `v0.5.7`.
Note: GitHub pauses scheduled workflows after 60 days without repository activity; re-enable it in
the Actions tab if that happens.
