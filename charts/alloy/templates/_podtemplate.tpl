{{- define "alloy.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.alloy.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.alloy.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.alloy.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: alloy
    {{- if .Values.alloy.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alloy.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.alloy.hostNetwork }}
  {{- if .Values.alloy.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.alloy.dnsPolicy }}
  dnsPolicy: {{ .Values.alloy.dnsPolicy | quote }}
  {{- end }}
  {{- include "alloy.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.alloy.automountServiceAccountToken }}
  {{- if .Values.alloy.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.alloy.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.alloy.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.alloy.podAffinityPreset "component" "alloy" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.alloy.podAntiAffinityPreset "component" "alloy" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.alloy.nodeAffinityPreset.type "key" .Values.alloy.nodeAffinityPreset.key "values" .Values.alloy.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.alloy.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.alloy.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.alloy.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.alloy.priorityClassName }}
  priorityClassName: {{ .Values.alloy.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.alloy.schedulerName }}
  schedulerName: {{ .Values.alloy.schedulerName }}
  {{- end }}
  {{- if .Values.alloy.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.alloy.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.alloy.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.alloy.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.alloy.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "alloy.defaultInitContainers.volumePermissions" (dict "context" . "component" "alloy") | nindent 4 }}
    {{- end }}
    {{- if .Values.alloy.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alloy.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: collector
      image: {{ template "alloy.image" . }}
      imagePullPolicy: {{ .Values.alloy.image.pullPolicy | quote }}
      {{- if .Values.alloy.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.alloy.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.alloy.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.alloy.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.alloy.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.alloy.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.alloy.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.alloy.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.alloy.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.alloy.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.alloy.resources }}
      resources: {{- toYaml .Values.alloy.resources | nindent 8 }}
      {{- else if ne .Values.alloy.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.alloy.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.alloy.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.alloy.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alloy.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.alloy.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alloy.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.alloy.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.alloy.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.alloy.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.alloy.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.alloy.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/alloy/config.alloy
          subPath: config.alloy
        {{- if .Values.alloy.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.alloy.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $)  }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.alloy.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.alloy.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.alloy.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.alloy.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.alloy.secret.tls.contents }}
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
    {{- if .Values.alloy.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.alloy.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.alloy.pod.enabled }}
  restartPolicy: {{ .Values.alloy.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}