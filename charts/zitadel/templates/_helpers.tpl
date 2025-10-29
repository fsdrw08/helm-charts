{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper zitadel image name
*/}}
{{- define "zitadel.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.zitadel.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "zitadel.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "zitadel.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.zitadel.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "zitadel.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "zitadel.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "zitadel.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "zitadel.validateValues.foo" .) -}}
{{- $messages := append $messages (include "zitadel.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{- define "checkSecretEnvVarsEnabled" -}}
{{- $secretEnvVarsEnabled := "" -}}
{{- range $key, $val := .Values.zitadel.container }}
  {{- if and $val.enabled $val.secret.envVars -}}
    {{- $secretEnvVarsEnabled = "1" -}}
  {{- end -}}
{{- end -}}
{{- $secretEnvVarsEnabled -}}
{{- end -}}

{{- define "checkSecretTlsEnabled" -}}
{{- $secretTlsEnabled := "" -}}
{{- range $key, $val := .Values.zitadel.container }}
  {{- if and $val.enabled $val.secret.tls.contents -}}
    {{- $secretTlsEnabled = "1" -}}
  {{- end -}}
{{- end -}}
{{- $secretTlsEnabled -}}
{{- end -}}

{{- define "checkSecretOthersEnabled" -}}
{{- $secretOthersEnabled := "" -}}
{{- range $key, $val := .Values.zitadel.container }}
  {{- if and $val.enabled $val.secret.others.contents -}}
    {{- $secretOthersEnabled = "1" -}}
  {{- end -}}
{{- end -}}
{{- $secretOthersEnabled -}}
{{- end -}}