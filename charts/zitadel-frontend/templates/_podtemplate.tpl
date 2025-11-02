{{- define "zitadelLogin.podTemplate" -}}
metadata:
  {{- if eq .Values.zitadelLogin.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.zitadelLogin.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: zitadel-login
    {{- if .Values.zitadelLogin.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "zitadelLogin.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.zitadelLogin.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  hostNetwork: {{ .Values.zitadelLogin.hostNetwork }}
  {{- if .Values.zitadelLogin.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.zitadelLogin.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.zitadelLogin.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "zitadelLogin.volumePermissions.image" . }}
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
    {{- if .Values.zitadelLogin.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: login
      image: {{ template "zitadelLogin.image" . }}
      imagePullPolicy: {{ .Values.zitadelLogin.image.pullPolicy | quote }}
      {{- if .Values.zitadelLogin.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.zitadelLogin.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadelLogin.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadelLogin.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.zitadelLogin.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        - configMapRef:
            name: {{ template "common.names.fullname" . }}-cm
        {{- if .Values.zitadelLogin.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.zitadelLogin.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.zitadelLogin.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.zitadelLogin.resources }}
      resources: {{- toYaml .Values.zitadelLogin.resources | nindent 8 }}
      {{- else if ne .Values.zitadelLogin.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.zitadelLogin.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadelLogin.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.zitadelLogin.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zitadelLogin.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zitadelLogin.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadelLogin.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zitadelLogin.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zitadelLogin.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zitadelLogin.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.zitadelLogin.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zitadelLogin.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.persistence.enabled }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        {{- end }}
      {{- if .Values.zitadelLogin.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.zitadelLogin.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.zitadelLogin.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- if .Values.persistence.enabled }}
    - name: data
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- end }}
    {{- if .Values.zitadelLogin.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zitadelLogin.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.zitadelLogin.podRestartPolicy }}
  {{- end }}
{{- end -}}