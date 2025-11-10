{{- define "exporter.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.exporter.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: prometheus-podman-exporter
    {{- if .Values.exporter.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.exporter.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "exporter.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.exporter.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  hostNetwork: {{ .Values.exporter.hostNetwork }}
  {{- if .Values.exporter.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.exporter.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.exporter.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "exporter.volumePermissions.image" . }}
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
    {{- if .Values.exporter.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.exporter.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: workload
      image: {{ template "exporter.image" . }}
      imagePullPolicy: {{ .Values.exporter.image.pullPolicy | quote }}
      {{- if .Values.exporter.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.exporter.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.exporter.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.exporter.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.exporter.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.exporter.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.exporter.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.exporter.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.exporter.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.exporter.resources }}
      resources: {{- toYaml .Values.exporter.resources | nindent 8 }}
      {{- else if ne .Values.exporter.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.exporter.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.exporter.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.exporter.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.exporter.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.exporter.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.exporter.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.exporter.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.exporter.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.exporter.flags.web.config.file }}
        - name: config-web
          mountPath: {{ .Values.exporter.flags.web.config.file }}
          subPath: {{ base .Values.exporter.flags.web.config.file }}
        {{- end }}
        {{- if .Values.exporter.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.exporter.secret.tls.mountPath }}
        {{- end }}
      {{- if .Values.exporter.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.exporter.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.exporter.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.exporter.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- if .Values.exporter.configFile.web }}
    - name: config-web
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- end }}
    {{- if .Values.exporter.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{- if .Values.exporter.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.exporter.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.exporter.podRestartPolicy }}
  {{- end }}
{{- end -}}