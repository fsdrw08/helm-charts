{{- define "alertmanager.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.alertmanager.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: alertmanager
    {{- if .Values.alertmanager.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "alertmanager.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.alertmanager.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.alertmanager.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.alertmanager.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "alertmanager.volumePermissions.image" . }}
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
    {{- if .Values.alertmanager.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: {{ if .Values.alertmanager.flags.agent }}agent{{ else }}server{{ end }}
      image: {{ template "alertmanager.image" . }}
      imagePullPolicy: {{ .Values.alertmanager.image.pullPolicy | quote }}
      {{- if .Values.alertmanager.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.alertmanager.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.alertmanager.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alertmanager.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.args "context" $) | nindent 8 }}
      {{- else }}
      args: 
      {{- include "processFlags" (dict "values" .Values.alertmanager.flags) | trim | nindent 8 -}}
      {{- end }}
      env:
        {{- if .Values.alertmanager.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.alertmanager.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.alertmanager.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.alertmanager.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.alertmanager.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.alertmanager.resources }}
      resources: {{- toYaml .Values.alertmanager.resources | nindent 8 }}
      {{- else if ne .Values.alertmanager.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.alertmanager.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.alertmanager.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.alertmanager.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.alertmanager.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alertmanager.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alertmanager.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.alertmanager.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alertmanager.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alertmanager.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.alertmanager.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alertmanager.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: {{ .Values.alertmanager.flags.config.file }}
          subPath: {{ base .Values.alertmanager.flags.config.file }}
        {{- if .Values.alertmanager.flags.web.config.file }}
        - name: web
          mountPath: {{ .Values.alertmanager.flags.web.config.file }}
          subPath: {{ base .Values.alertmanager.flags.web.config.file }}
        {{- end }}
        {{- if .Values.alertmanager.tls.contents }}
        - name: tls
          mountPath: {{ .Values.alertmanager.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $) }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.alertmanager.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.alertmanager.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.alertmanager.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.alertmanager.flags.web.config.file }}
    - name: web
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- end }}
    {{- if .Values.alertmanager.tls.contents }}
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
    {{- if .Values.alertmanager.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alertmanager.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.alertmanager.podRestartPolicy }}
  {{- end }}
{{- end -}}