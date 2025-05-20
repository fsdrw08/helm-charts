{{- define "alloy.podTemplate" -}}
metadata:
  {{- if eq .Values.workloadKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.alloy.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: alloy
    {{- if .Values.alloy.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alloy.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "alloy.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.alloy.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.alloy.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.alloy.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "alloy.volumePermissions.image" . }}
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
    {{- if .Values.alloy.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alloy.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: alloy
      image: {{ template "alloy.image" . }}
      imagePullPolicy: {{ .Values.alloy.image.pullPolicy | quote }}
      {{- if .Values.alloy.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.alloy.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.args "context" $) | nindent 8 }}
      {{- else }}
      args:
        - run
        {{- include "processFlags" (dict "values" .Values.alloy.flags) | nindent 8 -}}
        {{- /*
        {{- range $key, $value := .Values.alloy.flags }}
          {{- if kindIs "map" $value }}
            {{- range $subkey, $subvalue := $value }}
              {{- if kindIs "map" $subvalue }}
                {{- range $subsubkey, $subsubvalue := $subvalue }}
                  {{- if not (empty $subsubvalue) }}
                  {{- if kindIs "bool" $subsubvalue }}
        - --{{ $key }}.{{ $subkey }}.{{ $subsubkey }}={{ $subsubvalue }}
                  {{- else }}
        - --{{ $key }}.{{ $subkey }}.{{ $subsubkey }}={{ $subsubvalue | quote }}
                  {{- end }}
                  {{- end }}
                {{- end }}
              {{- else if not (empty $subvalue) }}
        - --{{ $key }}.{{ $subkey }}={{ $subvalue | quote }}
              {{- end }}
            {{- end }}
          {{- else if not (empty $value) }}
        - --{{ $key }}={{ $value | quote }}
          {{- end }}
        {{- end }}
        */}}
        - /etc/alloy/config.alloy
      {{- end }}
      env:
        {{- if .Values.alloy.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.alloy.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.alloy.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.alloy.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- /*
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        */}}
        {{- if .Values.alloy.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.alloy.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.alloy.resources }}
      resources: {{- toYaml .Values.alloy.resources | nindent 8 }}
      {{- else if ne .Values.alloy.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.alloy.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.alloy.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.alloy.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alloy.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.alloy.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alloy.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.alloy.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alloy.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.alloy.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.alloy.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.alloy.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.alloy.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.alloy.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alloy.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.workloadKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.alloy.podRestartPolicy }}
  {{- end }}
{{- end -}}