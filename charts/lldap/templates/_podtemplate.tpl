{{- define "lldap.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.lldap.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.lldap.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.lldap.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: lldap
    {{- if .Values.lldap.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.lldap.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.lldap.hostNetwork }}
  {{- if .Values.lldap.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.lldap.dnsPolicy }}
  dnsPolicy: {{ .Values.lldap.dnsPolicy | quote }}
  {{- end }}
  {{- include "lldap.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.lldap.automountServiceAccountToken }}
  {{- if .Values.lldap.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.lldap.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.lldap.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.lldap.podAffinityPreset "component" "lldap" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.lldap.podAntiAffinityPreset "component" "lldap" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.lldap.nodeAffinityPreset.type "key" .Values.lldap.nodeAffinityPreset.key "values" .Values.lldap.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.lldap.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.lldap.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.lldap.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.lldap.priorityClassName }}
  priorityClassName: {{ .Values.lldap.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.lldap.schedulerName }}
  schedulerName: {{ .Values.lldap.schedulerName }}
  {{- end }}
  {{- if .Values.lldap.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.lldap.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.lldap.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.lldap.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.lldap.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "lldap.defaultInitContainers.volumePermissions" (dict "context" . "component" "lldap") | nindent 4 }}
    {{- end }}
    {{- if .Values.lldap.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.lldap.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "lldap.image" . }}
      imagePullPolicy: {{ .Values.lldap.image.pullPolicy | quote }}
      {{- if .Values.lldap.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.lldap.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.lldap.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.lldap.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.lldap.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.lldap.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.lldap.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.lldap.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.lldap.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.lldap.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.lldap.resources }}
      resources: {{- toYaml .Values.lldap.resources | nindent 8 }}
      {{- else if ne .Values.lldap.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.lldap.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.lldap.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.lldap.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.lldap.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.lldap.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.lldap.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.lldap.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.lldap.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.lldap.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.lldap.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.lldap.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /data/lldap_config.toml
          subPath: lldap_config.toml
        {{- if .Values.lldap.secret.ssl.contents }}
        - name: secret-ssl
          mountPath: {{ .Values.lldap.secret.ssl.mountPath }}
        {{- end }}
        {{- if .Values.lldap.secret.others.contents }}
        - name: secret-others
          mountPath: {{ .Values.lldap.secret.others.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.lldap.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.lldap.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.lldap.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.lldap.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.lldap.secret.ssl.contents }}
    - name: secret-ssl
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-ssl
    {{- end }}
    {{- if .Values.lldap.secret.others.contents }}
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
    {{- if .Values.lldap.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.lldap.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.lldap.pod.enabled }}
  restartPolicy: {{ .Values.lldap.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}