{{- define "nfs-ganesha.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.nfs.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: nfs-ganesha
    {{- if .Values.nfs.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nfs.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "nfs-ganesha.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.nfs.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.nfs.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.nfs.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "nfs-ganesha.volumePermissions.image" . }}
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
    {{- if .Values.nfs.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nfs.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: ganesha
      image: {{ template "nfs-ganesha.image" . }}
      imagePullPolicy: {{ .Values.nfs.image.pullPolicy | quote }}
      {{- if .Values.nfs.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.nfs.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.nfs.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nfs.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.nfs.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.nfs.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.nfs.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.nfs.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.nfs.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.nfs.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.nfs.resources }}
      resources: {{- toYaml .Values.nfs.resources | nindent 8 }}
      {{- else if ne .Values.nfs.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.nfs.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.nfs.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.nfs.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.nfs.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nfs.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nfs.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.nfs.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nfs.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nfs.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nfs.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.nfs.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nfs.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/ganesha/ganesha.conf
          subPath: ganesha.conf
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.nfs.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.nfs.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.nfs.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.nfs.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" $ }}-cm
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.nfs.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nfs.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.nfs.podRestartPolicy }}
  {{- end }}
{{- end -}}