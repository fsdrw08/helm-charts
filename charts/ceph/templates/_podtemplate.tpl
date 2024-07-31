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
    {{- if and .Values.ceph.mon.enabled }}
    - name: mon
      image: {{ template "ceph.image" . }}
      imagePullPolicy: {{ .Values.ceph.mon.image.pullPolicy }}
      {{- if .Values.ceph.mon.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.ceph.mon.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.mon.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.mon.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        - name: CEPH_DAEMON
          value: MON
        {{- if .Values.ceph.mon.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.ceph.mon.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.ceph.mon.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.ceph.mon.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.ceph.mon.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.ceph.mon.resources }}
      resources: {{- toYaml .Values.ceph.mon.resources | nindent 8 }}
      {{- else if ne .Values.ceph.mon.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.ceph.mon.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.mon.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.ceph.mon.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.mon.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.mon.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.mon.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.mon.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.mon.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.mon.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.mon.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.mon.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: etc
          mountPath: {{ .Values.persistence.mountPath.etc }}
        - name: var
          mountPath: {{ .Values.persistence.mountPath.var }}
      {{- if .Values.ceph.mon.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.ceph.mon.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.ceph.mon.sidecars "context" $) | nindent 4 }}
    {{- end }}
    {{- end }}
  volumes:
    - name: etc
      {{- if .Values.ceph.config.setFromImage }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}-pvc-etc
      {{- else }}
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
      {{- end }}
    - name: var
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}-pvc-var
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