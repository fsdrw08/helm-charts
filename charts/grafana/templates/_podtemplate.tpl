{{- define "grafana.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.grafana.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: grafana
    {{- if .Values.grafana.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.grafana.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "grafana.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.grafana.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.grafana.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.grafana.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "grafana.volumePermissions.image" . }}
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
    {{- if .Values.grafana.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.grafana.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "grafana.image" . }}
      imagePullPolicy: {{ .Values.grafana.image.pullPolicy | quote }}
      {{- if .Values.grafana.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.grafana.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.grafana.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.grafana.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.grafana.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.grafana.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.grafana.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.grafana.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.grafana.resources }}
      resources: {{- toYaml .Values.grafana.resources | nindent 8 }}
      {{- else if ne .Values.grafana.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.grafana.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.grafana.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.grafana.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.grafana.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.grafana.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.grafana.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.grafana.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.grafana.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: custom
          mountPath: /etc/grafana/grafana.ini
          subPath: grafana.ini
        {{- if .Values.grafana.configFiles.dataSource }}
        - name: dataSource
          mountPath: {{ .Values.grafana.configFiles.custom.paths.provisioning }}/datasources
        {{- end }}
        {{- if .Values.grafana.configFiles.ldap }}
        - name: ldap
          mountPath: /etc/grafana/ldap.toml
          subPath: ldap.toml
        {{- end }}
        {{- if .Values.grafana.tls.contents }}
        - name: tls
          mountPath: {{ .Values.grafana.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.grafana.configFiles.custom.paths.data }}
      {{- if .Values.grafana.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.grafana.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.grafana.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.grafana.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: custom
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-custom
    {{- if .Values.grafana.configFiles.dataSource }}
    - name: dataSource
      configMap:
        name: {{ include "common.names.fullname" . }}-cm-datasource
    {{- end }}
    {{- if .Values.grafana.configFiles.ldap }}
    - name: ldap
      secret:
        secretName: {{ include "common.names.fullname" . }}-sec-ldap
        items:
          - key: ldap.toml
            path: ldap.toml
    {{- end }}
    {{- if .Values.grafana.tls.contents }}
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
    {{- if .Values.grafana.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.grafana.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.grafana.podRestartPolicy }}
  {{- end }}
{{- end -}}