{{- define "drone.podTemplate" -}}
metadata:
  {{- if eq .Values.instanceKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.droneServer.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: server
    {{- if .Values.droneServer.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "drone.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.droneServer.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.droneServer.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.droneServer.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "drone.volumePermissions.image" . }}
      imagePullPolicy: {{ .Values.volumePermissions.image.pullPolicy | quote }}
      command:
        - %%commands%%
      securityContext: {{- include "common.tplvalues.render" (dict "value" .Values.volumePermissions.containerSecurityContext "context" $) | nindent 8 }}
      {{- if .Values.volumePermissions.resources }}
      resources: {{- toYaml .Values.volumePermissions.resources | nindent 8 }}
      {{- else if ne .Values.volumePermissions.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.volumePermissions.resourcesPreset) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: foo
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
    {{- end }}
    {{- if .Values.droneServer.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "server.image" . }}
      imagePullPolicy: {{ .Values.droneServer.image.pullPolicy }}
      {{- if .Values.droneServer.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.droneServer.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.droneServer.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.droneServer.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.droneServer.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.droneServer.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.droneServer.extraEnvVarsCM "context" $) }}
        {{- end }}
        # extraEnvVarsInSecret
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.droneServer.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.droneServer.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.droneServer.resources }}
      resources: {{- toYaml .Values.droneServer.resources | nindent 8 }}
      {{- else if ne .Values.droneServer.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.droneServer.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.droneServer.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.droneServer.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.droneServer.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.droneServer.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.droneServer.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.droneServer.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.droneServer.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.droneServer.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.droneServer.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.droneServer.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.persistence.mountPath }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        {{- end -}}
      {{- if .Values.droneServer.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.droneServer.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.droneServer.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.droneServer.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.droneServer.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.instanceKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.droneServer.podRestartPolicy }}
  {{- end }}
{{- end -}}