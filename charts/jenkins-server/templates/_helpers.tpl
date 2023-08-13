{{/*
Return the proper jenkinsController image name
*/}}
{{- define "jenkins.image" -}}
{{ include "common.images.image" (dict "imageRoot" .Values.controller.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "jenkins.volumePermissions.image" -}}
{{- include "common.images.image" ( dict "imageRoot" .Values.volumePermissions.image "global" .Values.global ) -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "jenkins.imagePullSecrets" -}}
{{- include "common.images.pullSecrets" (dict "images" (list .Values.controller.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "jenkins.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message.
*/}}
{{- define "jenkins.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "jenkins.validateValues.foo" .) -}}
{{- $messages := append $messages (include "jenkins.validateValues.bar" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message -}}
{{- end -}}
{{- end -}}


{{- define "jenkins.casc.security" -}}
security:
{{- with .Values.controller.JCasC }}
{{- if .security }}
  {{- .security | toYaml | nindent 2 }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "jenkins.casc.defaults" -}}
jenkins:
  {{- $configScripts := toYaml .Values.controller.JCasC.configScripts }}
  {{- if and (.Values.controller.JCasC.authorizationStrategy) (not (contains "authorizationStrategy:" $configScripts)) }}
  authorizationStrategy:
    {{- tpl .Values.controller.JCasC.authorizationStrategy . | nindent 4 }}
  {{- end }}
  {{- if and (.Values.controller.JCasC.securityRealm) (not (contains "securityRealm:" $configScripts)) }}
  securityRealm:
    {{- tpl .Values.controller.JCasC.securityRealm . | nindent 4 }}
  {{- end }}
  disableRememberMe: {{ .Values.controller.disableRememberMe }}
  {{- if .Values.controller.legacyRemotingSecurityEnabled }}
  remotingSecurity:
    enabled: true
  {{- end }}
  mode: {{ .Values.controller.executorMode }}
  numExecutors: {{ .Values.controller.numExecutors }}
  {{- if not (kindIs "invalid" .Values.controller.customJenkinsLabels) }}
  labelString: "{{ join " " .Values.controller.customJenkinsLabels }}"
  {{- end }}
  {{- if .Values.controller.projectNamingStrategy }}
  {{- if kindIs "string" .Values.controller.projectNamingStrategy }}
  projectNamingStrategy: "{{ .Values.controller.projectNamingStrategy }}"
  {{- else }}
  projectNamingStrategy:
    {{- toYaml .Values.controller.projectNamingStrategy | nindent 4 }}
  {{- end }}
  {{- end }}
  markupFormatter:
    {{- if .Values.controller.enableRawHtmlMarkupFormatter }}
    rawHtml:
      disableSyntaxHighlighting: true
    {{- else }}
    {{- toYaml .Values.controller.markupFormatter | nindent 4 }}
    {{- end }}
  clouds:
  {{- /*
  - kubernetes:
      containerCapStr: "{{ .Values.agent.containerCap }}"
      {{- if .Values.agent.jnlpregistry }}
      jnlpregistry: "{{ .Values.agent.jnlpregistry }}"
      {{- end }}
      defaultsProviderTemplate: "{{ .Values.agent.defaultsProviderTemplate }}"
      connectTimeout: "{{ .Values.agent.kubernetesConnectTimeout }}"
      readTimeout: "{{ .Values.agent.kubernetesReadTimeout }}"
      {{- if .Values.agent.directConnection }}
      directConnection: true
      {{- else }}
      {{- if .Values.agent.jenkinsUrl }}
      jenkinsUrl: "{{ tpl .Values.agent.jenkinsUrl . }}"
      {{- else }}
      jenkinsUrl: "http://{{ template "jenkins.fullname" . }}.{{ template "jenkins.namespace" . }}.svc.{{.Values.clusterZone}}:{{.Values.controller.servicePort}}{{ default "" .Values.controller.jenkinsUriPrefix }}"
      {{- end }}
      {{- if not .Values.agent.websocket }}
      {{- if .Values.agent.jenkinsTunnel }}
      jenkinsTunnel: "{{ tpl .Values.agent.jenkinsTunnel . }}"
      {{- else }}
      jenkinsTunnel: "{{ template "jenkins.fullname" . }}-agent.{{ template "jenkins.namespace" . }}.svc.{{.Values.clusterZone}}:{{ .Values.controller.agentListenerPort }}"
      {{- end }}
      {{- else }}
      webSocket: true
      {{- end }}
      {{- end }}
      maxRequestsPerHostStr: {{ .Values.agent.maxRequestsPerHostStr | quote }}
      name: "{{ .Values.controller.cloudName }}"
      namespace: "{{ template "jenkins.agent.namespace" . }}"
      serverUrl: "{{ .Values.kubernetesURL }}"
      {{- if .Values.agent.enabled }}
      podLabels:
      - key: "jenkins/{{ .Release.Name }}-{{ .Values.agent.componentName }}"
        value: "true"
      {{- range $key, $val := .Values.agent.podLabels }}
      - key: {{ $key | quote }}
        value: {{ $val | quote }}
      {{- end }}
      templates:
    {{- if not .Values.agent.disableDefaultAgent }}
      {{- include "jenkins.casc.podTemplate" . | nindent 8 }}
    {{- end }}
    {{- if .Values.additionalAgents }}
      {{- /* save .Values.agent */}}
  {{- /*
      {{- $agent := .Values.agent }}
      {{- range $name, $additionalAgent := .Values.additionalAgents }}
        {{- $additionalContainersEmpty := and (hasKey $additionalAgent "additionalContainers") (empty $additionalAgent.additionalContainers)  }}
        {{- /* merge original .Values.agent into additional agent to ensure it at least has the default values */}}
  {{- /*
        {{- $additionalAgent := merge $additionalAgent $agent }}
        {{- /* clear list of additional containers in case it is configured empty for this agent (merge might have overwritten that) */}}
  {{- /*
        {{- if $additionalContainersEmpty }}
        {{- $_ := set $additionalAgent "additionalContainers" list }}
        {{- end }}
        {{- /* set .Values.agent to $additionalAgent */}}
  {{- /*
        {{- $_ := set $.Values "agent" $additionalAgent }}
        {{- include "jenkins.casc.podTemplate" $ | nindent 8 }}
      {{- end }}
      {{- /* restore .Values.agent */}}
  {{- /*
      {{- $_ := set .Values "agent" $agent }}
    {{- end }}
      {{- if .Values.agent.podTemplates }}
        {{- range $key, $val := .Values.agent.podTemplates }}
          {{- tpl $val $ | nindent 8 }}
        {{- end }}
      {{- end }}
      {{- end }}
  */}}
{{- include "jenkins.casc.security" . }}
{{- if .Values.controller.scriptApproval }}
  scriptApproval:
    approvedSignatures:
{{- range $key, $val := .Values.controller.scriptApproval }}
    - "{{ $val }}"
{{- end }}
{{- end }}
unclassified:
  location:
    adminAddress: {{ default "" .Values.controller.jenkinsAdminEmail }}
    url: {{ .Values.controller.jenkinsUrl }}
{{- end -}}