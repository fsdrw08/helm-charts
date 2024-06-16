{{/*
Return the proper freeipa image name
*/}}
{{- define "freeipa.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.freeipa.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "freeipa.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "freeipa.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.freeipa.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "freeipa.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "freeipa.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "freeipa.validateValues.foo" .) -}}
{{- $messages := append $messages (include "freeipa.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

