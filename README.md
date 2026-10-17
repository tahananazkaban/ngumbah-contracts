# ngumbah-contracts

Shared gRPC contracts for Ngumbah services. This repository is the single source of truth for every service API; services generate their own code from a release tag.

## Layout

| Package | Contents |
|---|---|
| `ngumbah.tenant.v1` | `TenantService.GetTenant` |

Packages are named `ngumbah.<domain>.v<major>`. Event schemas will live under `ngumbah.events.<domain>.v<major>` when they are introduced.

Protos contain no language-specific options (such as `go_package`); each consumer sets package paths in its own generation config.

## Gates

```sh
make check   # format-check, lint, breaking, go-check (same as CI)
```

| Command | What it checks |
|---|---|
| `make format-check` | Protos are in canonical Buf format (`make format` fixes them) |
| `make lint` | Buf `STANDARD` lint rules |
| `make breaking` | No breaking change against the latest `v*` tag (`FILE` rules); skipped before the first release |
| `make go-check` | Generated Go code compiles |

Requires Buf 1.74.0 and Go 1.27 (see `make doctor` in `ngumbah-platform`).

## Versioning

Releases are semantic version tags (`v0.1.0`, `v0.2.0`, ...), each with a GitHub release listing what changed.

- **Compatible changes** (new RPCs, messages, fields or enum values) bump the minor version.
- **Incompatible changes** are never made to an existing package. Create a new package version (`v2`) next to the old one and migrate consumers.
- Never reuse or renumber a field. When removing a field, add its number and name to `reserved`.
- `make breaking` enforces this and has no bypass.

## Consuming the contract

Generate from the Git repository at a tag; no registry or account is needed.

**Go** — pin the plugins as tool dependencies in the consumer module:

```sh
go get -tool google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.12
go get -tool google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.6.2
```

Add a `buf.gen.yaml` with managed mode, setting `go_package_prefix` to the consumer's module path:

```yaml
version: v2
managed:
  enabled: true
  override:
    - file_option: go_package_prefix
      value: github.com/tahananazkaban/<consumer-repo>/gen
plugins:
  - local: ["go", "tool", "protoc-gen-go"]
    out: gen
    opt: paths=source_relative
  - local: ["go", "tool", "protoc-gen-go-grpc"]
    out: gen
    opt: paths=source_relative
```

Then generate from the tag:

```sh
buf generate "https://github.com/tahananazkaban/ngumbah-contracts.git#tag=v0.1.0"
```

**Rust** — generate with `tonic`/`prost` from the same tag (set up with the first Rust service).
