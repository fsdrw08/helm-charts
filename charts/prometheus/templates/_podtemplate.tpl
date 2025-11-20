{{- define "prometheus.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.prometheus.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.prometheus.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.prometheus.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: prometheus
    {{- if .Values.prometheus.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.prometheus.hostNetwork }}
  {{- if .Values.prometheus.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.prometheus.dnsPolicy }}
  dnsPolicy: {{ .Values.prometheus.dnsPolicy | quote }}
  {{- end }}
  {{- include "prometheus.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.prometheus.automountServiceAccountToken }}
  {{- if .Values.prometheus.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.prometheus.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.prometheus.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.prometheus.podAffinityPreset "component" "prometheus" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.prometheus.podAntiAffinityPreset "component" "prometheus" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.prometheus.nodeAffinityPreset.type "key" .Values.prometheus.nodeAffinityPreset.key "values" .Values.prometheus.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.prometheus.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.prometheus.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.prometheus.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.prometheus.priorityClassName }}
  priorityClassName: {{ .Values.prometheus.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.prometheus.schedulerName }}
  schedulerName: {{ .Values.prometheus.schedulerName }}
  {{- end }}
  {{- if .Values.prometheus.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.prometheus.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.prometheus.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.prometheus.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.prometheus.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "%%TEMPLATE_NAME%%.defaultInitContainers.volumePermissions" (dict "context" . "component" "prometheus") | nindent 4 }}
    {{- end }}
    {{- if .Values.prometheus.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "prometheus.image" . }}
      imagePullPolicy: {{ .Values.prometheus.image.pullPolicy | quote }}
      {{- if .Values.prometheus.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.prometheus.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.prometheus.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.prometheus.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.prometheus.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.prometheus.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.prometheus.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.prometheus.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.prometheus.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.prometheus.resources }}
      resources: {{- toYaml .Values.prometheus.resources | nindent 8 }}
      {{- else if ne .Values.prometheus.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.prometheus.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.prometheus.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheus.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheus.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheus.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheus.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.prometheus.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.prometheus.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.prometheus.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.prometheus.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: {{ .Values.prometheus.flags.config.file }}
          subPath: {{ base .Values.prometheus.flags.config.file }}
        {{- if .Values.prometheus.flags.web.config.file }}
        - name: config-web
          mountPath: {{ .Values.prometheus.flags.web.config.file }}
          subPath: {{ base .Values.prometheus.flags.web.config.file }}
        {{- end }}
        {{- if .Values.prometheus.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.prometheus.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $) }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.prometheus.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.prometheus.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.prometheus.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.prometheus.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.prometheus.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if .Values.prometheus.pod.enabled }}
  restartPolicy: {{ .Values.prometheus.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}