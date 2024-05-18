{{- define "vault.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.vault.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.vault.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: vault
    {{- if .Values.vault.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.vault.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "vault.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.vault.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.vault.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.vault.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.vault.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "vault.volumePermissions.image" . }}
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
    {{- if .Values.vault.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.vault.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: vault
      image: {{ template "vault.image" . }}
      imagePullPolicy: {{ .Values.vault.image.pullPolicy }}
      {{- if .Values.vault.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.vault.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.vault.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.vault.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.vault.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.vault.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.vault.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.vault.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.vault.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.vault.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.vault.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.vault.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.vault.resources }}
      resources: {{- toYaml .Values.vault.resources | nindent 8 }}
      {{- end }}
      {{- if .Values.vault.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.vault.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.vault.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.vault.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.vault.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.vault.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.vault.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.vault.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.vault.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.vault.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.vault.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.vault.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.vault.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.vault.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: persistent-volume
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        {{- if (first .Values.vault.configFiles.listeners.listener).tcp.tls_disable }}
        - name: tls
          mountPath: {{ dir (first .Values.vault.configFiles.listeners.listener).tcp.tls_cert_file }}
          subPath: tls.crt
        - name: tls
          mountPath: {{ dir (first .Values.vault.configFiles.listeners.listener).tcp.tls_key_file }}
          subPath: tls.key
        {{- end }}
      {{- if .Values.vault.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.vault.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.vault.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.vault.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    - name: persistent-volume
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if (first .Values.vault.configFiles.listeners.listener).tcp.tls_disable }}
    - name: tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-tlsSec
    {{- end }}
    {{- if .Values.vault.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.vault.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.vault.podRestartPolicy }}
  {{- end }}
{{- end -}}