{{- define "zot.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.zot.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.zot.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: zot
    {{- if .Values.zot.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zot.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "zot.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.zot.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.zot.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.zot.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.zot.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "zot.volumePermissions.image" . }}
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
    {{- if .Values.zot.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zot.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: zot
      image: {{ template "zot.image" . }}
      imagePullPolicy: {{ .Values.zot.image.pullPolicy | quote }}
      {{- if .Values.zot.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.zot.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.zot.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.zot.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.zot.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.zot.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.zot.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zot.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.zot.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zot.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.zot.resources }}
      resources: {{- toYaml .Values.zot.resources | nindent 8 }}
      {{- else if ne .Values.zot.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.zot.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.zot.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.zot.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zot.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zot.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zot.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zot.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zot.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zot.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zot.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.zot.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zot.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/zot/config.json
          subPath: config.json
        {{- if .Values.zot.htpasswdCredentials }}
        - name: config
          mountPath: {{ .Values.zot.config.http.auth.htpasswd.path }}
          subPath: htpasswd
        {{- end }}
        {{- if .Values.zot.tls.contents }}
        - name: tls
          mountPath: {{ .Values.zot.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.zot.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.zot.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.zot.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.zot.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.zot.tls.contents }}
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
    {{- if .Values.zot.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zot.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.zot.podRestartPolicy }}
  {{- end }}
{{- end -}}