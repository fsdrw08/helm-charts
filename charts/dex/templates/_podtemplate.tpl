{{- define "dex.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.dex.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.dex.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.dex.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.dex.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: dex
    {{- if .Values.dex.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dex.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.dex.hostNetwork }}
  {{- if .Values.dex.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.dex.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.dex.dnsPolicy }}
  dnsPolicy: {{ .Values.dex.dnsPolicy | quote }}
  {{- end }}
  {{- include "dex.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.dex.automountServiceAccountToken }}
  {{- if .Values.dex.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.dex.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dex.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.dex.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.dex.podAffinityPreset "component" "dex" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.dex.podAntiAffinityPreset "component" "dex" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.dex.nodeAffinityPreset.type "key" .Values.dex.nodeAffinityPreset.key "values" .Values.dex.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.dex.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.dex.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dex.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.dex.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dex.priorityClassName }}
  priorityClassName: {{ .Values.dex.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.dex.schedulerName }}
  schedulerName: {{ .Values.dex.schedulerName }}
  {{- end }}
  {{- if .Values.dex.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.dex.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.dex.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.dex.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.dex.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.dex.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "dex.defaultInitContainers.volumePermissions" (dict "context" . "component" "dex") | nindent 4 }}
    {{- end }}
    {{- if .Values.dex.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dex.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: idp
      image: {{ template "dex.image" . }}
      imagePullPolicy: {{ .Values.dex.image.pullPolicy | quote }}
      {{- if .Values.dex.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.dex.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.dex.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.dex.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.dex.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.dex.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.dex.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.dex.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dex.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.dex.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.dex.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.dex.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.dex.resources }}
      resources: {{- toYaml .Values.dex.resources | nindent 8 }}
      {{- else if ne .Values.dex.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.dex.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.dex.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.dex.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dex.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dex.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dex.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dex.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.dex.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dex.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.dex.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.dex.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.dex.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.dex.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.dex.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.dex.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/dex/config.docker.yaml
          subPath: config.docker.yaml
        {{- if .Values.dex.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.dex.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.dex.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.dex.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.dex.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.dex.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.dex.secret.tls.contents }}
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
    {{- if .Values.dex.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.dex.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.dex.pod.enabled }}
  restartPolicy: {{ .Values.dex.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}