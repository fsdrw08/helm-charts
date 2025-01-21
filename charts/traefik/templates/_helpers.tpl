{{/*
Return the proper traefik image name
*/}}
{{- define "traefik.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.traefik.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "traefik.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "traefik.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.traefik.image .Values.%%SECONDARY_OBJECT_BLOCK%%.image .Values.volumePermissions.image) "context" $) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "traefik.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "traefik.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "traefik.validateValues.foo" .) -}}
{{- $messages := append $messages (include "traefik.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}