{{- define "redis.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.redis.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.redis.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: redis
    {{- if .Values.redis.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redis.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "redis.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.redis.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.redis.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redis.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.redis.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "redis.volumePermissions.image" . }}
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
    {{- if .Values.redis.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redis.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "redis.image" . }}
      imagePullPolicy: {{ .Values.redis.image.pullPolicy | quote }}
      {{- if .Values.redis.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.redis.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.redis.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.redis.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.redis.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.redis.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.redis.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redis.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.redis.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redis.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.redis.resources }}
      resources: {{- toYaml .Values.redis.resources | nindent 8 }}
      {{- else if ne .Values.redis.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.redis.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.redis.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.redis.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redis.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redis.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redis.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redis.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redis.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redis.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redis.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.redis.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redis.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/redis
        {{- if .Values.redis.tls.contents }}
        - name: tls
          mountPath: {{ .Values.redis.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.redis.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.redis.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.redis.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.redis.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.redis.tls.contents }}
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
    {{- if .Values.redis.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redis.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.redis.podRestartPolicy }}
  {{- end }}
{{- end -}}