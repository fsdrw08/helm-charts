{{- define "jenkins.podTemplate" -}}
metadata:
  {{- if eq .Values.instanceKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.controller.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.controller.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: server
    {{- if .Values.controller.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.controller.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  {{- include "jenkins.imagePullSecrets" . | nindent 2 }}
  {{- if .Values.controller.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.controller.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.controller.podSecurityContext.enabled -}}
  securityContext: {{- omit .Values.controller.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  initContainers:
    - name: provision
      image: {{ template "jenkins.image" . }}
      imagePullPolicy: {{ .Values.controller.image.pullPolicy }}
      {{- if .Values.controller.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.controller.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      command:
        - sh
        - /var/jenkins_config/apply_config.sh
      env:
      {{- if .Values.controller.provision.extraEnvVars }}
      {{- include "common.tplvalues.render" (dict "value" .Values.controller.provision.extraEnvVars "context" $) | nindent 8 }}
      {{- end }}
      envFrom:
      {{- if .Values.controller.provision.extraEnvVarsFrom }}
      {{- include "common.tplvalues.render" (dict "value" .Values.controller.provision.extraEnvVarsFrom "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.controller.provision.resources }}
      resources: {{- toYaml .Values.controller.provision.resources | nindent 8 }}
      {{- else }}
      resources: {{- toYaml .Values.controller.resources | indent 8 }}
      {{- end }}
      volumeMounts:
        - name: jenkins-home
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        - name: jenkins-config
          mountPath: /var/jenkins_config
        {{- if .Values.controller.installPlugins }}
        {{- if .Values.controller.overwritePluginsFromImage }}
        - name: plugins
          mountPath: {{ .Values.controller.jenkinsRef }}/plugins
        {{- end }}
        - name: plugin-dir
          mountPath: /var/jenkins_plugins
        - name: tmp-volume
          mountPath: /tmp
        {{- end }}
        {{- if or .Values.controller.initScripts .Values.controller.initConfigMap }}
        - name: init-scripts
          mountPath: {{ .Values.controller.jenkinsHome }}/init.groovy.d
        {{- end }}
        {{- if and .Values.controller.httpsKeyStore.enable (not .Values.controller.httpsKeyStore.disableSecretMount) }}
        - name: jenkins-https-keystore
          mountPath: {{ .Values.controller.httpsKeyStore.path }}
        {{- end }}
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled }}
    - name: volume-permissions
      image: {{ include "jenkins.volumePermissions.image" . }}
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
    {{- if .Values.controller.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.controller.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: controller
      image: {{ template "jenkins.image" . }}
      imagePullPolicy: {{ .Values.controller.image.pullPolicy }}
      {{- if .Values.controller.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.controller.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      {{- if .Values.controller.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.controller.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.controller.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.controller.args "context" $) | nindent 8 }}
      {{- else if .Values.controller.httpsKeyStore.enable }}
      args: 
        - --httpPort={{.Values.controller.httpsKeyStore.httpPort}}
        - --httpsPort={{.Values.controller.targetPort}}
        - --httpsKeyStore={{ .Values.controller.httpsKeyStore.path }}/{{ .Values.controller.httpsKeyStore.fileName }}
        - --httpsKeyStorePassword=$(JENKINS_HTTPS_KEYSTORE_PASSWORD)" ]
      {{- else }}
      args: 
        - --httpPort={{.Values.controller.targetPort}}
      {{- end }}
      {{- end }}
      env:
        {{- if .Values.controller.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.controller.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.controller.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.controller.extraEnvVarsCM "context" $) }}
        {{- end }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}
        {{- if .Values.controller.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.controller.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.controller.resources }}
      resources: {{- toYaml .Values.controller.resources | nindent 8 }}
      {{- end }}
      {{- if .Values.controller.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.controller.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if .Values.controller.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.controller.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.controller.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.controller.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.controller.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.controller.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.controller.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.controller.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.controller.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.controller.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.controller.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.controller.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: jenkins-home
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.controller.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.controller.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.controller.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.controller.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: jenkins-home
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default (include "common.names.fullname" .) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.controller.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.controller.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.instanceKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.instanceKind }}
  {{- end }}
{{- end -}}