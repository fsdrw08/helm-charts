{{- define "coredns.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.coredns.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.coredns.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.coredns.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: coredns
    {{- if .Values.coredns.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.coredns.hostNetwork }}
  {{- if .Values.coredns.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.coredns.dnsPolicy }}
  dnsPolicy: {{ .Values.coredns.dnsPolicy | quote }}
  {{- end }}
  {{- include "coredns.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.coredns.automountServiceAccountToken }}
  {{- if .Values.coredns.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.coredns.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.coredns.podAffinityPreset "component" "coredns" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.coredns.podAntiAffinityPreset "component" "coredns" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.coredns.nodeAffinityPreset.type "key" .Values.coredns.nodeAffinityPreset.key "values" .Values.coredns.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.coredns.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.coredns.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.priorityClassName }}
  priorityClassName: {{ .Values.coredns.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.coredns.schedulerName }}
  schedulerName: {{ .Values.coredns.schedulerName }}
  {{- end }}
  {{- if .Values.coredns.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.coredns.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.coredns.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "coredns.defaultInitContainers.volumePermissions" (dict "context" . "component" "coredns") | nindent 4 }}
    {{- end }}
    {{- if .Values.coredns.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "coredns.image" . }}
      imagePullPolicy: {{ .Values.coredns.image.pullPolicy | quote }}
      {{- if .Values.coredns.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.coredns.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.coredns.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.coredns.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.coredns.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.coredns.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.coredns.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.coredns.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.coredns.resources }}
      resources: {{- toYaml .Values.coredns.resources | nindent 8 }}
      {{- else if ne .Values.coredns.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.coredns.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.coredns.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.coredns.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.coredns.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.coredns.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.coredns.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.coredns.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/coredns
        {{- if .Values.coredns.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.coredns.secret.tls.mountPath }}
        {{- end }}
      {{- if .Values.coredns.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.coredns.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.coredns.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
        items:
        - key: Corefile
          path: Corefile
        {{- range .Values.coredns.zoneFiles }}
        - key: {{ .filename }}
          path: {{ .filename }}
        {{- end }}
    {{- if .Values.coredns.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
  {{- if .Values.coredns.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.coredns.extraVolumes "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.coredns.pod.enabled }}
  restartPolicy: {{ .Values.coredns.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}