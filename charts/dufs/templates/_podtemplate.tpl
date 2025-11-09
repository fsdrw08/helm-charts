{{- define "dufs.podTemplate" -}}
metadata:
  {{- if eq .Values.dufs.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.dufs.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: dufs
    {{- if .Values.dufs.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dufs.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "dufs.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.dufs.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dufs.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.dufs.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "dufs.volumePermissions.image" . }}
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
    {{- if .Values.dufs.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dufs.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "dufs.image" . }}
      imagePullPolicy: {{ .Values.dufs.image.pullPolicy | quote }}
      {{- if .Values.dufs.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.dufs.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.args "context" $) | nindent 8 }}
      {{- else }}
      args: 
        - --config
        - /etc/dufs/config.yaml
      {{- end }}
      env:
        {{- if .Values.dufs.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.dufs.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.dufs.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dufs.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.dufs.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.dufs.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dufs.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.dufs.resources }}
      resources: {{- toYaml .Values.dufs.resources | nindent 8 }}
      {{- else if ne .Values.dufs.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.dufs.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.dufs.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dufs.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dufs.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dufs.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dufs.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.dufs.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dufs.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/dufs
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $) }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.dufs.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.dufs.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.dufs.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.dufs.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.dufs.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dufs.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.dufs.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.dufs.podRestartPolicy }}
  {{- end }}
{{- end -}}