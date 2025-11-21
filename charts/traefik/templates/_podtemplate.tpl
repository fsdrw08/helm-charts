{{- define "traefik.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.traefik.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.traefik.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.traefik.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: traefik
    {{- if .Values.traefik.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.traefik.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.traefik.hostNetwork }}
  {{- if .Values.traefik.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.traefik.dnsPolicy }}
  dnsPolicy: {{ .Values.traefik.dnsPolicy | quote }}
  {{- end }}
  {{- include "traefik.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.traefik.automountServiceAccountToken }}
  {{- if .Values.traefik.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.traefik.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.traefik.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.traefik.podAffinityPreset "component" "traefik" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.traefik.podAntiAffinityPreset "component" "traefik" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.traefik.nodeAffinityPreset.type "key" .Values.traefik.nodeAffinityPreset.key "values" .Values.traefik.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.traefik.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.traefik.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.traefik.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.traefik.priorityClassName }}
  priorityClassName: {{ .Values.traefik.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.traefik.schedulerName }}
  schedulerName: {{ .Values.traefik.schedulerName }}
  {{- end }}
  {{- if .Values.traefik.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.traefik.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.traefik.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.traefik.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.traefik.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "traefik.defaultInitContainers.volumePermissions" (dict "context" . "component" "traefik") | nindent 4 }}
    {{- end }}
    {{- if .Values.traefik.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.traefik.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: proxy
      image: {{ template "traefik.image" . }}
      imagePullPolicy: {{ .Values.traefik.image.pullPolicy | quote }}
      {{- if .Values.traefik.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.traefik.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.traefik.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.traefik.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.traefik.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.traefik.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.traefik.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.traefik.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.traefik.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.traefik.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.traefik.resources }}
      resources: {{- toYaml .Values.traefik.resources | nindent 8 }}
      {{- else if ne .Values.traefik.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.traefik.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.traefik.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.traefik.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.traefik.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.traefik.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.traefik.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.traefik.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.traefik.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.traefik.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.traefik.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.traefik.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config-install
          mountPath: /etc/traefik/traefik.yml
          subPath: traefik.yml
        - name: config-routing-builtin
          mountPath: {{ .Values.traefik.configFiles.install.providers.file.directory }}/builtin
        {{- if .Values.traefik.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.traefik.secret.tls.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.traefik.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.traefik.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.traefik.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.traefik.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config-install
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-install
        items:
          - key: traefik.yml
            path: traefik.yml
    {{- if .Values.traefik.configFiles.routing }}
    - name: config-routing-builtin
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-routing
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- if .Values.traefik.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{- if .Values.traefik.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.traefik.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.traefik.pod.enabled }}
  restartPolicy: {{ .Values.traefik.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}