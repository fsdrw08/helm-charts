{{- define "opendj.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.opendj.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: opendj
    {{- if .Values.opendj.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.opendj.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "opendj.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.opendj.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.opendj.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.opendj.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "opendj.volumePermissions.image" . }}
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
    {{- if .Values.opendj.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.opendj.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "opendj.image" . }}
      imagePullPolicy: {{ .Values.opendj.image.pullPolicy | quote }}
      {{- if .Values.opendj.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.opendj.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.opendj.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.opendj.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.opendj.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.opendj.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        - configMapRef:
            name: {{ template "common.names.fullname" . }}-cm-envvar
        {{- if .Values.opendj.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.opendj.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */ -}}
        {{- if .Values.opendj.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.opendj.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.opendj.resources }}
      resources: {{- toYaml .Values.opendj.resources | nindent 8 }}
      {{- else if ne .Values.opendj.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.opendj.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.opendj.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.opendj.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.opendj.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.opendj.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.opendj.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.opendj.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.opendj.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.opendj.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.opendj.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.opendj.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.opendj.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.opendj.ssl.contents_b64 }}
        - name: ssl
          mountPath: {{ .Values.opendj.ssl.mountPath }}
        {{- end }}
        {{- if .Values.opendj.schemas }}
        - name: schemas
          mountPath: /opt/opendj/bootstrap/schema
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.opendj.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.opendj.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.opendj.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.opendj.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- if .Values.opendj.ssl.contents_b64 }}
    - name: ssl
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-ssl
    {{- end }}
    {{- if .Values.opendj.schemas }}
    - name: schemas
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-schemas
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.opendj.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.opendj.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.opendj.podRestartPolicy }}
  {{- end }}
{{- end -}}