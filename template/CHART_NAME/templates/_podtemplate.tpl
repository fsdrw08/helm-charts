{{- define "%%TEMPLATE_NAME%%.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: %%COMPONENT_NAME%%
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "%%TEMPLATE_NAME%%.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.%%MAIN_OBJECT_BLOCK%%.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
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
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: %%MAIN_OBJECT_BLOCK%%
      image: {{ template "%%TEMPLATE_NAME%%.image" . }}
      imagePullPolicy: {{ .Values.%%MAIN_OBJECT_BLOCK%%.image.pullPolicy | quote }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.%%MAIN_OBJECT_BLOCK%%.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.resources }}
      resources: {{- toYaml .Values.%%MAIN_OBJECT_BLOCK%%.resources | nindent 8 }}
      {{- else if ne .Values.%%MAIN_OBJECT_BLOCK%%.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.%%MAIN_OBJECT_BLOCK%%.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.%%MAIN_OBJECT_BLOCK%%.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.%%MAIN_OBJECT_BLOCK%%.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.%%MAIN_OBJECT_BLOCK%%.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.%%MAIN_OBJECT_BLOCK%%.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.%%MAIN_OBJECT_BLOCK%%.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.%%MAIN_OBJECT_BLOCK%%.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.%%MAIN_OBJECT_BLOCK%%.podRestartPolicy }}
  {{- end }}
{{- end -}}