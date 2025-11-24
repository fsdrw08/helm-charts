{{- define "consul.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.consul.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.consul.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.consul.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.consul.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: consul
    {{- if .Values.consul.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consul.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.consul.hostNetwork }}
  {{- if .Values.consul.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.consul.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.consul.dnsPolicy }}
  dnsPolicy: {{ .Values.consul.dnsPolicy | quote }}
  {{- end }}
  {{- include "consul.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.consul.automountServiceAccountToken }}
  {{- if .Values.consul.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.consul.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.consul.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.consul.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.consul.podAffinityPreset "component" "consul" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.consul.podAntiAffinityPreset "component" "consul" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.consul.nodeAffinityPreset.type "key" .Values.consul.nodeAffinityPreset.key "values" .Values.consul.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.consul.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.consul.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.consul.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.consul.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.consul.priorityClassName }}
  priorityClassName: {{ .Values.consul.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.consul.schedulerName }}
  schedulerName: {{ .Values.consul.schedulerName }}
  {{- end }}
  {{- if .Values.consul.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.consul.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.consul.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.consul.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.consul.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.consul.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "consul.defaultInitContainers.volumePermissions" (dict "context" . "component" "consul") | nindent 4 }}
    {{- end }}
    {{- if .Values.consul.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consul.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: agent
      image: {{ template "consul.image" . }}
      imagePullPolicy: {{ .Values.consul.image.pullPolicy | quote }}
      {{- if .Values.consul.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.consul.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.consul.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.consul.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.consul.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.consul.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.consul.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.consul.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.consul.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.consul.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.consul.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.consul.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.consul.resources }}
      resources: {{- toYaml .Values.consul.resources | nindent 8 }}
      {{- else if ne .Values.consul.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.consul.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.consul.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.consul.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consul.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.consul.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consul.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consul.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.consul.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consul.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.consul.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.consul.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.consul.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.consul.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.consul.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.consul.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /consul/config
        {{- if .Values.consul.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.consul.secret.tls.mountPath }}
        {{- end }}
        {{- if .Values.consul.secret.others.contents }}
        - name: secret-others
          mountPath: {{ .Values.consul.secret.others.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.consul.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.consul.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.consul.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.consul.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.consul.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{- if .Values.consul.secret.others.contents }}
    - name: secret-others
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-others
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.consul.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.consul.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.consul.pod.enabled }}
  restartPolicy: {{ .Values.consul.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}