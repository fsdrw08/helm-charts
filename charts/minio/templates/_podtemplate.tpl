{{- define "minio.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.minio.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.minio.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.minio.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.minio.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: minio
    {{- if .Values.minio.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.minio.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.minio.hostNetwork }}
  {{- if .Values.minio.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.minio.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.minio.dnsPolicy }}
  dnsPolicy: {{ .Values.minio.dnsPolicy | quote }}
  {{- end }}
  {{- include "minio.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.minio.automountServiceAccountToken }}
  {{- if .Values.minio.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.minio.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.minio.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.minio.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.minio.podAffinityPreset "component" "minio" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.minio.podAntiAffinityPreset "component" "minio" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.minio.nodeAffinityPreset.type "key" .Values.minio.nodeAffinityPreset.key "values" .Values.minio.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.minio.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.minio.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.minio.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.minio.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.minio.priorityClassName }}
  priorityClassName: {{ .Values.minio.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.minio.schedulerName }}
  schedulerName: {{ .Values.minio.schedulerName }}
  {{- end }}
  {{- if .Values.minio.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.minio.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.minio.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.minio.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.minio.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.minio.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "minio.defaultInitContainers.volumePermissions" (dict "context" . "component" "minio") | nindent 4 }}
    {{- end }}
    {{- if .Values.minio.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.minio.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: server
      image: {{ template "minio.image" . }}
      imagePullPolicy: {{ .Values.minio.image.pullPolicy | quote }}
      {{- if .Values.minio.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.minio.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.minio.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.minio.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.minio.args "context" $) | nindent 8 }}
      {{- else }}
      args: 
        - server
        {{- range $command := splitList " " .Values.minio.config.MINIO_OPTS }}
        - {{ $command }}
        {{- end }}
        - {{ .Values.minio.config.MINIO_VOLUMES }}
      {{- end }}
      env:
        - name: MINIO_CONFIG_ENV_FILE
          value: {{ .Values.minio.config.MINIO_CONFIG_ENV_FILE }}
        - name: MINIO_ROOT_USER_FILE
          value: {{ .Values.minio.config.MINIO_ROOT_USER_FILE }}
        - name: MINIO_ROOT_PASSWORD_FILE
          value: {{ .Values.minio.config.MINIO_ROOT_PASSWORD_FILE }}
        {{- if .Values.minio.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.minio.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.minio.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.minio.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.minio.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.minio.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.minio.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.minio.resources }}
      resources: {{- toYaml .Values.minio.resources | nindent 8 }}
      {{- else if ne .Values.minio.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.minio.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.minio.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.minio.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.minio.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.minio.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.minio.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.minio.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.minio.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.minio.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.minio.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.minio.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.minio.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.minio.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.minio.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.minio.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: {{ .Values.minio.config.MINIO_CONFIG_ENV_FILE }}
          subPath: {{ base .Values.minio.config.MINIO_CONFIG_ENV_FILE }}
        {{- if and ( index .Values.minio.secret.tls.contents "public.crt" ) ( index .Values.minio.secret.tls.contents "private.key" ) }}
        - name: secret-tls-default
          mountPath: {{ .Values.minio.secret.tls.mountPath }}
        {{- end }}
        {{- if .Values.minio.secret.tls.contents.additionalDomains }}
        {{- range $additionalDomain := .Values.minio.secret.tls.contents.additionalDomains }}
        - name: secret-tls-additional-{{ $additionalDomain.name }}
          mountPath: {{ $.Values.minio.secret.tls.mountPath }}/{{ $additionalDomain.name }}
        {{- end }}
        {{- end }}
        {{- if .Values.minio.secret.tls.contents.CAs }}
        - name: secret-tls-ca
          mountPath: {{ $.Values.minio.secret.tls.mountPath }}/CAs
        {{- end }}
        {{- if .Values.minio.secret.others.contents }}
        - name: secret-others
          mountPath: {{ .Values.minio.secret.others.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.minio.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.minio.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.minio.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.minio.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if and ( index .Values.minio.secret.tls.contents "public.crt" ) ( index .Values.minio.secret.tls.contents "private.key" ) }}
    - name: secret-tls-default
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls-default
        items:
          - key: public.crt
            path: public.crt
          - key: private.key
            path: private.key
    {{- end }}
    {{- if .Values.minio.secret.tls.contents.additionalDomains }}
    {{- range $additionalDomain := .Values.minio.secret.tls.contents.additionalDomains }}
    - name: secret-tls-additional-{{ $additionalDomain.name }}
      secret:
        secretName: {{ template "common.names.fullname" $ }}-sec-tls-additional
        items:
          - key: {{ $additionalDomain.name }}.public.crt
            path: public.crt
          - key: {{ $additionalDomain.name }}.private.key
            path: private.key
    {{- end }}
    {{- end }}
    {{- if .Values.minio.secret.tls.contents.CAs }}
    - name: secret-tls-ca
      secret:
        secretName: {{ template "common.names.fullname" $ }}-sec-tls-ca
        items:
          {{- range $key, $val := .Values.minio.secret.tls.contents.CAs }}
          - key: ca.{{ $key }}
            path: {{ $key }}
          {{- end }}
    {{- end }}
    {{- if .Values.minio.secret.others.contents }}
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
    {{- if .Values.minio.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.minio.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.minio.pod.enabled }}
  restartPolicy: {{ .Values.minio.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}