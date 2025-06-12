{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper prometheus image name
{{- define "prometheus.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.prometheus.image "global" .Values.global) }}
{{- end -}}
*/}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "prometheus.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "prometheus.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.prometheus.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheus.serviceAccountName" -}}
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
{{- define "prometheus.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "prometheus.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "prometheus.validateValues.foo" .) -}}
{{- $messages := append $messages (include "prometheus.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

{{- define "processFlags" -}}
  {{- $prefix := "" -}}
  {{- if .prefix -}}
    {{- $prefix = printf "%s." .prefix -}}
  {{- end -}}

  {{- range $key, $value := .values -}}
    {{- $fullPath := printf "%s%s" $prefix $key -}}
    {{- if kindIs "map" $value -}}
      {{- include "processFlags" (dict "values" $value "prefix" $fullPath) | trim | nindent 0 -}}
    {{- else -}}
    {{- /* https://github.com/prometheus/prometheus/pull/7410#issuecomment-718696715 */}}
      {{- if (kindIs "bool" $value) }}
      {{- if $value }}
- --{{ $fullPath }}
      {{- end -}}
      {{- else if not (kindIs "invalid" $value) }}
- --{{ $fullPath }}={{ $value }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "checkTlsEnabled" -}}
{{- $tlsEnabled := "" -}}
{{- range $key, $val := .Values.prometheus.containers }}
  {{- if and $val.enabled $val.tls.contents -}}
    {{- $tlsEnabled = "1" -}}
  {{- end -}}
{{- end -}}
{{- $tlsEnabled -}}
{{- end -}}