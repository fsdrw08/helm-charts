{{- define "powerdns.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.powerdns.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: powerdns
    {{- if .Values.powerdns.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "powerdns.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.powerdns.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.powerdns.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.powerdns.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "powerdns.volumePermissions.image" . }}
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
    {{- if .Values.powerdns.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: auth
      image: {{ template "powerdns.image" . }}
      imagePullPolicy: {{ .Values.powerdns.image.pullPolicy | quote }}
      {{- if .Values.powerdns.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.powerdns.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.powerdns.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.powerdns.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.powerdns.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.powerdns.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.powerdns.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */ -}}
        {{- if .Values.powerdns.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.powerdns.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.powerdns.resources }}
      resources: {{- toYaml .Values.powerdns.resources | nindent 8 }}
      {{- else if ne .Values.powerdns.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.powerdns.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.powerdns.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.powerdns.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.powerdns.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.powerdns.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.powerdns.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.powerdns.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.powerdns.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.powerdns.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.powerdns.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.powerdns.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: settings
          mountPath: /etc/powerdns
          subPath: pdns.conf
        {{- if index .Values "powerdns" "configFiles" "pdns" "include-dir" }}
        - name: include-dir
          mountPath: {{ index .Values "powerdns" "configFiles" "pdns" "include-dir" }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.powerdns.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.powerdns.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.powerdns.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: settings
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-main
        items:
          - key: pdns.conf
            path: pdns.conf
    {{- if index .Values "powerdns" "configFiles" "pdns" "include-dir" }}
    - name: include-dir
      configMap: 
        name: {{ template "common.names.fullname" . }}-cm-include
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.powerdns.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.powerdns.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.powerdns.podRestartPolicy }}
  {{- end }}
{{- end -}}