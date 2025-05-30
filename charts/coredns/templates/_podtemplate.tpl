{{- define "coredns.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.coredns.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: coredns
    {{- if .Values.coredns.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "coredns.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.coredns.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.coredns.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "coredns.volumePermissions.image" . }}
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
    {{- if .Values.coredns.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: coredns
      image: {{ template "coredns.image" . }}
      imagePullPolicy: {{ .Values.coredns.image.pullPolicy | quote }}
      {{- if .Values.coredns.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.coredns.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.coredns.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.coredns.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.coredns.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.coredns.resources }}
      resources: {{- toYaml .Values.coredns.resources | nindent 8 }}
      {{- else if ne .Values.coredns.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.coredns.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.coredns.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config-volume
          mountPath: /etc/coredns
        {{- if .Values.coredns.tls.contents }}
        - name: tls
          mountPath: {{ .Values.coredns.tls.mountPath }}
        {{- end }}
      {{- if .Values.coredns.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.coredns.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.coredns.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config-volume
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
        items:
        - key: Corefile
          path: Corefile
        {{- range .Values.coredns.zoneFiles }}
        - key: {{ .filename }}
          path: {{ .filename }}
        {{- end }}
    {{- if .Values.coredns.tls.contents }}
    - name: tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
  {{- if .Values.coredns.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraVolumes "context" $) | nindent 4 }}
  {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.coredns.podRestartPolicy }}
  {{- end }}
{{- end -}}