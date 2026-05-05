---
name: coolify-new-site
description: Provision a new site on the personal Coolify instance (context "sai") — create project, app, storages, first deploy, and verify TLS. For redeploys/operations of an existing app, use the coolify-deploy skill instead.
---

# Skill: Coolify New Site

Stand up a brand-new site on the personal Coolify server. For redeploys, use `coolify-deploy`.

## Defaults

- Coolify CLI context: `sai` (https://c.sharjeel.ai). SSH alias for the server: `c`.
- Server UUID: `xsckwksgg8gk8sk0cgkcwcgc` (sole server). Confirm with `coolify --context=sai server list` if unsure.
- Coolify dir on host: `/data/coolify` (root-owned).

## Inputs to gather upfront

- **Project name** and **app name**.
- **Domain(s)**, comma-separated, each prefixed with `https://`.
- **Source type** — `dockerimage` for prebuilt images, `public`/`github` for git-based.
- **Image + tag** (if dockerimage), e.g., `nginx:alpine`.
- **Container port** to expose.
- **Storage needs** — bind mounts? config file mounts?

## Workflow

### 1. Create project

```
coolify --context=sai project create --name "<project-name>" --description "..."
```

Capture the project UUID from the output (it's the only durable identifier).

### 2. Create app

For dockerimage:
```
coolify --context=sai app create dockerimage \
  --server-uuid xsckwksgg8gk8sk0cgkcwcgc \
  --project-uuid <project-uuid> \
  --environment-name production \
  --docker-registry-image-name <image> \
  --docker-registry-image-tag <tag> \
  --ports-exposes <port> \
  --domains "https://a.example.com,https://b.example.com" \
  --name "<app-name>" \
  --description "..."
```

Do NOT pass `--instant-deploy` if you need storages first — the container will start without mounts and you'll have to redeploy.

### 3. Add storages

CLI `app storage create` works only on Coolify >= 4.0.0-beta.470. Check with `coolify --context=sai server list`-adjacent endpoint or the `/api/v1/health` payload. If the server is older:

**Bind mount (host dir → container path):** UI works fine — short, single-line paths. Storages → New → Volume Mount.

**File mount with multi-line content:** the UI textarea has corrupted multi-line pastes (introduced duplicate blocks). Two-step approach:
1. Use the UI to register the file mount slot (path + empty/placeholder content).
2. Overwrite the actual content from a local file by writing into Coolify's app dir via a throwaway root container (the dir is root-owned):
   ```
   cat <local-file> | ssh c 'sg docker -c "docker run --rm -i \
     -v /data/coolify/applications/<app-uuid>/<host-mirror-path>:/f \
     alpine sh -c \"cat > /f\""'
   ```
   The host-mirror path is shown in `docker inspect <container> --format {{.Mounts}}` once the container exists.

### 4. First deploy

```
coolify --context=sai app start <app-uuid>
```

Watch status (loop a few times):
```
coolify --context=sai app get <app-uuid> --format json | jq -r '.status'
```

If status is `restarting:unknown`, fetch container logs to find the crash reason:
```
ssh c 'sg docker -c "docker ps -a --filter name=<app-uuid> -q | head -1 | xargs -I{} docker logs {} --tail 40"'
```

### 5. Verify

```
# Routing (use --resolve to bypass DNS during cutover)
curl -sk --resolve <domain>:443:147.182.196.136 https://<domain>/

# Cert issuer — should be "Let's Encrypt", NOT "TRAEFIK DEFAULT CERT"
echo | openssl s_client -servername <domain> -connect 147.182.196.136:443 2>&1 | grep issuer=
```

## Gotchas

- **`fqdn` in `~/.config/coolify/config.json` must include the `https://` scheme.** Otherwise the CLI errors with `unsupported protocol scheme`.
- **Existing ssh sessions to `c`** may not have the `docker` group cached. Wrap docker commands in `sg docker -c "..."` until the session is re-logged.
- **DNS / ACME backoff during cutover.** If the user just changed DNS, Let's Encrypt validators may still see the old IP for up to TTL seconds. Don't restart Traefik repeatedly — LE rate-limits 5 failed validations per hostname per hour. Wait for propagation, then a single app restart triggers a fresh attempt.
- **Coolify UI file-mount textarea** has mangled multi-line config pastes (duplicates, weird indentation). Use the host-write trick above for non-trivial config content.
- **Conflicting manual containers**: if a hand-crafted `docker-compose` was previously running with the same Traefik labels (same Host rules), tear it down before deploying the Coolify-managed version — they'll fight over hostnames.
- **`--domains` requires `https://` prefix** on each entry, comma-separated.

## Safety

- Don't pass `--force` or `--instant-deploy` unless explicitly asked.
- Confirm project name and domain list with the user before creating.
- Report final UUIDs (project, app), routed domains, and TLS verification status.
