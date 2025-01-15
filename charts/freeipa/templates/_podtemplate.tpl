{{- define "freeipa.podTemplate" -}}
metadata:
  {{- if eq .Values.deployKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.freeipa.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: freeIPA
    {{- if .Values.freeipa.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "freeipa.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.freeipa.hostAliases -}}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.hostAliases "context" $) | nindent 4 }}
  {{ end }}
  {{- if .Values.freeipa.hostName -}}
  hostname: {{ .Values.freeipa.hostName }}
  {{ end }}
  {{- if .Values.freeipa.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.freeipa.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end -}}
  initContainers:
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "freeipa.volumePermissions.image" . }}
      imagePullPolicy: {{ .Values.volumePermissions.image.pullPolicy | quote }}
      command:
        - chmod
        - -R
        - "777"
        - /dev/shm
      securityContext: {{- include "common.tplvalues.render" (dict "value" .Values.volumePermissions.containerSecurityContext "context" $) | nindent 8 }}
      {{- if .Values.volumePermissions.resources }}
      resources: {{- toYaml .Values.volumePermissions.resources | nindent 8 }}
      {{- else if ne .Values.volumePermissions.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.volumePermissions.resourcesPreset) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: dshm
          mountPath: /dev/shm
    {{- end }}
    {{- if .Values.freeipa.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: freeipa
      image: {{ template "freeipa.image" . }}
      imagePullPolicy: {{ .Values.freeipa.image.pullPolicy | quote }}
      {{- if .Values.freeipa.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.freeipa.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.freeipa.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.freeipa.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.freeipa.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.freeipa.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.freeipa.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.freeipa.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.freeipa.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.freeipa.resources }}
      resources: {{- toYaml .Values.freeipa.resources | nindent 8 }}
      {{- else if ne .Values.freeipa.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.freeipa.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.freeipa.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.freeipa.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.freeipa.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.freeipa.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.freeipa.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.freeipa.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.freeipa.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.freeipa.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.freeipa.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.freeipa.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- if .Values.persistence.mountPath }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        {{- end }}
        {{- if .Values.freeipa.serverInstallOptions }}
        - name: ipa-server-install-options
          mountPath: /data/ipa-server-install-options
          subPath: ipa-server-install-options
        {{- end }}
        - name: dshm
          mountPath: /dev/shm
        {{- if .Values.freeipa.extraVolumeMounts }}
        {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.extraVolumeMounts "context" $) | nindent 8 }}
        {{- end }}
    {{- if .Values.freeipa.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.freeipa.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.freeipa.serverInstallOptions }}
    - name: ipa-server-install-options
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec
        items:
          - key: ipa-server-install-options
            path: ipa-server-install-options
    {{- end }}
    - name: dshm
      emptyDir:
        medium: Memory
    {{- if .Values.freeipa.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.freeipa.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.freeipa.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{ if eq .Values.deployKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.deployKind }}
  {{- end }}
{{- end -}}