{{- define "traefik.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.traefik.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: traefik
    {{- if .Values.traefik.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.traefik.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "traefik.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.traefik.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.traefik.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.traefik.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "traefik.volumePermissions.image" . }}
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
    {{- if .Values.traefik.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.traefik.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: traefik
      image: {{ template "traefik.image" . }}
      imagePullPolicy: {{ .Values.traefik.image.pullPolicy }}
      {{- if .Values.traefik.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.traefik.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.traefik.customRootCA }}
        - name: LEGO_CA_CERTIFICATES
          value: /etc/traefik/root_ca.crt
        - name: LEGO_CA_SYSTEM_CERT_POOL
          value: "true"
        {{- end }}
        {{- if .Values.traefik.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.traefik.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.traefik.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.traefik.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.traefik.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.traefik.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.traefik.resources }}
      resources: {{- toYaml .Values.traefik.resources | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.traefik.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.traefik.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.traefik.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.traefik.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.traefik.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.traefik.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.traefik.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.persistence.mountPath }}
        - name: persistent-volume
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        {{- end }}
        {{- if .Values.traefik.customRootCA }}
        - name: root_ca.crt
          mountPath: /etc/traefik/root_ca.crt
          subPath: root_ca.crt
        {{- end }}
      {{- if .Values.traefik.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.traefik.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.traefik.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.traefik.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: persistent-volume
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.traefik.customRootCA }}
    - name: root_ca.crt
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec
        items:
          - key: root_ca.crt
            path: root_ca.crt
    {{- end }}
    {{- if .Values.traefik.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.traefik.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.deployKind }}
  {{- end }}
{{- end -}}