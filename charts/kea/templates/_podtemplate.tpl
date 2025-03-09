{{- define "kea.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.kea.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.kea.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: kea
    {{- if .Values.kea.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.kea.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{/*
  {{- include "kea.imagePullSecrets" . | nindent 2 }}
  */}}
  {{- if .Values.kea.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.kea.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.kea.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.kea.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "kea.volumePermissions.image" . }}
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
    {{- if .Values.kea.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.kea.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
  {{- range $key, $val := .Values.kea.containers }}
  {{- if $val.enabled }}
    - name: {{ $key }}
      image: {{ include "common.images.image" (dict "imageRoot" $val.image "global" $.Values.global) }}
      imagePullPolicy: {{ $val.image.pullPolicy | quote }}
      {{- if $val.containerSecurityContext.enabled }}
      securityContext: {{- omit $val.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if $val.command }}
      command: {{- include "common.tplvalues.render" (dict "value" $val.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if $val.args }}
      args: {{- include "common.tplvalues.render" (dict "value" $val.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if $val.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" $val.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if $val.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" $val.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" $ }}
        */ -}}
        {{- if $val.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" $val.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if $val.resources }}
      resources: {{- toYaml $val.resources | nindent 8 }}
      {{- else if ne $val.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" $val.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if $val.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" $val.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if $val.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" $val.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if $val.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit $val.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if $val.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" $val.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if $val.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit $val.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if $val.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" $val.customStartupProbe "context" $) | nindent 8 }}
      {{- else if $val.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit $val.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/kea/kea-{{ $key }}.conf
          subPath: kea-{{ $key }}.conf
        - name: data
          mountPath: {{ $.Values.persistence.mountPath }}
          {{- if $.Values.persistence.subPath }}
          subPath: {{ $.Values.persistence.subPath }}
          {{- end }}
      {{- if $val.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" $val.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
  {{- end }}
  {{- end }}
    {{- if .Values.kea.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.kea.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" $ }}-cm
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.kea.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.kea.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.kea.podRestartPolicy }}
  {{- end }}
{{- end -}}