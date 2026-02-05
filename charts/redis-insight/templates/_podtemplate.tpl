{{- define "redisInsight.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.redisInsight.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.redisInsight.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.redisInsight.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: redis-insight
    {{- if .Values.redisInsight.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.redisInsight.hostNetwork }}
  {{- if .Values.redisInsight.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.redisInsight.dnsPolicy }}
  dnsPolicy: {{ .Values.redisInsight.dnsPolicy | quote }}
  {{- end }}
  {{- include "redisInsight.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.redisInsight.automountServiceAccountToken }}
  {{- if .Values.redisInsight.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redisInsight.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.redisInsight.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.redisInsight.podAffinityPreset "component" "redis-insight" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.redisInsight.podAntiAffinityPreset "component" "redis-insight" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.redisInsight.nodeAffinityPreset.type "key" .Values.redisInsight.nodeAffinityPreset.key "values" .Values.redisInsight.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.redisInsight.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.redisInsight.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redisInsight.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redisInsight.priorityClassName }}
  priorityClassName: {{ .Values.redisInsight.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.redisInsight.schedulerName }}
  schedulerName: {{ .Values.redisInsight.schedulerName }}
  {{- end }}
  {{- if .Values.redisInsight.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.redisInsight.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.redisInsight.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.redisInsight.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.redisInsight.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "redisInsight.defaultInitContainers.volumePermissions" (dict "context" . "component" "redisInsight") | nindent 4 }}
    {{- end }}
    {{- if .Values.redisInsight.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "redisInsight.image" . }}
      imagePullPolicy: {{ .Values.redisInsight.image.pullPolicy | quote }}
      {{- if .Values.redisInsight.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.redisInsight.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.redisInsight.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.redisInsight.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        - configMapRef:
            name: {{ template "common.names.fullname" . }}-cm-envvar
        {{- if .Values.redisInsight.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.redisInsight.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.redisInsight.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.redisInsight.resources }}
      resources: {{- toYaml .Values.redisInsight.resources | nindent 8 }}
      {{- else if ne .Values.redisInsight.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.redisInsight.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.redisInsight.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redisInsight.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redisInsight.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.redisInsight.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redisInsight.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.redisInsight.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.redisInsight.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.redisInsight.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.redisInsight.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $)  }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.redisInsight.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.redisInsight.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.redisInsight.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.redisInsight.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.redisInsight.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.redisInsight.pod.enabled }}
  restartPolicy: {{ .Values.redisInsight.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}