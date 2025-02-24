{{- define "postgresql.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.postgresql.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: postgresql
    {{- if .Values.postgresql.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "postgresql.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.postgresql.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.postgresql.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.postgresql.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "postgresql.volumePermissions.image" . }}
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
    {{- if .Values.postgresql.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: postgresql
      image: {{ template "postgresql.image" . }}
      imagePullPolicy: {{ .Values.postgresql.image.pullPolicy | quote }}
      {{- if .Values.postgresql.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.postgresql.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.postgresql.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        - configMapRef:
            name: {{ template "common.names.fullname" . }}-cm-envvar
        {{- if .Values.postgresql.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.postgresql.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */ -}}
        {{- if .Values.postgresql.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.postgresql.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.postgresql.resources }}
      resources: {{- toYaml .Values.postgresql.resources | nindent 8 }}
      {{- else if ne .Values.postgresql.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.postgresql.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.postgresql.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.postgresql.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.postgresql.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.postgresql.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.postgresql.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.postgresql.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.postgresql.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- range $key, $val := .Values.postgresql.extending }}
        {{- if $val }}
        - name: config-extending-{{ $key }}
          mountPath: /opt/app-root/src/postgresql-{{ $key }}
        {{- end }}
        {{- end }}
        {{- if .Values.postgresql.ssl.contents }}
        - name: ssl
          mountPath: {{ .Values.postgresql.ssl.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.postgresql.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.postgresql.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.postgresql.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- range $key, $val := .Values.postgresql.extending }}
    {{- if $val }}
    - name: config-extending-{{ $key }}
      configMap: 
        name: {{ template "common.names.fullname" $ }}-cm-extending-{{ $key }}
    {{- end }}
    {{- end }}
    {{- if .Values.postgresql.ssl.contents }}
    - name: ssl
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-ssl
        defaultMode: 0600
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.postgresql.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.postgresql.podRestartPolicy }}
  {{- end }}
{{- end -}}