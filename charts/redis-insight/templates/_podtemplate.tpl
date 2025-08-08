{{- define "redisInsight.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.redisInsight.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: RedisInsight
    {{- if .Values.redisInsight.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "redisInsight.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.redisInsight.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redisInsight.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.redisInsight.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "redisInsight.volumePermissions.image" . }}
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
    {{- if .Values.redisInsight.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: console
      image: {{ template "redisInsight.image" . }}
      imagePullPolicy: {{ .Values.redisInsight.image.pullPolicy | quote }}
      {{- if .Values.redisInsight.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.redisInsight.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.redisInsight.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        - configMapRef:
            name: {{ template "common.names.fullname" . }}-cm-envvar
        {{- if .Values.redisInsight.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.redisInsight.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.redisInsight.resources }}
      resources: {{- toYaml .Values.redisInsight.resources | nindent 8 }}
      {{- else if ne .Values.redisInsight.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.redisInsight.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.redisInsight.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redisInsight.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redisInsight.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redisInsight.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redisInsight.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.redisInsight.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redisInsight.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.redisInsight.tls.contents }}
        - name: tls
          mountPath: {{ .Values.redisInsight.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.redisInsight.config.RI_APP_FOLDER_ABSOLUTE_PATH }}
      {{- if .Values.redisInsight.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.redisInsight.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.redisInsight.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- if .Values.redisInsight.tls.contents }}
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
    {{- if .Values.redisInsight.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.redisInsight.podRestartPolicy }}
  {{- end }}
{{- end -}}