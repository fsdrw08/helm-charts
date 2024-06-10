{{- define "%%TEMPLATE_NAME%%.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.coredns.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: %%COMPONENT_NAME%%
    {{- if .Values.coredns.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "%%TEMPLATE_NAME%%.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.coredns.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.coredns.podSecurityContext "enabled" | toYaml | nindent 4 }}
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
      {{- end }}
      volumeMounts:
        - name: foo
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
    {{- end }}
    {{- if .Values.coredns.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: coredns
      image: {{ template "%%TEMPLATE_NAME%%.image" . }}
      imagePullPolicy: {{ .Values.coredns.image.pullPolicy }}
      {{- if .Values.coredns.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.coredns.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.coredns.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.coredns.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.coredns.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.coredns.resources }}
      resources: {{- toYaml .Values.coredns.resources | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.coredns.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: persistent-volume
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.coredns.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.coredns.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.coredns.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: persistent-volume
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.coredns.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.coredns.podRestartPolicy }}
  {{- end }}
{{- end -}}