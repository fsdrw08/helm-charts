{{- define "%%TEMPLATE_NAME%%.podTemplate" -}}
metadata:
  {{- if .Values.%%TEMPLATE_NAME%%.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: %%COMPONENT_NAME%%
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.%%MAIN_OBJECT_BLOCK%%.hostNetwork }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.dnsPolicy }}
  dnsPolicy: {{ .Values.%%MAIN_OBJECT_BLOCK%%.dnsPolicy | quote }}
  {{- end }}
  {{- include "%%TEMPLATE_NAME%%.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.%%MAIN_OBJECT_BLOCK%%.automountServiceAccountToken }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.%%MAIN_OBJECT_BLOCK%%.podAffinityPreset "component" "%%COMPONENT_NAME%%" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.%%MAIN_OBJECT_BLOCK%%.podAntiAffinityPreset "component" "%%COMPONENT_NAME%%" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.%%MAIN_OBJECT_BLOCK%%.nodeAffinityPreset.type "key" .Values.%%MAIN_OBJECT_BLOCK%%.nodeAffinityPreset.key "values" .Values.%%MAIN_OBJECT_BLOCK%%.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.priorityClassName }}
  priorityClassName: {{ .Values.%%MAIN_OBJECT_BLOCK%%.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.schedulerName }}
  schedulerName: {{ .Values.%%MAIN_OBJECT_BLOCK%%.schedulerName }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.%%MAIN_OBJECT_BLOCK%%.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.%%MAIN_OBJECT_BLOCK%%.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "%%TEMPLATE_NAME%%.defaultInitContainers.volumePermissions" (dict "context" . "component" "%%MAIN_OBJECT_BLOCK%%") | nindent 4 }}
    {{- end }}
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: %%MAIN_OBJECT_BLOCK%%
      image: {{ template "%%TEMPLATE_NAME%%.image" . }}
      imagePullPolicy: {{ .Values.%%MAIN_OBJECT_BLOCK%%.image.pullPolicy | quote }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.%%MAIN_OBJECT_BLOCK%%.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.%%MAIN_OBJECT_BLOCK%%.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.%%MAIN_OBJECT_BLOCK%%.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.resources }}
      resources: {{- toYaml .Values.%%MAIN_OBJECT_BLOCK%%.resources | nindent 8 }}
      {{- else if ne .Values.%%MAIN_OBJECT_BLOCK%%.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.%%MAIN_OBJECT_BLOCK%%.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.%%MAIN_OBJECT_BLOCK%%.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.%%MAIN_OBJECT_BLOCK%%.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.%%MAIN_OBJECT_BLOCK%%.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.%%MAIN_OBJECT_BLOCK%%.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.%%MAIN_OBJECT_BLOCK%%.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.%%MAIN_OBJECT_BLOCK%%.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.%%MAIN_OBJECT_BLOCK%%.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.%%MAIN_OBJECT_BLOCK%%.pod.enabled }}
  restartPolicy: {{ .Values.%%MAIN_OBJECT_BLOCK%%.pod.restartPolicy }}
  {{- else -}}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}