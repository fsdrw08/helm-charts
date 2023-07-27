{{/*
Return the proper droneServer image name
*/}}
{{- define "server.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.droneRunnerDocker.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper droneRunnerDocker image name
*/}}
{{- define "runner.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.droneRunnerDocker.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "drone.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "drone.imagePullSecrets" -}}
{{- include "common.images.renderPullSecrets" (dict "images" (list .Values.droneRunnerDocker.image .Values.droneRunnerDocker.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "drone.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "drone.validateValues.foo" .) -}}
{{- $messages := append $messages (include "drone.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}

