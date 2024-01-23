{{- define "jenkins.podTemplate" -}}
metadata:
  {{- if eq .Values.instanceKind "Pod" }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.controller.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.controller.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: jenkins-controller
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
    {{- if and .Values.volumePermissions.enabled .Values.persistence.enabled .Values.controller.containerSecurityContext.enabled}}
    - name: volume-permissions
      image: {{ include "jenkins.volumePermissions.image" . }}
      imagePullPolicy: {{ .Values.volumePermissions.image.pullPolicy | quote }}
      command:
        - /bin/bash
        - -ec
        - |
          chown -R {{ .Values.controller.containerSecurityContext.runAsUser }}:{{ .Values.controller.containerSecurityContext.runAsGroup }} {{ .Values.controller.jenkinsHome }}
      securityContext: {{- include "common.tplvalues.render" (dict "value" .Values.volumePermissions.containerSecurityContext "context" $) | nindent 8 }}
      {{- if .Values.volumePermissions.resources }}
      resources: {{- toYaml .Values.volumePermissions.resources | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: jenkins-home
          mountPath: {{ .Values.controller.jenkinsHome }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
    {{- end }}
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
      {{- end }}
      volumeMounts:
        - name: jenkins-home
          mountPath: {{ .Values.controller.jenkinsHome }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        - name: jenkins-config
          mountPath: /var/jenkins_config
        {{- if .Values.controller.installPlugins }}
        {{- if .Values.controller.overwritePluginsFromImage }}
        - name: plugins-loading
          mountPath: {{ .Values.controller.jenkinsRef }}/plugins
        {{- end }}
        - name: plugins-storage
          mountPath: /var/jenkins_plugins
        - name: tmp-volume
          mountPath: /tmp
        {{- end }}
        {{- if or .Values.controller.initScripts }}
        - name: init-scripts
          mountPath: {{ .Values.controller.jenkinsHome }}/init.groovy.d
        {{- end }}
        {{- if and .Values.controller.httpsKeyStore.enable }}
        - name: jenkins-https-keystore
          mountPath: {{ .Values.controller.httpsKeyStore.path }}
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
      env:
        {{- if .Values.controller.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.controller.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
        {{- if or .Values.controller.additionalSecrets .Values.controller.adminSecret }}
        # https://github.com/jenkinsci/configuration-as-code-plugin/blob/810dc950b514b9f3542defa22fc7e36eb077c18f/demos/kubernetes-secrets/README.md
        # With the help of SECRETS environment variable
        # we point Jenkins Configuration as Code plugin the location of the secrets
        # JCasC read the config yaml, find the var key(e.g. pattern with ${xxx}),
        # then go to the dir set in env var $SECRETS,
        # find related var key files content as key value
        - name: SECRETS
          value: /run/secrets/additional
        {{- end }}
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        {{- if and .Values.controller.JCasC.enabled .Values.controller.JCasC.autoReload.enabled }}
        - name: CASC_RELOAD_TOKEN 
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        {{- end }}
        - name: JAVA_OPTS
          value: >-
            {{- default "" .Values.controller.javaOpts }}
        - name: JENKINS_OPTS
          value: >-
            {{- if .Values.controller.jenkinsUriPrefix }}--prefix={{ .Values.controller.jenkinsUriPrefix }} {{ end }}
            --webroot=/var/jenkins_cache/war
            {{- default "" .Values.controller.jenkinsOpts}}
        - name: JENKINS_SLAVE_AGENT_PORT
          value: "{{ .Values.controller.agentListenerPort }}"
        {{- if .Values.controller.httpsKeyStore.enable }}
        - name: JENKINS_HTTPS_KEYSTORE_PASSWORD
          value: {{ .Values.controller.httpsKeyStore.password }}
        {{- end }}
        - name: CASC_JENKINS_CONFIG
          value: >-
            {{ printf "%s/casc_configs" (.Values.controller.jenkinsHome) }}
            {{- if .Values.controller.JCasC.configUrls }},{{ join "," .Values.controller.JCasC.configUrls }}{{- end }}
      envFrom:
        {{- if .Values.controller.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.controller.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.controller.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.controller.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.controller.resources }}
      resources: {{- toYaml .Values.controller.resources | nindent 8 }}
      {{- end }}
      {{/*
      {{- if .Values.controller.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.controller.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      */}}
      ports:
        {{- if .Values.controller.exposeHttpToHost }}
        - name: http
          {{- if .Values.controller.httpsKeyStore.enable }}
          containerPort: {{.Values.controller.httpsKeyStore.httpPort}}
          hostPort: {{.Values.controller.hostHttpPort}}
          {{- else }}
          containerPort: {{.Values.controller.targetPort}}
          hostPort: {{.Values.controller.hostTargetPort}}
          {{- end }}
        {{- end }}
        {{- if .Values.controller.agentListener.enabled }}
        - name: agent-listener
          containerPort: {{ .Values.controller.agentListener.port }}
          {{- if .Values.controller.agentListener.hostPort }}
          hostPort: {{ .Values.controller.agentListener.hostPort }}
          {{- end }}
        {{- end }}
        {{- if .Values.controller.jmxPort }}
        - name: jmx
          containerPort: {{ .Values.controller.jmxPort }}
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
        {{- if and .Values.controller.httpsKeyStore.enable }}
        - name: jenkins-https-keystore
          mountPath: {{ .Values.controller.httpsKeyStore.path }}
        {{- end }}
        - name: jenkins-home
          mountPath: {{ .Values.controller.jenkinsHome }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
        - name: jenkins-config
          mountPath: /var/jenkins_config
          readOnly: true
        {{- if .Values.controller.JCasC.enabled }}
        - name: jenkins-config-jcasc
          mountPath: {{ .Values.controller.jenkinsHome }}/casc_configs
        {{- end }}
        {{- if .Values.controller.installPlugins }}
        - name: plugins-storage
          mountPath: {{ .Values.controller.jenkinsRef }}/plugins/
          readOnly: false
        {{- end }}
        {{- if .Values.controller.initScripts }}
        - name: init-scripts
          mountPath: {{ .Values.controller.jenkinsHome }}/init.groovy.d
        {{- end }}
        {{- if or .Values.controller.additionalSecrets .Values.controller.adminSecret }}
        - name: jenkins-secrets
          mountPath: /run/secrets/additional
          readOnly: true
        {{- end }}
        - name: jenkins-cache
          mountPath: /var/jenkins_cache
        - name: tmp-volume
          mountPath: /tmp
      {{- if .Values.controller.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.controller.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if and .Values.controller.JCasC.enabled .Values.controller.JCasC.autoReload.enabled }}
    - name: reload-JCasC
      image: {{ include "common.images.image" (dict "imageRoot" .Values.controller.JCasC.autoReload.image "global" .Values.global) }}
      imagePullPolicy: {{ .Values.controller.JCasC.autoReload.image.pullPolicy | quote }}
      {{- if .Values.controller.JCasC.autoReload.containerSecurityContext.enabled }}
      securityContext: {{- omit .Values.controller.JCasC.autoReload.containerSecurityContext "enabled" | toYaml | nindent 8 }}
      {{- end }}
      env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
      {{- if .Values.controller.JCasC.autoReload.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .controller.JCasC.autoReload.command "context" $) | nindent 8 }}
      {{- else }}
      command:
        - /bin/sh
        - -c
      {{- end }}
      {{- if .Values.controller.JCasC.autoReload.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.controller.JCasC.autoReload.args "context" $) | nindent 12 }}
      {{- else }}
          # while true; do
          #   inotifywait -r --event modify create delete {{ .Values.controller.jenkinsHome }}/casc_configs;
          #   wget --post-data casc-reload-token=$(POD_NAME) http://localhost:{{.Values.controller.targetPort}}/reload-configuration-as-code/
          # done
      args:
        - |-
          inotifywait -mr -e modify {{ .Values.controller.jenkinsHome }}/casc_configs | while read MODIFY
          do
            wget --post-data casc-reload-token=$POD_NAME http://localhost:{{.Values.controller.targetPort}}/reload-configuration-as-code/
          done
      {{- end }}
      volumeMounts:
        - name: jenkins-config-jcasc
          mountPath: {{ .Values.controller.jenkinsHome }}/casc_configs
    {{- end }}
    {{- if .Values.controller.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.controller.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- /* plugins loading zone aka plugins */}}
    {{- if .Values.controller.installPlugins }}
    {{- if .Values.controller.overwritePluginsFromImage }}
    - name: plugins-loading
      persistentVolumeClaim:
        claimName: {{ include "common.names.fullname" . }}-pvc-plugins-loading
    {{- end }}
    {{- end }}
    {{- /* init-scripts */}}
    {{- if .Values.controller.initScripts }}
    - name: init-scripts
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-init-scripts
    {{- end }}
    {{- /* jenkins-config */}}
    - name: jenkins-config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- /* jenkins-config-jcasc */}}
    {{- if .Values.controller.JCasC.enabled }}
    - name: jenkins-config-jcasc
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-jcasc
    {{- end }}
    {{- /* plugins-storage aka plugin-dir */}}
    {{- if .Values.controller.installPlugins }}
    - name: plugins-storage
      persistentVolumeClaim:
        claimName: {{ include "common.names.fullname" . }}-pvc-plugins-storage
    {{- end }}
    {{- /* jenkins-secrets */}}
    - name: jenkins-secrets
      secret:
        secretName: {{ include "common.names.fullname" . }}-sec
    {{- /* jenkins-cache */}}
    - name: jenkins-cache
      emptyDir: {}
    {{- /* jenkins-home */}}
    - name: jenkins-home
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc-home" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    - name: tmp-volume
      emptyDir: {}
    {{- if and .Values.controller.httpsKeyStore.enable }}
    - name: jenkins-https-keystore
      secret:
        secretName: {{ template "jenkins.fullname" . }}-sec-https-jks
        items:
        - key: jenkins-jks-file
          path: {{ .Values.controller.httpsKeyStore.fileName }}
    {{- end }}
    {{- if .Values.controller.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.controller.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if eq .Values.instanceKind "Deployment" }}
  restartPolicy: Always
  {{- else -}}
  restartPolicy: {{ .Values.controller.podRestartPolicy }}
  {{- end }}
{{- end }}
