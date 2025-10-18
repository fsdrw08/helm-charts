{{- define "consulTemplate.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.consulTemplate.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: consulTemplate
    {{- if .Values.consulTemplate.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "consulTemplate.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.consulTemplate.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  hostNetwork: {{ .Values.consulTemplate.hostNetwork }}
  {{- if .Values.consulTemplate.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.consulTemplate.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.consulTemplate.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "consulTemplate.volumePermissions.image" . }}
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
    {{- if .Values.consulTemplate.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: daemon
      image: {{ template "consulTemplate.image" . }}
      imagePullPolicy: {{ .Values.consulTemplate.image.pullPolicy | quote }}
      {{- if .Values.consulTemplate.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.consulTemplate.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.consulTemplate.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consulTemplate.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.consulTemplate.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.consulTemplate.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.consulTemplate.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.consulTemplate.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.consulTemplate.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.consulTemplate.resources }}
      resources: {{- toYaml .Values.consulTemplate.resources | nindent 8 }}
      {{- else if ne .Values.consulTemplate.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.consulTemplate.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.consulTemplate.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.consulTemplate.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.consulTemplate.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consulTemplate.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consulTemplate.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.consulTemplate.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consulTemplate.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consulTemplate.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.consulTemplate.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consulTemplate.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /consul-template/config
        {{- if .Values.consulTemplate.templates }}
        - name: templates
          mountPath: /consul-template/templates
        {{- end }}
        {{- if .Values.consulTemplate.tls.contents }}
        - name: tls
          mountPath: {{ .Values.consulTemplate.tls.mountPath }}
        {{- end }}
        {{/*
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        */}}
      {{- if .Values.consulTemplate.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.consulTemplate.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.consulTemplate.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.consulTemplate.templates }}
    - name: templates
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-tmpl
    {{- end }}
    {{- if .Values.consulTemplate.tls.contents }}
    - name: tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{/*
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    */}}
    {{- if .Values.consulTemplate.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consulTemplate.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.consulTemplate.podRestartPolicy }}
  {{- end }}
{{- end -}}