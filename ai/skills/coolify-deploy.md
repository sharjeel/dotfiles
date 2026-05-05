# Skill: Coolify Deploy

Use this playbook when deploying or redeploying to the personal Coolify server.

## Defaults

- Default Coolify context: `sai`
- Do not switch to another context unless the user explicitly asks for it.
- Prefer the existing CLI context over ad hoc `--host` or `--token` flags.

## Workflow

1. Confirm the target resource name if the user provided one.
2. If the target is unclear, inspect available resources first:
   - `coolify --context=sai app list`
   - `coolify --context=sai resources list`
3. Prefer deployment by name when the resource name is stable:
   - `coolify --context=sai deploy name <resource-name>`
4. If names are ambiguous, resolve the UUID first and deploy by UUID:
   - `coolify --context=sai app list --format=json`
   - `coolify --context=sai deploy uuid <resource-uuid>`
5. Check deployment state and capture the relevant identifier:
   - `coolify --context=sai deploy list`
   - `coolify --context=sai deploy get <deployment-uuid>`
6. Pull logs when the deployment fails or the user asks for verification:
   - `coolify --context=sai app deployments logs <app-uuid> -n 200`
   - add `-f` only when actively tailing a live deploy

## Safety Rules

- Use `--force` only when the user asked for it or when rerunning a known stuck deployment is clearly warranted.
- Prefer JSON output for scripted lookups and human-readable output for interactive diagnosis.
- Report what was deployed, which context was used, and any follow-up verification or failures.
