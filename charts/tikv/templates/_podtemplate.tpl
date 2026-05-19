{{- define "tikv.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.tikv.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.tikv.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.tikv.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: tikv
    {{- if .Values.tikv.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.tikv.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.tikv.hostNetwork }}
  {{- if .Values.tikv.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.tikv.dnsPolicy }}
  dnsPolicy: {{ .Values.tikv.dnsPolicy | quote }}
  {{- end }}
  {{- include "tikv.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.tikv.automountServiceAccountToken }}
  {{- if .Values.tikv.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.tikv.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.tikv.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.tikv.podAffinityPreset "component" "tikv" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.tikv.podAntiAffinityPreset "component" "tikv" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.tikv.nodeAffinityPreset.type "key" .Values.tikv.nodeAffinityPreset.key "values" .Values.tikv.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.tikv.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.tikv.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.tikv.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.tikv.priorityClassName }}
  priorityClassName: {{ .Values.tikv.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.tikv.schedulerName }}
  schedulerName: {{ .Values.tikv.schedulerName }}
  {{- end }}
  {{- if .Values.tikv.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.tikv.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.tikv.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.tikv.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.tikv.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "tikv.defaultInitContainers.volumePermissions" (dict "context" . "component" "tikv") | nindent 4 }}
    {{- end }}
    {{- if .Values.tikv.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.tikv.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "tikv.image" . }}
      imagePullPolicy: {{ .Values.tikv.image.pullPolicy | quote }}
      {{- if .Values.tikv.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.tikv.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.tikv.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.tikv.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.tikv.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.tikv.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.tikv.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.tikv.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.tikv.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.tikv.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.tikv.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.tikv.resources }}
      resources: {{- toYaml .Values.tikv.resources | nindent 8 }}
      {{- else if ne .Values.tikv.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.tikv.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.tikv.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.tikv.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.tikv.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.tikv.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.tikv.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.tikv.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.tikv.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.tikv.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.tikv.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.tikv.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.tikv.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.tikv.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/tikv/config.toml
          subPath: config.toml
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.tikv.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.tikv.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.tikv.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.tikv.sidecars "context" $) | nindent 4 }}
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
    {{- if .Values.tikv.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.tikv.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.tikv.pod.enabled }}
  restartPolicy: {{ .Values.tikv.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}