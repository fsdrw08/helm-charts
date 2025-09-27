{{- define "sftpgo.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.sftpgo.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: sftpgo
    {{- if .Values.sftpgo.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "sftpgo.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.sftpgo.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.sftpgo.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.sftpgo.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "sftpgo.volumePermissions.image" . }}
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
    {{- if .Values.sftpgo.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "sftpgo.image" . }}
      imagePullPolicy: {{ .Values.sftpgo.image.pullPolicy | quote }}
      {{- if .Values.sftpgo.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.sftpgo.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.sftpgo.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.sftpgo.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.sftpgo.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.sftpgo.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.sftpgo.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.sftpgo.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.sftpgo.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.sftpgo.resources }}
      resources: {{- toYaml .Values.sftpgo.resources | nindent 8 }}
      {{- else if ne .Values.sftpgo.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.sftpgo.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.sftpgo.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.sftpgo.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.sftpgo.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.sftpgo.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.sftpgo.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.sftpgo.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.sftpgo.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.sftpgo.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.sftpgo.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.sftpgo.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
        {{/*
          mountPath: /etc/sftpgo/sftpgo.json
        */}}
          mountPath: /etc/sftpgo
      {{- range $name, $path := .Values.persistence.mountPath }}
        - name: {{ $name }}
          mountPath: {{ $path }}
          {{- if hasKey $.Values.persistence.subPath $name }}
          subPath: {{ index $.Values.persistence.subPath $name }}
          {{- end }}
      {{- end }}
      {{- if .Values.sftpgo.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.sftpgo.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.sftpgo.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- range $name, $path := .Values.persistence.mountPath }}
    - name: {{ $name }}
      {{- if $.Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" $) "-pvc-" $name ) $.Values.persistence.existingClaim }}
      {{- else }}
      emptyDir: {}
      {{- end }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.sftpgo.tls.contents }}
    - name: tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{- if .Values.sftpgo.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.sftpgo.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.sftpgo.podRestartPolicy }}
  {{- end }}
{{- end -}}