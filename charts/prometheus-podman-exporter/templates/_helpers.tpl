{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper prometheusPodmanExporter image name
*/}}
{{- define "prometheusPodmanExporter.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.prometheusPodmanExporter.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "prometheusPodmanExporter.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "prometheusPodmanExporter.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.prometheusPodmanExporter.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "prometheusPodmanExporter.serviceAccountName" -}}
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
{{- define "prometheusPodmanExporter.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "prometheusPodmanExporter.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "prometheusPodmanExporter.validateValues.foo" .) -}}
{{- $messages := append $messages (include "prometheusPodmanExporter.validateValues.bar" .) -}}
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