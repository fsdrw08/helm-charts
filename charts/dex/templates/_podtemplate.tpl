{{- define "dex.podTemplate" -}}
metadata:
  {{- if eq .Values.dex.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.dex.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.dex.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: dex
    {{- if .Values.dex.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dex.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "dex.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.dex.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.dex.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  hostNetwork: {{ .Values.dex.hostNetwork }}
  {{- if .Values.dex.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.dex.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.dex.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.dex.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "dex.volumePermissions.image" . }}
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
    {{- if .Values.dex.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dex.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: idp
      image: {{ template "dex.image" . }}
      imagePullPolicy: {{ .Values.dex.image.pullPolicy | quote }}
      {{- if .Values.dex.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.dex.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.dex.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.dex.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.dex.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.dex.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.dex.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dex.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.dex.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.dex.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dex.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.dex.resources }}
      resources: {{- toYaml .Values.dex.resources | nindent 8 }}
      {{- else if ne .Values.dex.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.dex.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.dex.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.dex.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dex.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dex.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dex.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dex.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dex.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dex.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dex.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.dex.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dex.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.dex.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.dex.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.dex.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.dex.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.dex.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dex.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.dex.podRestartPolicy }}
  {{- end }}
{{- end -}}