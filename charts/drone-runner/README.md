<!--- app-name: Drone Runner -->

# Drone Runner

Drone runner helm chart for podman, deploy drone runner in podman with podman kube play. 
Drone is a self-service Continuous Integration platform for busy development teams. (check existing examples)

## TL;DR

```powershell
$releaseName = "drone-runner"
helm template .\charts\drone-runner\ --name-template=$releaseName | podman kube play -
```

## Introduction

%%INTRODUCTION%% (check existing examples)

## Prerequisites

- Helm 3.2.0+
- Podman 4.4+ (need volumeMount.subPath support)

## Installing the Chart

To install the chart with the release name `drone-runner`:

```console
helm template .\charts\drone-runner\ --name-template=drone-runner | podman kube play -
```

The command deploys Drone Runner on podman host in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `podman pod ls`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm template .\charts\drone-runner\ --name-template=drone-runner | podman kube play --down -
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

See <https://github.com/bitnami-labs/readme-generator-for-helm> to create the table

The above parameters map to the env variables defined in [bitnami/Drone Runner](https://github.com/bitnami/containers/tree/main/bitnami/Drone Runner). For more information please refer to the [bitnami/Drone Runner](https://github.com/bitnami/containers/tree/main/bitnami/Drone Runner) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm template`. For example,

> NOTE: Once this chart is deployed, it is not possible to change the application's access credentials, such as usernames or passwords, using Helm. To change these application credentials after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or use the application's built-in administrative tools if available.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm install my-release -f values.yaml oci://registry-1.docker.io/bitnamicharts/Drone Runner
```

> **Tip**: You can use the default [values.yaml](values.yaml)

### Additional environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property.

```yaml
droneRunnerDocker:
  extraEnvVars:
    - name: LOG_LEVEL
      value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or the `extraEnvVarsSecret` values.

### Sidecars

If additional containers are needed in the same pod as Drone Runner (such as additional metrics or logging exporters), they can be defined using the `sidecars` parameter. If these sidecars export extra ports, extra port definitions can be added using the `service.extraPorts` parameter. [Learn more about configuring and using sidecar containers](https://docs.bitnami.com/kubernetes/apps/Drone Runner/administration/configure-use-sidecars/).

## Troubleshooting

Find more information about how to deal with common errors related to Bitnami's Helm charts in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).
