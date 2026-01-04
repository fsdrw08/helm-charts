{{- define "redis.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.redis.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.redis.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.redis.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.redis.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: redis
    {{- if .Values.redis.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redis.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.redis.hostNetwork }}
  {{- if .Values.redis.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.redis.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.redis.dnsPolicy }}
  dnsPolicy: {{ .Values.redis.dnsPolicy | quote }}
  {{- end }}
  {{- include "redis.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.redis.automountServiceAccountToken }}
  {{- if .Values.redis.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.redis.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redis.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.redis.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.redis.podAffinityPreset "component" "redis" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.redis.podAntiAffinityPreset "component" "redis" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.redis.nodeAffinityPreset.type "key" .Values.redis.nodeAffinityPreset.key "values" .Values.redis.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.redis.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.redis.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redis.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.redis.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redis.priorityClassName }}
  priorityClassName: {{ .Values.redis.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.redis.schedulerName }}
  schedulerName: {{ .Values.redis.schedulerName }}
  {{- end }}
  {{- if .Values.redis.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.redis.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redis.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.redis.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.redis.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.redis.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "redis.defaultInitContainers.volumePermissions" (dict "context" . "component" "redis") | nindent 4 }}
    {{- end }}
    {{- if .Values.redis.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redis.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "redis.image" . }}
      imagePullPolicy: {{ .Values.redis.image.pullPolicy | quote }}
      {{- if .Values.redis.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.redis.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.redis.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.redis.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.redis.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.redis.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.redis.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.redis.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redis.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.redis.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.redis.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redis.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.redis.resources }}
      resources: {{- toYaml .Values.redis.resources | nindent 8 }}
      {{- else if ne .Values.redis.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.redis.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.redis.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.redis.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redis.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redis.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redis.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redis.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redis.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redis.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redis.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redis.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.redis.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redis.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.redis.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.redis.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/redis
        {{- if .Values.redis.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.redis.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.redis.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.redis.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.redis.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.redis.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.redis.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redis.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.redis.pod.enabled }}
  restartPolicy: {{ .Values.redis.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}