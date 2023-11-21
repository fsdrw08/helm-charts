{{/*
Return the proper socat image name
*/}}
{{- define "socat.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.socat.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "socat.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "socat.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.socat.image .Values.%%SECONDARY_OBJECT_BLOCK%%.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "socat.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "socat.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "socat.validateValues.foo" .) -}}
{{- $messages := append $messages (include "socat.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

