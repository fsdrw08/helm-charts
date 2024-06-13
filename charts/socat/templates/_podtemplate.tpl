{{- define "socat.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.socat.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.socat.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: socat
    {{- if .Values.socat.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.socat.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "socat.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.socat.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.socat.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.socat.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.socat.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "socat.volumePermissions.image" . }}
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
    {{- if .Values.socat.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.socat.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: socat
      image: {{ template "socat.image" . }}
      imagePullPolicy: {{ .Values.socat.image.pullPolicy }}
      {{- if .Values.socat.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.socat.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.socat.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.socat.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.socat.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.socat.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.socat.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.socat.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.socat.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.socat.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.socat.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.socat.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.socat.resources }}
      resources: {{- toYaml .Values.socat.resources | nindent 8 }}
      {{- end }}
      {{- if .Values.socat.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.socat.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.socat.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.socat.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.socat.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.socat.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.socat.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.socat.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.socat.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.socat.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.socat.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.socat.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.socat.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.socat.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.socat.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.socat.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.socat.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.socat.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.socat.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.socat.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.socat.podRestartPolicy }}
  {{- end }}
{{- end -}}