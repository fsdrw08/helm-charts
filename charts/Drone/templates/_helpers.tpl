
{{/*
Return the proper droneServer image name
*/}}
{{- define "drone.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.droneServer.image "global" .Values.global) }}
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
{{- include "common.images.pullSecrets" (dict "images" (list .Values.droneServer.image  .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}


{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "drone.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
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

