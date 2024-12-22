{{- define "etcd.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.etcd.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: etcd
    {{- if .Values.etcd.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.etcd.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "etcd.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.etcd.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.etcd.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.etcd.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "etcd.volumePermissions.image" . }}
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
    {{- if .Values.etcd.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.etcd.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: etcd
      image: {{ template "etcd.image" . }}
      imagePullPolicy: {{ .Values.etcd.image.pullPolicy }}
      {{- if .Values.etcd.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.etcd.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.args "context" $) | nindent 8 }}
      {{/*
      {{- else }}
      args: 
        - --config-file
        - /etc/etcd/etcd.config.yml
      */}}
      {{- end }}
      env:
        - name: ETCD_CONFIG_FILE
          value: /etc/etcd/etcd.config.yml
        {{- if .Values.etcd.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.etcd.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.etcd.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.etcd.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.etcd.extraEnvVarsSecret }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- end }}
        {{- if .Values.etcd.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.etcd.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.etcd.resources }}
      resources: {{- toYaml .Values.etcd.resources | nindent 8 }}
      {{- else if ne .Values.etcd.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.etcd.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.etcd.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.etcd.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.etcd.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.etcd.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.etcd.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.etcd.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.etcd.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/etcd/etcd.config.yml
          subPath: etcd.config.yml
        {{- if .Values.etcd.tls.contents }}
        - name: tls
          mountPath: {{ .Values.etcd.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.etcd.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.etcd.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.etcd.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.etcd.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
        items:
          - key: etcd.config.yml
            path: etcd.config.yml
    {{- if .Values.etcd.tls.contents }}
    - name: tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}-pvc
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.etcd.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.etcd.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.etcd.podRestartPolicy }}
  {{- end }}
{{- end -}}