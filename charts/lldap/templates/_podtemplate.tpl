{{- define "lldap.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.lldap.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: lldap
    {{- if .Values.lldap.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.lldap.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "lldap.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.lldap.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.lldap.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.lldap.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "lldap.volumePermissions.image" . }}
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
    {{- if .Values.lldap.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.lldap.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: lldap
      image: {{ template "lldap.image" . }}
      imagePullPolicy: {{ .Values.lldap.image.pullPolicy | quote }}
      {{- if .Values.lldap.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.lldap.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.lldap.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.lldap.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.lldap.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.lldap.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.lldap.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.lldap.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.lldap.resources }}
      resources: {{- toYaml .Values.lldap.resources | nindent 8 }}
      {{- else if ne .Values.lldap.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.lldap.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.lldap.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.lldap.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.lldap.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.lldap.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.lldap.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.lldap.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.lldap.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.lldap.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.lldap.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.lldap.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.lldap.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.lldap.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.lldap.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.lldap.podRestartPolicy }}
  {{- end }}
{{- end -}}