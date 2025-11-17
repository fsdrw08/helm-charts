{{- define "loki.podTemplate" -}}
metadata:
  {{- if eq .Values.loki.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.loki.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.loki.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: loki
    {{- if .Values.loki.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.loki.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "loki.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.loki.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.loki.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  hostNetwork: {{ .Values.loki.hostNetwork }}
  {{- if .Values.loki.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.loki.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.loki.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.loki.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "loki.volumePermissions.image" . }}
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
    {{- if .Values.loki.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.loki.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "loki.image" . }}
      imagePullPolicy: {{ .Values.loki.image.pullPolicy | quote }}
      {{- if .Values.loki.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.loki.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.loki.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.loki.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.loki.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.loki.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.loki.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.loki.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.loki.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.loki.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.loki.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.loki.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.loki.resources }}
      resources: {{- toYaml .Values.loki.resources | nindent 8 }}
      {{- else if ne .Values.loki.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.loki.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.loki.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.loki.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.loki.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.loki.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.loki.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.loki.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.loki.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.loki.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.loki.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.loki.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.loki.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.loki.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.loki.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.loki.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/loki/local-config.yaml
          subPath: local-config.yaml
        {{- if .Values.loki.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.loki.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.loki.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.loki.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.loki.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.loki.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.loki.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.loki.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.loki.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.loki.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.loki.podRestartPolicy }}
  {{- end }}
{{- end -}}