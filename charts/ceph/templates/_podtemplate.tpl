{{- define "ceph.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
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
    {{- if .Values.ceph.mon.enabled }}
    - name: mon
      image: {{ template "ceph.image" . }}
      imagePullPolicy: {{ .Values.ceph.image.pullPolicy | quote }}
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
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
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
        {{- if .Values.ceph.config.enabled }}
        - name: ceph_conf
          mountPath: {{ .Values.ceph.config.path }}
          subPath: {{ base .Values.ceph.config.path }}
        {{- end }}
        - name: var
          mountPath: {{ .Values.persistence.mountPath.var }}
      {{- if .Values.ceph.mon.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.ceph.mon.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- end }}
    {{- if .Values.ceph.osd.enabled }}
    - name: osd
      image: {{ template "ceph.image" . }}
      imagePullPolicy: {{ .Values.ceph.image.pullPolicy | quote }}
      {{- if .Values.ceph.osd.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.ceph.osd.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.osd.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.osd.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        - name: CEPH_DAEMON
          value: OSD
        {{- if .Values.ceph.osd.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.ceph.osd.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.ceph.osd.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.ceph.osd.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.ceph.osd.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.ceph.osd.resources }}
      resources: {{- toYaml .Values.ceph.osd.resources | nindent 8 }}
      {{- else if ne .Values.ceph.osd.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.ceph.osd.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.osd.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.ceph.osd.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.osd.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.osd.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.osd.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.osd.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.osd.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.ceph.osd.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.ceph.osd.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.ceph.osd.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: etc
          mountPath: {{ .Values.persistence.mountPath.etc }}
        {{- if .Values.ceph.config.enabled }}
        - name: ceph_conf
          mountPath: {{ .Values.ceph.config.path }}
          subPath: {{ base .Values.ceph.config.path }}
        {{- end }}
        - name: var
          mountPath: {{ .Values.persistence.mountPath.var }}
      {{- if .Values.ceph.osd.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.ceph.osd.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- end }}
    {{- if .Values.ceph.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.ceph.osd.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: etc
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}-etc
    {{- if .Values.ceph.config.enabled }}
    - name: ceph_conf
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- end }}
    - name: var
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}-var
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.ceph.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.ceph.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.ceph.podRestartPolicy }}
  {{- end }}
{{- end -}}