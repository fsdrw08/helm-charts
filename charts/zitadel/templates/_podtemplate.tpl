{{- define "%%TEMPLATE_NAME%%.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.zitadel.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: %%COMPONENT_NAME%%
    {{- if .Values.zitadel.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "%%TEMPLATE_NAME%%.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.zitadel.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  hostNetwork: {{ .Values.zitadel.hostNetwork }}
  {{- if .Values.zitadel.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.zitadel.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.zitadel.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "%%TEMPLATE_NAME%%.volumePermissions.image" . }}
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
    {{- if .Values.zitadel.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: zitadel
      image: {{ template "%%TEMPLATE_NAME%%.image" . }}
      imagePullPolicy: {{ .Values.zitadel.image.pullPolicy | quote }}
      {{- if .Values.zitadel.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.zitadel.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadel.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadel.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.zitadel.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.zitadel.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zitadel.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.zitadel.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zitadel.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.zitadel.resources }}
      resources: {{- toYaml .Values.zitadel.resources | nindent 8 }}
      {{- else if ne .Values.zitadel.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.zitadel.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadel.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.zitadel.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zitadel.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zitadel.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadel.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zitadel.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zitadel.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadel.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.zitadel.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zitadel.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.zitadel.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.zitadel.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.zitadel.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.zitadel.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zitadel.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.zitadel.podRestartPolicy }}
  {{- end }}
{{- end -}}