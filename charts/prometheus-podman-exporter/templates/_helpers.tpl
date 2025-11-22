{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper exporter image name
*/}}
{{- define "exporter.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.exporter.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "exporter.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.defaultInitContainers.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "exporter.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.exporter.image .Values.defaultInitContainers.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "exporter.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "exporter.validateValues.foo" .) -}}
{{- $messages := append $messages (include "exporter.validateValues.bar" .) -}}
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