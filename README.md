# Docker Login GCR (and GAR) Buildkite Plugin

Login to Google Container Registry (GCR) and Google Artifact Registry (GAR) using the `docker-credential-gcr` utility.

This plugin is meant to be combined with the [gcp-workload-identity-federation](https://github.com/buildkite-plugins/gcp-workload-identity-federation-buildkite-plugin) plugin to provide short-lived credentials for accessing GCR and GAR registries.

The advantage of using this plugin is that it uses `docker-credential-gcr` with Application Default Credentials to obtain an oauth2 access token and store it in the `$DOCKER_CONFIG/config.json` file. The file contains all of the credentials necessary to access GCR and GAR registries. No additional files are needed such as the `credentials.json` or `token.json` created by the `gcp-workload-identity-federation` plugin. Nor is the `docker-credential-gcr` needed after the token is acquired. This greatly simplifies certain workflows by reducing the number of files that need to be mounted into a docker or docker-compose context.

If the [docker-credential-gcr](https://github.com/GoogleCloudPlatform/docker-credential-gcr) utility is already installed on the build worker and available in `$PATH` it will be used, otherwise a version will be downloaded into a temp dir. The temp dir and the binary will be removed up after the plugin runs.

## Example

Add the following to your `pipeline.yml`:

```yaml
steps:
  - command: ./run_build.sh
    plugins:
      - planetscale/docker-login-gcr#v0.0.1:
          registries: ["us-docker.pkg.dev", "gcr.io"] # required. One or more GAR or GCR endpoints to auth
```

Usage with the [gcp-workload-identity-federation](https://github.com/buildkite-plugins/gcp-workload-identity-federation-buildkite-plugin) plugin:

```yaml
steps:
  - command: ./run_build.sh
    plugins:
      - gcp-workload-identity-federation#v1.1.0:
          audience: "//iam.googleapis.com/projects/1234567890123/locations/global/workloadIdentityPools/buildkite/providers/buildkite"
          service_account: "my-gsa@my-project.iam.gserviceaccount.com"
      - planetscale/docker-login-gcr#v0.0.1:
          registries: ["us-docker.pkg.dev", "gcr.io"] # required. One or more GAR or GCR endpoints to auth
```

## Developing

To run the linters:

```shell
make lint
```

To run the tests:

```shell
make test
```

## Releases

The release process is currently manual. Bump the tag and push to GitHub.


## Contributing

1. Fork the repo
2. Make changes
3. Run the tests
4. Commit and push your changes
5. Send a pull request
