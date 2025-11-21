{{- define "etcd.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.etcd.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.etcd.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.etcd.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: etcd
    {{- if .Values.etcd.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.etcd.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.etcd.hostNetwork }}
  {{- if .Values.etcd.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.etcd.dnsPolicy }}
  dnsPolicy: {{ .Values.etcd.dnsPolicy | quote }}
  {{- end }}
  {{- include "etcd.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.etcd.automountServiceAccountToken }}
  {{- if .Values.etcd.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.etcd.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.etcd.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.etcd.podAffinityPreset "component" "etcd" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.etcd.podAntiAffinityPreset "component" "etcd" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.etcd.nodeAffinityPreset.type "key" .Values.etcd.nodeAffinityPreset.key "values" .Values.etcd.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.etcd.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.etcd.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.etcd.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.etcd.priorityClassName }}
  priorityClassName: {{ .Values.etcd.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.etcd.schedulerName }}
  schedulerName: {{ .Values.etcd.schedulerName }}
  {{- end }}
  {{- if .Values.etcd.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.etcd.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.etcd.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.etcd.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.etcd.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "etcd.defaultInitContainers.volumePermissions" (dict "context" . "component" "etcd") | nindent 4 }}
    {{- end }}
    {{- if .Values.etcd.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.etcd.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "etcd.image" . }}
      imagePullPolicy: {{ .Values.etcd.image.pullPolicy | quote }}
      {{- if .Values.etcd.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.etcd.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.etcd.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.etcd.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.etcd.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.etcd.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.etcd.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.etcd.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.etcd.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.etcd.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.etcd.resources }}
      resources: {{- toYaml .Values.etcd.resources | nindent 8 }}
      {{- else if ne .Values.etcd.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.etcd.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.etcd.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.etcd.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.etcd.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.etcd.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.etcd.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.etcd.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.etcd.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.etcd.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.etcd.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.etcd.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/etcd/etcd.config.yml
          subPath: etcd.config.yml
        {{- if .Values.etcd.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.etcd.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.etcd.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.etcd.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.etcd.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.etcd.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
        items:
          - key: etcd.config.yml
            path: etcd.config.yml
    {{- if .Values.etcd.secret.tls.contents }}
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
    {{- if .Values.etcd.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.etcd.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{ if .Values.etcd.pod.enabled }}
  restartPolicy: {{ .Values.etcd.pod.restartPolicy }}
  {{- else -}}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}