# Tandoor Ansible role

This is an [Ansible](https://www.ansible.com/) role which installs [Tandoor](https://docs.tandoor.dev/) to run as a [Docker](https://www.docker.com/) container wrapped in a systemd service.

[Docher Hub Container tags](https://hub.docker.com/r/vabene1111/recipes/tags)

This role *implicitly* depends on:

- [`com.devture.ansible.role.playbook_help`](https://github.com/devture/com.devture.ansible.role.playbook_help)
- [`com.devture.ansible.role.systemd_docker_base`](https://github.com/devture/com.devture.ansible.role.systemd_docker_base)

For an Ansible playbook which integrates this role and makes it easier to use, see the [mash-playbook](https://github.com/mother-of-all-self-hosting/mash-playbook).

## OpenID Connect configuration

The role exposes the `SOCIAL_PROVIDERS` and `SOCIALACCOUNT_PROVIDERS` environment variables used by Django allauth. Set the corresponding variables in your inventory to enable [OIDC login with Tandoor](https://docs.tandoor.dev/features/authentication/):

```yaml
tandoor_social_providers: allauth.socialaccount.providers.openid_connect
tandoor_socialaccount_providers:
  openid_connect:
    APPS:
      - provider_id: authentik
        name: Authentik
        client_id: "{{ vault_tandoor_oidc_client_id }}"
        secret: "{{ vault_tandoor_oidc_client_secret }}"
        settings:
          server_url: "https://authentik.example.com/application/o/tandoor/.well-known/openid-configuration"
          oauth_pkce_enabled: true
```

The `server_url` should point to the Authentik application’s OpenID Connect discovery endpoint; replace `authentik.example.com` and the `tandoor` slug to match the application you created in Authentik as described in their [integration guide](https://integrations.goauthentik.io/documentation/tandoor/).

The role automatically serialises `tandoor_socialaccount_providers` to JSON when rendering the `.env` file, so you can manage the provider configuration with ordinary Ansible dictionaries and keep secrets in Ansible Vault or group variables.

## Development

Install the lint dependency before running the Just recipes:

```bash
pip install -r requirements.txt
```

Once `ansible-lint` is available locally you can run `just lint` to validate the role.
