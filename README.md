# Tandoor Ansible role

This is an [Ansible](https://www.ansible.com/) role which installs [Tandoor](https://docs.tandoor.dev/) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

[Docher Hub Container tags](https://hub.docker.com/r/vabene1111/recipes/tags)

This role *implicitly* depends on:

- [`com.devture.ansible.role.playbook_help`](https://github.com/devture/com.devture.ansible.role.playbook_help)
- [`com.devture.ansible.role.systemd_docker_base`](https://github.com/devture/com.devture.ansible.role.systemd_docker_base)

For an Ansible playbook which integrates this role and makes it easier to use, see the [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook).

## OpenID Connect (OIDC) configuration

### Minimal configuration (Authentik example)

```yaml
# Required: enable OIDC
tandoor_oidc_enabled: true

# Add one app (button) named "Authentik"
tandoor_oidc_apps:
  - provider_id: "authentik"   # must match callback path segment below
    name: "Authentik"          # controls the login button label
    client_id: "{{ vault_tandoor_oidc_client_id }}"
    secret: "{{ vault_tandoor_oidc_client_secret }}"
    settings:
      # Authentik per-app discovery URL
      server_url: "https://AUTHENTIK_FQDN/application/o/AUTHENTIK_TANDOOR_SLUG/.well-known/openid-configuration"
      # Per-app PKCE for newer allauth (older covered provider-wide)
      oauth_pkce_enabled: true

# Optional (recommended behind reverse proxies)
tandoor_oidc_proxy_header: "X-Forwarded-Proto"
# Optional defaults for new SSO users
tandoor_social_default_access: null
tandoor_social_default_group: null
```

> **Secrets:** put `vault_tandoor_oidc_client_id` and `vault_tandoor_oidc_client_secret` in Ansible Vault.

### Authentik setup

* **Provider:** OAuth2/OpenID Connect
* **Client type:** Confidential
* **Grant/Response:** Authorization Code (PKCE supported automatically)
* **Scopes:** `openid email profile` (add `offline_access` if you want refresh tokens)
* **Signing key:** default (RS256)
* **Encryption key:** leave empty (JWS only)
* **Issuer mode:** per application (matches the per-app discovery URL)
* **Subject mode:** hashed ID (default)
* **Redirect URI (Strict):**

  * If `tandoor_path_prefix == "/"` (default):

    ```
    https://<TANDOOR_FQDN>/accounts/oidc/authentik/login/callback/
    ```
  * If served under a sub-path, **prepend the prefix** (no trailing slash):

    ```
    https://<TANDOOR_FQDN><tandoor_path_prefix>/accounts/oidc/authentik/login/callback/
    ```

### Notes

* The login button label comes from the app `name` ("Authentik" above).
* The "Social authentication" panel title in account settings is a Tandoor UI string; it’s not provider-specific.
