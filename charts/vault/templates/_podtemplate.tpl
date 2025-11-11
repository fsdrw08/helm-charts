{{- define "vault.podTemplate" -}}
metadata:
  {{- if eq .Values.vault.workloadKind "Pod" }}
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
  hostNetwork: {{ .Values.vault.hostNetwork }}
  {{- if .Values.vault.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.vault.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.vault.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.vault.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "vault.volumePermissions.image" . }}
      {{/*
      https://github.com/cello-proj/cello/blob/d00b16e337af4fa131146fd63c43863097ac36ed/scripts/quickstart_manifest.yaml#L420
      */}}
      imagePullPolicy: {{ .Values.volumePermissions.image.pullPolicy | quote }}
      command:
        - chown
        - -R
        - {{ .Values.vault.containerSecurityContext.runAsUser }}:{{ .Values.vault.containerSecurityContext.runAsGroup }}
        - /vault
      securityContext: {{- include "common.tplvalues.render" (dict "value" .Values.volumePermissions.containerSecurityContext "context" $) | nindent 8 }}
      {{- if .Values.volumePermissions.resources }}
      resources: {{- toYaml .Values.volumePermissions.resources | nindent 8 }}
      {{- else if ne .Values.volumePermissions.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.volumePermissions.resourcesPreset) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: storage
          mountPath: {{ .Values.persistence.mountPath.storage }}
        - name: logs
          mountPath: {{ .Values.persistence.mountPath.logs }}
    {{- end }}
    {{- if .Values.vault.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.vault.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "vault.image" . }}
      imagePullPolicy: {{ .Values.vault.image.pullPolicy | quote }}
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
        {{- if .Values.vault.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.vault.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.vault.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.vault.resources }}
      resources: {{- toYaml .Values.vault.resources | nindent 8 }}
      {{- else if ne .Values.vault.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.vault.resourcesPreset) | nindent 8 }}
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
        - name: config
          mountPath: /vault/config
        - name: storage
          mountPath: {{ .Values.persistence.mountPath.storage }}
        - name: logs
          mountPath: {{ .Values.persistence.mountPath.logs }}
        {{- if .Values.vault.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.vault.secret.tls.mountPath }}
        {{- end }}
      {{- if .Values.vault.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.vault.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.vault.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.vault.sidecars "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.vault.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.vault.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.vault.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    - name: storage
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc-file" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    - name: logs
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc-logs" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.vault.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.vault.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.vault.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.vault.podRestartPolicy }}
  {{- end }}
{{- end -}}