{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper alloy image name
*/}}
{{- define "alloy.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.alloy.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "alloy.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "alloy.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.alloy.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "alloy.serviceAccountName" -}}
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
{{- define "alloy.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "alloy.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "alloy.validateValues.foo" .) -}}
{{- $messages := append $messages (include "alloy.validateValues.bar" .) -}}
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
      {{- if not (kindIs "invalid" $value) }}
      {{- if kindIs "string" $value }}
- --{{ $fullPath }}={{ $value | quote}}
      {{- else }}
- --{{ $fullPath }}={{ $value }}
      {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{- define "alloy.yamlToAlloy" -}}
{{- $config := . -}}
{{- range $config }}
{{ .component }} {{ if .label }}"{{ .label }}" {{ end -}} {{ print "{" }}
  {{- $indent := 2 }}
  {{- include "alloy.yamlToAlloyAttribute" (dict "attributes" .attributes "indent" $indent) }}
{{ print "}" }}
{{ end }}
{{- end }}

{{- define "alloy.yamlToAlloyAttribute" -}}
{{- $attributes := .attributes -}}
{{- $indent := .indent -}}
{{- range $key, $value := $attributes -}}
{{- if kindIs "map" $value }}
{{ $key | indent $indent }} {{ print "{" }}
{{- include "alloy.yamlToAlloyAttribute" (dict "attributes" $value "indent" (add $indent 2 | int)) }}
{{ print "}" | indent $indent }}
{{- else if kindIs "slice" $value }}
{{ $key | indent $indent }} = [
  {{- range $subKey, $subValue := $value }}
  {{- if kindIs "map" . }}
  {{ print "{" | indent $indent }}
  {{- include "alloy.yamlToAlloyAttribute" (dict "attributes" $subValue "indent" (add $indent 4 | int)) }}
  {{ print "}," | indent $indent }}
  {{- else }}
  {{ join "," $value | indent (add $indent | int) }}
  {{- end }}
  {{- end }}
{{ print "]" | indent ($indent | int) }}
{{- else if kindIs "string" $value }}
{{ $key | indent $indent }} = {{ $value }}
{{- else }}
{{ $key | indent $indent }} = {{ $value }}
{{- end }}
{{- end }}
{{- end }}
