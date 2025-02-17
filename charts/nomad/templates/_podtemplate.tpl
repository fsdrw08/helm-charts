{{- define "nomad.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.nomad.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: nomad
    {{- if .Values.nomad.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nomad.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "nomad.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.nomad.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.nomad.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.nomad.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "nomad.volumePermissions.image" . }}
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
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
    {{- end }}
    {{- if .Values.nomad.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nomad.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: nomad
      image: {{ template "nomad.image" . }}
      imagePullPolicy: {{ .Values.nomad.image.pullPolicy | quote }}
      {{- if .Values.nomad.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.nomad.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.command "context" $) | nindent 8 }}
      {{- else }}
      command:
      {{- end }}
      {{- if .Values.nomad.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.args "context" $) | nindent 8 }}
      {{- else }}
      args:
        - agent
      {{- end }}
      env:
        {{- if .Values.nomad.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.nomad.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.nomad.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.nomad.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.nomad.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.nomad.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.nomad.resources }}
      resources: {{- toYaml .Values.nomad.resources | nindent 8 }}
      {{- else if ne .Values.nomad.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.nomad.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.nomad.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.nomad.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nomad.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.nomad.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nomad.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.nomad.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nomad.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /nomad/config
        {{- if .Values.nomad.tls.contents }}
        - name: tls
          mountPath: {{ .Values.nomad.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.nomad.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.nomad.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.nomad.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.nomad.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.nomad.tls.contents }}
    - name: tls
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
    {{- if .Values.nomad.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nomad.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.nomad.podRestartPolicy }}
  {{- end }}
{{- end -}}