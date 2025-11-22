{{- define "postgresql.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.postgresql.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.postgresql.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.postgresql.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: postgresql
    {{- if .Values.postgresql.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.postgresql.hostNetwork }}
  {{- if .Values.postgresql.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.postgresql.dnsPolicy }}
  dnsPolicy: {{ .Values.postgresql.dnsPolicy | quote }}
  {{- end }}
  {{- include "postgresql.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.postgresql.automountServiceAccountToken }}
  {{- if .Values.postgresql.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.postgresql.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.postgresql.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.postgresql.podAffinityPreset "component" "postgresql" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.postgresql.podAntiAffinityPreset "component" "postgresql" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.postgresql.nodeAffinityPreset.type "key" .Values.postgresql.nodeAffinityPreset.key "values" .Values.postgresql.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.postgresql.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.postgresql.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.postgresql.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.postgresql.priorityClassName }}
  priorityClassName: {{ .Values.postgresql.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.postgresql.schedulerName }}
  schedulerName: {{ .Values.postgresql.schedulerName }}
  {{- end }}
  {{- if .Values.postgresql.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.postgresql.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.postgresql.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.postgresql.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.postgresql.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "postgresql.defaultInitContainers.volumePermissions" (dict "context" . "component" "postgresql") | nindent 4 }}
    {{- end }}
    {{- if .Values.postgresql.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: postgresql
      image: {{ template "postgresql.image" . }}
      imagePullPolicy: {{ .Values.postgresql.image.pullPolicy | quote }}
      {{- if .Values.postgresql.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.postgresql.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.postgresql.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.postgresql.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        - configMapRef:
            name: {{ template "common.names.fullname" . }}-cm-envvar
        {{- if .Values.postgresql.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.postgresql.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.postgresql.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.postgresql.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.postgresql.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.postgresql.resources }}
      resources: {{- toYaml .Values.postgresql.resources | nindent 8 }}
      {{- else if ne .Values.postgresql.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.postgresql.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.postgresql.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.postgresql.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.postgresql.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.postgresql.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.postgresql.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.postgresql.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.postgresql.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.postgresql.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.postgresql.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        {{- range $key, $val := .Values.postgresql.extending }}
        {{- if $val }}
        - name: config-extending-{{ $key }}
          mountPath: /opt/app-root/src/postgresql-{{ $key }}
        {{- end }}
        {{- end }}
        {{- if .Values.postgresql.secret.ssl.contents }}
        - name: ssl
          mountPath: {{ .Values.postgresql.secret.ssl.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.postgresql.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.postgresql.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.postgresql.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    {{- range $key, $val := .Values.postgresql.extending }}
    {{- if $val }}
    - name: config-extending-{{ $key }}
      configMap: 
        name: {{ template "common.names.fullname" $ }}-cm-extending-{{ $key }}
    {{- end }}
    {{- end }}
    {{- if .Values.postgresql.secret.ssl.contents }}
    - name: ssl
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-ssl
        defaultMode: 0600
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.postgresql.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.postgresql.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.postgresql.pod.enabled }}
  restartPolicy: {{ .Values.postgresql.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}