{{- define "cockpit.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.cockpit.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.cockpit.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.cockpit.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: cockpit
    {{- if .Values.cockpit.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.cockpit.hostNetwork }}
  {{- if .Values.cockpit.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.cockpit.dnsPolicy }}
  dnsPolicy: {{ .Values.cockpit.dnsPolicy | quote }}
  {{- end }}
  {{- include "cockpit.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.cockpit.automountServiceAccountToken }}
  {{- if .Values.cockpit.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.cockpit.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.cockpit.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.cockpit.podAffinityPreset "component" "cockpit" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.cockpit.podAntiAffinityPreset "component" "cockpit" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.cockpit.nodeAffinityPreset.type "key" .Values.cockpit.nodeAffinityPreset.key "values" .Values.cockpit.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.cockpit.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.cockpit.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.cockpit.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.cockpit.priorityClassName }}
  priorityClassName: {{ .Values.cockpit.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.cockpit.schedulerName }}
  schedulerName: {{ .Values.cockpit.schedulerName }}
  {{- end }}
  {{- if .Values.cockpit.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.cockpit.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.cockpit.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.cockpit.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.cockpit.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "cockpit.defaultInitContainers.volumePermissions" (dict "context" . "component" "cockpit") | nindent 4 }}
    {{- end }}
    {{- if .Values.cockpit.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: ws
      image: {{ template "cockpit.image" . }}
      imagePullPolicy: {{ .Values.cockpit.image.pullPolicy | quote }}
      {{- if .Values.cockpit.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.cockpit.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.cockpit.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.cockpit.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.cockpit.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.cockpit.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.cockpit.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.cockpit.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.cockpit.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.cockpit.resources }}
      resources: {{- toYaml .Values.cockpit.resources | nindent 8 }}
      {{- else if ne .Values.cockpit.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.cockpit.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.cockpit.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.cockpit.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.cockpit.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.cockpit.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.cockpit.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.cockpit.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.cockpit.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.cockpit.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.cockpit.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/cockpit/cockpit.conf
          subPath: cockpit.conf
        {{- if .Values.cockpit.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.cockpit.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.cockpit.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.cockpit.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.cockpit.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.cockpit.secret.tls.contents }}
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
    {{- if .Values.cockpit.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.cockpit.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.cockpit.pod.enabled }}
  restartPolicy: {{ .Values.cockpit.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}