# My Infrastructure as Code repo [![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fz3ji%2Fnixioc)](https://garnix.io)

Modifications to the system are (or, at the very least, ought to be) recorded within this document.

# File System structure

See hosts/[host]/fs.nix.

Disk formatting should be configured with `nix run .#fs_cli -- [host] apply`.

# Hosts

Replace `[host]` with one of the following:
- `leda`: My laptop (i7-4558U, Iris 5100).
- `dia`: My desktop (Ryzen 5 3600, RX 5700 XT)

