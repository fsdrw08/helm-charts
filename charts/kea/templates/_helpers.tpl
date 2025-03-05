{{/*
Copyright Broadcom, Inc. All Rights Reserved.
SPDX-License-Identifier: APACHE-2.0
*/}}

{{/*
Return the proper kea image name
{{- define "kea.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.%%MAIN_OBJECT_BLOCK%%.image "global" .Values.global) }}
{{- end -}}
*/}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "kea.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
{{- define "kea.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.%%MAIN_OBJECT_BLOCK%%.image .Values.%%SECONDARY_OBJECT_BLOCK%%.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}
*/}}

{{/*
Create the name of the service account to use
*/}}
{{- define "kea.serviceAccountName" -}}
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
{{- define "kea.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "kea.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "kea.validateValues.foo" .) -}}
{{- $messages := append $messages (include "kea.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}