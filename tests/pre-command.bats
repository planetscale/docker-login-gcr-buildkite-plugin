#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# required to stub the 'docker-credential-gcr' command in the hook script:
export TEST=1

# uncomment to enable debug output from the hook:
# export BUILDKITE_PLUGIN_DOCKER_LOGIN_GCR_DEBUG=1

# uncomment for useful debug output from the stubs:
# export DOCKER_STUB_DEBUG=/dev/tty
# export DOCKER_CREDENTIAL_GCR_STUB_DEBUG=/dev/tty
# export JQ_STUB_DEBUG=/dev/tty

@test "registries arg not set" {
  run $PWD/hooks/pre-command

  assert_failure
  assert_output --partial "No registries specified"
}

@test "login to single registry" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_GCR_REGISTRIES_0="us-docker.pkg.dev"

  stub docker-credential-gcr \
    "get : echo 'docker-credential-gcr stubbed'"

  stub jq \
    "-r .Secret : echo 'jq stubbed'"

  stub docker \
    "login --username oauth2accesstoken --password-stdin https://us-docker.pkg.dev : echo logging in to us-docker.pkg.dev"

  run $PWD/hooks/pre-command
  assert_success
  assert_output --partial "Logging in to Docker registry us-docker.pkg.dev"

  unstub docker-credential-gcr
  unstub jq
  unstub docker
  unset BUILDKITE_PLUGIN_DOCKER_LOGIN_GCR_REGISTRIES_0
}

@test "login to multiple registries" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_GCR_REGISTRIES_0="us-docker.pkg.dev"
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_GCR_REGISTRIES_1="eu-docker.pkg.dev"

  stub docker-credential-gcr \
    "get : echo 'docker-credential-gcr stubbed'" \
    "get : echo 'docker-credential-gcr stubbed'"

  stub jq \
    "-r .Secret : echo 'jq stubbed'" \
    "-r .Secret : echo 'jq stubbed'"

  stub docker \
    "login --username oauth2accesstoken --password-stdin https://us-docker.pkg.dev : echo logging in to us-docker.pkg.dev" \
    "login --username oauth2accesstoken --password-stdin https://eu-docker.pkg.dev : echo logging in to eu-docker.pkg.dev"

  run $PWD/hooks/pre-command
  assert_success
  assert_output --partial "Logging in to Docker registry us-docker.pkg.dev"
  assert_output --partial "Logging in to Docker registry eu-docker.pkg.dev"

  unstub docker-credential-gcr
  unstub jq
  unstub docker
  unset BUILDKITE_PLUGIN_DOCKER_LOGIN_GCR_REGISTRIES_0
  unset BUILDKITE_PLUGIN_DOCKER_LOGIN_GCR_REGISTRIES_1
}