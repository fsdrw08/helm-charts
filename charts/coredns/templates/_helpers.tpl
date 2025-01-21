{{/*
Return the proper coredns image name
*/}}
{{- define "coredns.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.coredns.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "coredns.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "coredns.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.coredns.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "coredns.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "coredns.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "coredns.validateValues.foo" .) -}}
{{- $messages := append $messages (include "coredns.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

