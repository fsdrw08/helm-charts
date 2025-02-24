{{- define "consul.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.consul.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.consul.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: consul
    {{- if .Values.consul.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consul.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "consul.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.consul.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.consul.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.consul.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.consul.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "consul.volumePermissions.image" . }}
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
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
    {{- end }}
    {{- if .Values.consul.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consul.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: consul
      image: {{ template "consul.image" . }}
      imagePullPolicy: {{ .Values.consul.image.pullPolicy | quote }}
      {{- if .Values.consul.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.consul.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.consul.command "context" $) | nindent 8 }}
      {{- else }}
      command:
      {{- end }}
      {{- if .Values.consul.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.consul.args "context" $) | nindent 8 }}
      {{- else }}
      args:
        - agent
      {{- end }}
      env:
        {{- if .Values.consul.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.consul.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.consul.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.consul.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.consul.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.consul.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.consul.resources }}
      resources: {{- toYaml .Values.consul.resources | nindent 8 }}
      {{- else if ne .Values.consul.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.consul.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.consul.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.consul.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consul.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.consul.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consul.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consul.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.consul.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consul.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consul.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.consul.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consul.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /consul/config
        {{- if .Values.consul.tls.contents }}
        - name: tls
          mountPath: {{ .Values.consul.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.consul.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.consul.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.consul.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.consul.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.consul.tls.contents }}
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
    {{- if .Values.consul.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consul.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.consul.podRestartPolicy }}
  {{- end }}
{{- end -}}