{{- define "cockpit.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.cockpit.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: cockpit
    {{- if .Values.cockpit.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "cockpit.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.cockpit.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.cockpit.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.cockpit.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "cockpit.volumePermissions.image" . }}
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
    {{- if .Values.cockpit.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: ws
      image: {{ template "cockpit.image" . }}
      imagePullPolicy: {{ .Values.cockpit.image.pullPolicy | quote }}
      {{- if .Values.cockpit.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.cockpit.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.cockpit.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.cockpit.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.cockpit.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.cockpit.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.cockpit.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.cockpit.resources }}
      resources: {{- toYaml .Values.cockpit.resources | nindent 8 }}
      {{- else if ne .Values.cockpit.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.cockpit.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.cockpit.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.cockpit.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.cockpit.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.cockpit.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.cockpit.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.cockpit.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.cockpit.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/cockpit/cockpit.conf
          subPath: cockpit.conf
        {{- if .Values.cockpit.tls.contents }}
        - name: tls
          mountPath: {{ .Values.cockpit.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.cockpit.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.cockpit.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.cockpit.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.cockpit.tls.contents }}
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
    {{- if .Values.cockpit.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.cockpit.podRestartPolicy }}
  {{- end }}
{{- end -}}