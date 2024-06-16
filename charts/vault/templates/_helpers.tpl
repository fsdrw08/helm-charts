{{/*
Return the proper vault image name
*/}}
{{- define "vault.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.vault.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "vault.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "vault.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.%%MAIN_OBJECT_BLOCK%%.image .Values.%%SECONDARY_OBJECT_BLOCK%%.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "vault.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "vault.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "vault.validateValues.foo" .) -}}
{{- $messages := append $messages (include "vault.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}