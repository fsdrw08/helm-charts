{{- define "nomad.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.nomad.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.nomad.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.nomad.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: nomad
    {{- if .Values.nomad.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nomad.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.nomad.hostNetwork }}
  {{- if .Values.nomad.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.nomad.dnsPolicy }}
  dnsPolicy: {{ .Values.nomad.dnsPolicy | quote }}
  {{- end }}
  {{- include "nomad.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.nomad.automountServiceAccountToken }}
  {{- if .Values.nomad.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.nomad.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.nomad.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.nomad.podAffinityPreset "component" "nomad" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.nomad.podAntiAffinityPreset "component" "nomad" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.nomad.nodeAffinityPreset.type "key" .Values.nomad.nodeAffinityPreset.key "values" .Values.nomad.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.nomad.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.nomad.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.nomad.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.nomad.priorityClassName }}
  priorityClassName: {{ .Values.nomad.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.nomad.schedulerName }}
  schedulerName: {{ .Values.nomad.schedulerName }}
  {{- end }}
  {{- if .Values.nomad.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.nomad.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.nomad.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.nomad.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.nomad.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "nomad.defaultInitContainers.volumePermissions" (dict "context" . "component" "nomad") | nindent 4 }}
    {{- end }}
    {{- if .Values.nomad.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nomad.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: agent
      image: {{ template "nomad.image" . }}
      imagePullPolicy: {{ .Values.nomad.image.pullPolicy | quote }}
      {{- if .Values.nomad.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.nomad.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.nomad.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.nomad.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.nomad.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.nomad.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.nomad.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.nomad.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.nomad.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.nomad.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.nomad.resources }}
      resources: {{- toYaml .Values.nomad.resources | nindent 8 }}
      {{- else if ne .Values.nomad.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.nomad.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.nomad.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.nomad.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nomad.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.nomad.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nomad.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.nomad.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.nomad.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.nomad.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.nomad.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.nomad.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /nomad/config
        {{- if .Values.nomad.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.nomad.secret.tls.mountPath }}
        {{- end }}
        {{- if .Values.nomad.secret.others.contents }}
        - name: secret-others
          mountPath: {{ .Values.nomad.secret.others.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.nomad.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.nomad.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.nomad.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.nomad.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.nomad.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{- if .Values.nomad.secret.others.contents }}
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
    {{- if .Values.nomad.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.nomad.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.nomad.pod.enabled }}
  restartPolicy: {{ .Values.nomad.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}