{{- define "prometheus.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.prometheus.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: prometheus
    {{- if .Values.prometheus.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "prometheus.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.prometheus.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.prometheus.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.prometheus.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "prometheus.volumePermissions.image" . }}
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
    {{- if .Values.prometheus.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: {{ if .Values.prometheus.flags.agent }}agent{{ else }}server{{ end }}
      image: {{ template "prometheus.image" . }}
      imagePullPolicy: {{ .Values.prometheus.image.pullPolicy | quote }}
      {{- if .Values.prometheus.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.prometheus.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.args "context" $) | nindent 8 }}
      {{- else }}
      args: 
      {{- include "processFlags" (dict "values" .Values.prometheus.flags) | trim | nindent 8 -}}
      {{- end }}
      env:
        {{- if .Values.prometheus.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.prometheus.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.prometheus.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.prometheus.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.prometheus.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.prometheus.resources }}
      resources: {{- toYaml .Values.prometheus.resources | nindent 8 }}
      {{- else if ne .Values.prometheus.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.prometheus.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.prometheus.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheus.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheus.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheus.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheus.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheus.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheus.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: {{ .Values.prometheus.flags.config.file }}
          subPath: {{ base .Values.prometheus.flags.config.file }}
        {{- if .Values.prometheus.flags.web.config.file }}
        - name: web
          mountPath: {{ .Values.prometheus.flags.web.config.file }}
          subPath: {{ base .Values.prometheus.flags.web.config.file }}
        {{- end }}
        {{- if .Values.prometheus.tls.contents }}
        - name: tls
          mountPath: {{ .Values.prometheus.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $) }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.prometheus.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.prometheus.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.prometheus.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.prometheus.flags.web.config.file }}
    - name: web
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- end }}
    {{- if .Values.prometheus.tls.contents }}
    - name: tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.prometheus.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.prometheus.podRestartPolicy }}
  {{- end }}
{{- end -}}