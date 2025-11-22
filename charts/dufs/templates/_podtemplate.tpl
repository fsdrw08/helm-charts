{{- define "dufs.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.dufs.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.dufs.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.dufs.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: dufs
    {{- if .Values.dufs.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dufs.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.dufs.hostNetwork }}
  {{- if .Values.dufs.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.dufs.dnsPolicy }}
  dnsPolicy: {{ .Values.dufs.dnsPolicy | quote }}
  {{- end }}
  {{- include "dufs.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.dufs.automountServiceAccountToken }}
  {{- if .Values.dufs.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dufs.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.dufs.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.dufs.podAffinityPreset "component" "dufs" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.dufs.podAntiAffinityPreset "component" "dufs" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.dufs.nodeAffinityPreset.type "key" .Values.dufs.nodeAffinityPreset.key "values" .Values.dufs.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.dufs.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.dufs.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dufs.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dufs.priorityClassName }}
  priorityClassName: {{ .Values.dufs.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.dufs.schedulerName }}
  schedulerName: {{ .Values.dufs.schedulerName }}
  {{- end }}
  {{- if .Values.dufs.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dufs.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.dufs.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.dufs.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.dufs.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "dufs.defaultInitContainers.volumePermissions" (dict "context" . "component" "dufs") | nindent 4 }}
    {{- end }}
    {{- if .Values.dufs.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dufs.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "dufs.image" . }}
      imagePullPolicy: {{ .Values.dufs.image.pullPolicy | quote }}
      {{- if .Values.dufs.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.dufs.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.dufs.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.dufs.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.dufs.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.dufs.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dufs.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.dufs.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.dufs.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dufs.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.dufs.resources }}
      resources: {{- toYaml .Values.dufs.resources | nindent 8 }}
      {{- else if ne .Values.dufs.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.dufs.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.dufs.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dufs.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dufs.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dufs.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dufs.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dufs.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.dufs.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dufs.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.dufs.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.dufs.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/dufs
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $) }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.dufs.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.dufs.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.dufs.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.dufs.sidecars "context" $) | nindent 4 }}
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
    {{- if .Values.dufs.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dufs.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.dufs.pod.enabled }}
  restartPolicy: {{ .Values.dufs.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}