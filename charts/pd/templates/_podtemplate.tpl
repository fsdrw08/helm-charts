{{- define "pd.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.pd.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.pd.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.pd.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.pd.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: pd
    {{- if .Values.pd.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.pd.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.pd.hostNetwork }}
  {{- if .Values.pd.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.pd.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.pd.dnsPolicy }}
  dnsPolicy: {{ .Values.pd.dnsPolicy | quote }}
  {{- end }}
  {{- include "pd.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.pd.automountServiceAccountToken }}
  {{- if .Values.pd.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.pd.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.pd.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.pd.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.pd.podAffinityPreset "component" "pd" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.pd.podAntiAffinityPreset "component" "pd" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.pd.nodeAffinityPreset.type "key" .Values.pd.nodeAffinityPreset.key "values" .Values.pd.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.pd.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.pd.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.pd.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.pd.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.pd.priorityClassName }}
  priorityClassName: {{ .Values.pd.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.pd.schedulerName }}
  schedulerName: {{ .Values.pd.schedulerName }}
  {{- end }}
  {{- if .Values.pd.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.pd.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.pd.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.pd.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.pd.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.pd.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "pd.defaultInitContainers.volumePermissions" (dict "context" . "component" "pd") | nindent 4 }}
    {{- end }}
    {{- if .Values.pd.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.pd.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "pd.image" . }}
      imagePullPolicy: {{ .Values.pd.image.pullPolicy | quote }}
      {{- if .Values.pd.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.pd.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.pd.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.pd.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.pd.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.pd.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.pd.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.pd.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.pd.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.pd.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.pd.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.pd.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.pd.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.pd.resources }}
      resources: {{- toYaml .Values.pd.resources | nindent 8 }}
      {{- else if ne .Values.pd.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.pd.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.pd.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.pd.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.pd.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.pd.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.pd.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.pd.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.pd.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.pd.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.pd.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.pd.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.pd.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.pd.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.pd.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.pd.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.pd.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.pd.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/pd/config.toml
          subPath: config.toml
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.pd.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.pd.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.pd.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.pd.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
        items:
          - key: config.toml
            path: config.toml
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.pd.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.pd.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.pd.pod.enabled }}
  restartPolicy: {{ .Values.pd.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}