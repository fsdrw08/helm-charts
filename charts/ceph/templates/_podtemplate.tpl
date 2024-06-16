{{- define "ceph.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.ceph.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: ceph
    {{- if .Values.ceph.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.ceph.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "ceph.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.ceph.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.ceph.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.ceph.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "ceph.volumePermissions.image" . }}
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
        - name: etc
          mountPath: {{ .Values.persistence.mountPath.etc }}
        - name: var
          mountPath: {{ .Values.persistence.mountPath.var }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
    {{- end }}
    {{- if .Values.ceph.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.ceph.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    {{- if and .Values.mon.enabled }}
    - name: mon
      image: {{ template "ceph.image" . }}
      imagePullPolicy: {{ .Values.ceph.image.pullPolicy }}
      {{- if .Values.ceph.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.ceph.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.ceph.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.ceph.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.ceph.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.ceph.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.ceph.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.ceph.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.ceph.resources }}
      resources: {{- toYaml .Values.ceph.resources | nindent 8 }}
      {{- else if ne .Values.ceph.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.ceph.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.ceph.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: etc
          mountPath: {{ .Values.persistence.mountPath.etc }}
        - name: var
          mountPath: {{ .Values.persistence.mountPath.var }}
      {{- if .Values.ceph.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.ceph.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.ceph.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.ceph.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: etc
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    - name: var
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.ceph.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.ceph.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.ceph.podRestartPolicy }}
  {{- end }}
{{- end -}}