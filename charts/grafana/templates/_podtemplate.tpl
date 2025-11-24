{{- define "grafana.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.grafana.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.grafana.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.grafana.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: grafana
    {{- if .Values.grafana.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.grafana.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.grafana.hostNetwork }}
  {{- if .Values.grafana.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.grafana.dnsPolicy }}
  dnsPolicy: {{ .Values.grafana.dnsPolicy | quote }}
  {{- end }}
  {{- include "grafana.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.grafana.automountServiceAccountToken }}
  {{- if .Values.grafana.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.grafana.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.grafana.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.grafana.podAffinityPreset "component" "grafana" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.grafana.podAntiAffinityPreset "component" "grafana" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.grafana.nodeAffinityPreset.type "key" .Values.grafana.nodeAffinityPreset.key "values" .Values.grafana.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.grafana.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.grafana.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.grafana.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.grafana.priorityClassName }}
  priorityClassName: {{ .Values.grafana.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.grafana.schedulerName }}
  schedulerName: {{ .Values.grafana.schedulerName }}
  {{- end }}
  {{- if .Values.grafana.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.grafana.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.grafana.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.grafana.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.grafana.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "grafana.defaultInitContainers.volumePermissions" (dict "context" . "component" "grafana") | nindent 4 }}
    {{- end }}
    {{- if .Values.grafana.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.grafana.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "grafana.image" . }}
      imagePullPolicy: {{ .Values.grafana.image.pullPolicy | quote }}
      {{- if .Values.grafana.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.grafana.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.grafana.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.grafana.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.grafana.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.grafana.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.grafana.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.grafana.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.grafana.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.grafana.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.grafana.resources }}
      resources: {{- toYaml .Values.grafana.resources | nindent 8 }}
      {{- else if ne .Values.grafana.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.grafana.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.grafana.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.grafana.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.grafana.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.grafana.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.grafana.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.grafana.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.grafana.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.grafana.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.grafana.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.grafana.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config-custom
          mountPath: /etc/grafana/grafana.ini
          subPath: grafana.ini
        {{- if .Values.grafana.configFiles.dataSource }}
        - name: config-dataSource
          mountPath: {{ .Values.grafana.configFiles.custom.paths.provisioning }}/datasources
        {{- end }}
        {{- if .Values.grafana.configFiles.ldap }}
        - name: config-ldap
          mountPath: /etc/grafana/ldap.toml
          subPath: ldap.toml
        {{- end }}
        {{- if .Values.grafana.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.grafana.secret.tls.mountPath }}
        {{- end }}
        {{- if .Values.grafana.secret.others.contents }}
        - name: secret-others
          mountPath: {{ .Values.grafana.secret.others.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ include "common.tplvalues.render" (dict "value" .Values.persistence.mountPath "context" $) }}
      {{- if .Values.grafana.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.grafana.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.grafana.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.grafana.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config-custom
      configMap:
        name: {{ template "common.names.fullname" . }}-cm-custom
    {{- if .Values.grafana.configFiles.dataSource }}
    - name: config-dataSource
      configMap:
        name: {{ include "common.names.fullname" . }}-cm-datasource
    {{- end }}
    {{- if .Values.grafana.configFiles.ldap }}
    - name: config-ldap
      secret:
        secretName: {{ include "common.names.fullname" . }}-sec-ldap
        items:
          - key: ldap.toml
            path: ldap.toml
    {{- end }}
    {{- if .Values.grafana.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{- if .Values.grafana.secret.others.contents }}
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
    {{- if .Values.grafana.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.grafana.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.grafana.pod.enabled }}
  restartPolicy: {{ .Values.grafana.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}