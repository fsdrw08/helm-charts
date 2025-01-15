{{- define "keycloak.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.keycloak.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: keycloak
    {{- if .Values.keycloak.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "keycloak.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.keycloak.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.keycloak.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.keycloak.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "keycloak.volumePermissions.image" . }}
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
    {{- if .Values.keycloak.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: keycloak
      image: {{ template "keycloak.image" . }}
      imagePullPolicy: {{ .Values.keycloak.image.pullPolicy | quote }}
      {{- if .Values.keycloak.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.keycloak.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.keycloak.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.keycloak.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.keycloak.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.keycloak.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.keycloak.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.keycloak.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.keycloak.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.keycloak.resources }}
      resources: {{- toYaml .Values.keycloak.resources | nindent 8 }}
      {{- else if ne .Values.keycloak.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.keycloak.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.keycloak.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.keycloak.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.keycloak.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.keycloak.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.keycloak.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.keycloak.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.keycloak.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.keycloak.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.keycloak.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.keycloak.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.keycloak.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.keycloak.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.keycloak.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.keycloak.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.keycloak.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.keycloak.podRestartPolicy }}
  {{- end }}
{{- end -}}