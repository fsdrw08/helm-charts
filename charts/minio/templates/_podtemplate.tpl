{{- define "minio.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.minio.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.minio.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: minio
    {{- if .Values.minio.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.minio.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "minio.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.minio.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.minio.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.minio.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.minio.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "minio.volumePermissions.image" . }}
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
    {{- if .Values.minio.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.minio.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: minio
      image: {{ template "minio.image" . }}
      imagePullPolicy: {{ .Values.minio.image.pullPolicy | quote }}
      {{- if .Values.minio.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.minio.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.minio.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.minio.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.minio.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.minio.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.minio.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.minio.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.minio.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.minio.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.minio.resources }}
      resources: {{- toYaml .Values.minio.resources | nindent 8 }}
      {{- else if ne .Values.minio.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.minio.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.minio.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.minio.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.minio.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.minio.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.minio.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.minio.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.minio.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.minio.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.minio.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.minio.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.minio.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if and ( index .Values.minio.tls.contents "public.crt" ) ( index .Values.minio.tls.contents "private.key" ) }}
        - name: tls-default
          mountPath: {{ .Values.minio.tls.mountPath }}
        {{- end }}
        {{- if .Values.minio.tls.contents.additionalDomains }}
        {{- range $additionalDomain := .Values.minio.tls.contents.additionalDomains }}
        - name: tls-additional-{{ $additionalDomain.name }}
          mountPath: {{ $.Values.minio.tls.mountPath }}/{{ $additionalDomain.name }}
        {{- end }}
        {{- end }}
        {{- if .Values.minio.tls.contents.CAs }}
        {{- range $key, $val := .Values.minio.tls.contents.CAs }}
        - name: tls-ca-{{ $key }}
          mountPath: {{ $.Values.minio.tls.mountPath }}/CAs
        {{- end }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.minio.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.minio.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.minio.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.minio.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- if and ( index .Values.minio.tls.contents "public.crt" ) ( index .Values.minio.tls.contents "private.key" ) }}
    - name: tls-default
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
        items:
          - key: public.crt
            path: public.crt
          - key: private.key
            path: private.key
    {{- end }}
    {{- if .Values.minio.tls.contents.additionalDomains }}
    {{- range $additionalDomain := .Values.minio.tls.contents.additionalDomains }}
    - name: tls-additional-{{ $additionalDomain.name }}
      secret:
        secretName: {{ template "common.names.fullname" $ }}-sec-tls
        items:
          - key: {{ $additionalDomain.name }}.public.crt
            path: public.crt
          - key: {{ $additionalDomain.name }}.private.key
            path: private.key
    {{- end }}
    {{- end }}
    {{- if .Values.minio.tls.contents.CAs }}
    {{- range $key, $val := .Values.minio.tls.contents.CAs }}
    - name: tls-ca-{{ trimSuffix (ext $key) $key }}
      secret:
        secretName: {{ template "common.names.fullname" $ }}-sec-tls
        items:
          - key: ca.{{ $key }}
            path: {{ $key }}
    {{- end }}
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.minio.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.minio.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.minio.podRestartPolicy }}
  {{- end }}
{{- end -}}