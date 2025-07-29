{{- define "prometheusPodmanExporter.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.prometheusPodmanExporter.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: prometheus-podman-exporter
    {{- if .Values.prometheusPodmanExporter.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "prometheusPodmanExporter.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.prometheusPodmanExporter.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.prometheusPodmanExporter.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.prometheusPodmanExporter.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "prometheusPodmanExporter.volumePermissions.image" . }}
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
    {{- if .Values.prometheusPodmanExporter.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: exporter
      image: {{ template "prometheusPodmanExporter.image" . }}
      imagePullPolicy: {{ .Values.prometheusPodmanExporter.image.pullPolicy | quote }}
      {{- if .Values.prometheusPodmanExporter.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.prometheusPodmanExporter.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheusPodmanExporter.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheusPodmanExporter.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.args "context" $) | nindent 8 }}
      {{- else }}
      args:
      {{- include "processFlags" (dict "values" .Values.prometheusPodmanExporter.flags) | trim | nindent 8 -}}
      {{- end }}
      env:
        {{- if .Values.prometheusPodmanExporter.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.prometheusPodmanExporter.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.prometheusPodmanExporter.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.prometheusPodmanExporter.resources }}
      resources: {{- toYaml .Values.prometheusPodmanExporter.resources | nindent 8 }}
      {{- else if ne .Values.prometheusPodmanExporter.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.prometheusPodmanExporter.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheusPodmanExporter.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.prometheusPodmanExporter.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheusPodmanExporter.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheusPodmanExporter.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheusPodmanExporter.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheusPodmanExporter.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheusPodmanExporter.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheusPodmanExporter.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheusPodmanExporter.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheusPodmanExporter.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.prometheusPodmanExporter.flags.web.config.file }}
        - name: web
          mountPath: {{ .Values.prometheusPodmanExporter.flags.web.config.file }}
          subPath: {{ base .Values.prometheusPodmanExporter.flags.web.config.file }}
        {{- end }}
        {{- if .Values.prometheusPodmanExporter.tls.contents }}
        - name: tls
          mountPath: {{ .Values.prometheusPodmanExporter.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.prometheusPodmanExporter.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.prometheusPodmanExporter.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.prometheusPodmanExporter.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.prometheusPodmanExporter.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheusPodmanExporter.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.prometheusPodmanExporter.podRestartPolicy }}
  {{- end }}
{{- end -}}