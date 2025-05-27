<!--- app-name: minio -->

# minio

%%DESCRIPTION%% (check existing examples)

## TL;DR

```console
helm template %%HELM_REGISTRY%% --name-template=minio | podman kube play -
```

## Introduction

%%INTRODUCTION%% (check existing examples)

## Prerequisites

- Helm 3.2.0+
- Podman

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm template %%HELM_REGISTRY%% --name-template=minio | podman kube play -
```

The command deploys minio on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm template %%HELM_REGISTRY%% --name-template=minio | podman kube play --down -
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

See <https://github.com/bitnami-labs/readme-generator-for-helm> to create the table

The above parameters map to the env variables defined in [bitnami/minio](https://github.com/bitnami/containers/tree/main/bitnami/minio). For more information please refer to the [bitnami/minio](https://github.com/bitnami/containers/tree/main/bitnami/minio) image documentation.

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
helm install my-release \
  --set minioUsername=admin \
  --set minioPassword=password \
  --set mariadb.auth.rootPassword=secretpassword \
    oci://registry-1.docker.io/bitnamicharts/minio
```

The above command sets the minio administrator account username and password to `admin` and `password` respectively. Additionally, it sets the MariaDB `root` user password to `secretpassword`.

> NOTE: Once this chart is deployed, it is not possible to change the application's access credentials, such as usernames or passwords, using Helm. To change these application credentials after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or use the application's built-in administrative tools if available.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
helm template my-release -f values.yaml oci://registry-1.docker.io/bitnamicharts/minio
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Configuration and installation details

### [Rolling VS Immutable tags](https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/)

It is strongly recommended to use immutable tags in a production environment. This ensures your deployment does not change automatically if the same tag is updated with a different image.

Bitnami will release a new chart updating its containers if a new version of the main container, significant changes, or critical vulnerabilities exist.

### External database support

%%IF NEEDED%%

You may want to have minio connect to an external database rather than installing one inside your cluster. Typical reasons for this are to use a managed database service, or to share a common database server for all your applications. To achieve this, the chart allows you to specify credentials for an external database with the [`externalDatabase` parameter](#parameters). You should also disable the MariaDB installation with the `mariadb.enabled` option. Here is an example:

```console
mariadb.enabled=false
externalDatabase.host=myexternalhost
externalDatabase.user=myuser
externalDatabase.password=mypassword
externalDatabase.database=mydatabase
externalDatabase.port=3306
```

### Additional environment variables

In case you want to add extra environment variables (useful for advanced operations like custom init scripts), you can use the `extraEnvVars` property.

```yaml
minio:
  extraEnvVars:
    - name: LOG_LEVEL
      value: error
```

Alternatively, you can use a ConfigMap or a Secret with the environment variables. To do so, use the `extraEnvVarsCM` or the `extraEnvVarsSecret` values.

### Sidecars

If additional containers are needed in the same pod as minio (such as additional metrics or logging exporters), they can be defined using the `sidecars` parameter. If these sidecars export extra ports, extra port definitions can be added using the `service.extraPorts` parameter. [Learn more about configuring and using sidecar containers](https://docs.bitnami.com/kubernetes/apps/minio/administration/configure-use-sidecars/).

## Troubleshooting

Find more information about how to deal with common errors related to Bitnami's Helm charts in [this troubleshooting guide](https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues).
