{{- define "exporter.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.exporter.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.exporter.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.exporter.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: prometheus-blackbox-exporter
    {{- if .Values.exporter.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.exporter.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.exporter.hostNetwork }}
  {{- if .Values.exporter.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.exporter.dnsPolicy }}
  dnsPolicy: {{ .Values.exporter.dnsPolicy | quote }}
  {{- end }}
  {{- include "exporter.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.exporter.automountServiceAccountToken }}
  {{- if .Values.exporter.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.exporter.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.exporter.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.exporter.podAffinityPreset "component" "prometheus-blackbox-exporter" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.exporter.podAntiAffinityPreset "component" "prometheus-blackbox-exporter" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.exporter.nodeAffinityPreset.type "key" .Values.exporter.nodeAffinityPreset.key "values" .Values.exporter.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.exporter.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.exporter.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.exporter.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.exporter.priorityClassName }}
  priorityClassName: {{ .Values.exporter.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.exporter.schedulerName }}
  schedulerName: {{ .Values.exporter.schedulerName }}
  {{- end }}
  {{- if .Values.exporter.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.exporter.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.exporter.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.exporter.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.exporter.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "exporter.defaultInitContainers.volumePermissions" (dict "context" . "component" "exporter") | nindent 4 }}
    {{- end }}
    {{- if .Values.exporter.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.exporter.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: workload
      image: {{ template "exporter.image" . }}
      imagePullPolicy: {{ .Values.exporter.image.pullPolicy | quote }}
      {{- if .Values.exporter.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.exporter.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.exporter.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.exporter.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.exporter.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.exporter.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.exporter.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.exporter.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.exporter.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.exporter.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.exporter.resources }}
      resources: {{- toYaml .Values.exporter.resources | nindent 8 }}
      {{- else if ne .Values.exporter.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.exporter.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.exporter.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.exporter.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.exporter.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.exporter.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.exporter.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.exporter.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.exporter.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.exporter.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.exporter.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.exporter.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: {{ .Values.exporter.flags.config.file }}
          subPath: {{ base .Values.exporter.flags.config.file }}
        {{- if and .Values.exporter.configFiles.web .Values.exporter.flags.web.config.file }}
        - name: config-web
          mountPath: {{ .Values.exporter.flags.web.config.file }}
          subPath: {{ base .Values.exporter.flags.web.config.file }}
        {{- end }}
        {{- if .Values.exporter.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.exporter.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.exporter.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.exporter.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.exporter.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.exporter.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
        items:
          - key: config.yml
            path: {{ base .Values.exporter.flags.config.file }}
    {{- if and .Values.exporter.configFiles.web .Values.exporter.flags.web.config.file }}
    - name: config-web
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
        items:
          - key: web.yml
            path: {{ base .Values.exporter.flags.web.config.file }}
    {{- end }}
    {{- if .Values.exporter.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.exporter.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.exporter.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.exporter.pod.enabled }}
  restartPolicy: {{ .Values.exporter.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}