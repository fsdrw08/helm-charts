{{- define "jenkins.podTemplate" -}}
metadata:
  {{- if eq .Values.instanceKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.jenkinsController.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: server
    {{- if .Values.jenkinsController.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "jenkins.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.jenkinsController.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.jenkinsController.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.jenkinsController.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "jenkins.volumePermissions.image" . }}
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
    {{- if .Values.jenkinsController.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: jenkinsController
      image: {{ template "jenkins.image" . }}
      imagePullPolicy: {{ .Values.jenkinsController.image.pullPolicy }}
      {{- if .Values.jenkinsController.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.jenkinsController.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.jenkinsController.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.jenkinsController.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.jenkinsController.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.jenkinsController.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.jenkinsController.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.jenkinsController.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.jenkinsController.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.jenkinsController.resources }}
      resources: {{- toYaml .Values.jenkinsController.resources | nindent 8 }}
      {{- end }}
      {{- if .Values.jenkinsController.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.jenkinsController.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.jenkinsController.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.jenkinsController.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.jenkinsController.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.jenkinsController.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.jenkinsController.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.jenkinsController.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.jenkinsController.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.jenkinsController.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: jenkins-home
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.jenkinsController.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.jenkinsController.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.jenkinsController.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: jenkins-home
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.jenkinsController.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.jenkinsController.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.instanceKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.instanceKind }}
  {{- end }}
{{- end -}}