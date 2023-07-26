{{- define "drone.podTemplate" -}}
metadata:
  {{- if eq .Values.instanceKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.droneRunnerDocker.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: server
    {{- if .Values.droneRunnerDocker.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "drone.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.droneRunnerDocker.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.droneRunnerDocker.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.droneRunnerDocker.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "drone.volumePermissions.image" . }}
      imagePullPolicy: {{ .Values.volumePermissions.image.pullPolicy | quote }}
      command:
        - %%commands%%
      securityContext: {{- include "common.tplvalues.render" (dict "value" .Values.volumePermissions.containerSecurityContext "context" $) | nindent 8 }}
      {{- if .Values.volumePermissions.resources }}
      resources: {{- toYaml .Values.volumePermissions.resources | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: foo
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
    {{- end }}
    {{- if .Values.droneRunnerDocker.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: runner
      image: {{ template "runner.image" . }}
      imagePullPolicy: {{ .Values.droneRunnerDocker.image.pullPolicy }}
      {{- if .Values.droneRunnerDocker.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.droneRunnerDocker.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.droneRunnerDocker.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.droneRunnerDocker.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.droneRunnerDocker.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.droneRunnerDocker.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.droneRunnerDocker.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.droneRunnerDocker.resources }}
      resources: {{- toYaml .Values.droneRunnerDocker.resources | nindent 8 }}
      {{- end }}
      {{- if .Values.droneRunnerDocker.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.droneRunnerDocker.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.droneRunnerDocker.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.droneRunnerDocker.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.droneRunnerDocker.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.droneRunnerDocker.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.droneRunnerDocker.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.droneRunnerDocker.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.droneRunnerDocker.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.droneRunnerDocker.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: podman-socket
          mountPath: /var/run/docker.sock
          subPath: docker.sock
        - name: persistent-volume
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.droneRunnerDocker.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- end }}
    {{- if .Values.droneRunnerDocker.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.droneRunnerDocker.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: podman-socket
      hostPath:
        path: {{ .Values.droneRunnerDocker.podmanSocket }}
        # https://kubernetes.io/docs/concepts/storage/volumes/#hostpath-fileorcreate-example
        type: FileOrCreate
    - name: persistent-volume
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.droneRunnerDocker.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.droneRunnerDocker.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.instanceKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.droneRunnerDocker.podRestartPolicy }}
  {{- end }}
