{{- define "zot.podTemplate" -}}
metadata:
  {{- $podLabels := include "common.tplvalues.merge" ( dict "values" ( list .Values.zot.podLabels .Values.commonLabels ) "context" . ) }}
  {{- if .Values.zot.pod.enabled }}
  name: {{ template "common.names.fullname" . }}
  namespace: {{ include "common.names.namespace" . | quote }}
  {{- end }}
  {{- if .Values.zot.podAnnotations }}
  annotations: {{- include "common.tplvalues.render" (dict "value" .Values.zot.podAnnotations "context" $) | nindent 4 }}
  {{- end }}
  labels: {{- include "common.labels.standard" . | nindent 4 }}
    app.kubernetes.io/component: zot
    {{- if .Values.zot.podLabels }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zot.podLabels "context" $) | nindent 4 }}
    {{- end }}
    {{- if .Values.commonLabels }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.commonLabels "context" $ ) | nindent 4 }}
    {{- end }}
spec:
  hostNetwork: {{ .Values.zot.hostNetwork }}
  {{- if .Values.zot.dnsConfig }}
  dnsConfig: {{- include "common.tplvalues.render" (dict "value" .Values.zot.dnsConfig "context" $) | nindent 4 -}}
  {{- end }}
  {{- if .Values.zot.dnsPolicy }}
  dnsPolicy: {{ .Values.zot.dnsPolicy | quote }}
  {{- end }}
  {{- include "zot.imagePullSecrets" . | nindent 2 }}
  serviceAccountName: {{ .Values.serviceAccount.name }}
  automountServiceAccountToken: {{ .Values.zot.automountServiceAccountToken }}
  {{- if .Values.zot.hostAliases }}
  hostAliases: {{- include "common.tplvalues.render" (dict "value" .Values.zot.hostAliases "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.zot.affinity }}
  affinity: {{- include "common.tplvalues.render" ( dict "value" .Values.zot.affinity "context" $) | nindent 8 }}
  {{- else }}
  affinity:
    podAffinity: {{- include "common.affinities.pods" (dict "type" .Values.zot.podAffinityPreset "component" "zot" "customLabels" $podLabels "context" $) | nindent 6 }}
    podAntiAffinity: {{- include "common.affinities.pods" (dict "type" .Values.zot.podAntiAffinityPreset "component" "zot" "customLabels" $podLabels "context" $) | nindent 6 }}
    nodeAffinity: {{- include "common.affinities.nodes" (dict "type" .Values.zot.nodeAffinityPreset.type "key" .Values.zot.nodeAffinityPreset.key "values" .Values.zot.nodeAffinityPreset.values) | nindent 6 }}
  {{- end }}
  {{- if .Values.zot.nodeSelector }}
  nodeSelector: {{- include "common.tplvalues.render" ( dict "value" .Values.zot.nodeSelector "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.zot.tolerations }}
  tolerations: {{- include "common.tplvalues.render" (dict "value" .Values.zot.tolerations "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.zot.priorityClassName }}
  priorityClassName: {{ .Values.zot.priorityClassName | quote }}
  {{- end }}
  {{- if .Values.zot.schedulerName }}
  schedulerName: {{ .Values.zot.schedulerName }}
  {{- end }}
  {{- if .Values.zot.topologySpreadConstraints }}
  topologySpreadConstraints: {{- include "common.tplvalues.render" (dict "value" .Values.zot.topologySpreadConstraints "context" $) | nindent 4 }}
  {{- end }}
  {{- if .Values.zot.podSecurityContext.enabled }}
  securityContext: {{- omit .Values.zot.podSecurityContext "enabled" | toYaml | nindent 4 }}
  {{- end }}
  {{- if .Values.zot.terminationGracePeriodSeconds }}
  terminationGracePeriodSeconds: {{ .Values.zot.terminationGracePeriodSeconds }}
  {{- end }}
  initContainers:
    {{- if and .Values.defaultInitContainers.volumePermissions.enabled .Values.persistence.enabled }}
    {{- include "zot.defaultInitContainers.volumePermissions" (dict "context" . "component" "zot") | nindent 4 }}
    {{- end }}
    {{- if .Values.zot.initContainers }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zot.initContainers "context" $) | nindent 4 }}
    {{- end }}
  containers:
    - name: registry
      image: {{ template "zot.image" . }}
      imagePullPolicy: {{ .Values.zot.image.pullPolicy | quote }}
      {{- if .Values.zot.containerSecurityContext.enabled }}
      securityContext: {{- include "common.compatibility.renderSecurityContext" (dict "secContext" .Values.zot.containerSecurityContext "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.diagnosticMode.enabled }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.diagnosticMode.command "context" $) | nindent 8 }}
      {{- else if .Values.zot.command }}
      command: {{- include "common.tplvalues.render" (dict "value" .Values.zot.command "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.args }}
      args: {{- include "common.tplvalues.render" (dict "value" .Values.zot.args "context" $) | nindent 8 }}
      {{- end }}
      env:
        {{- if .Values.zot.extraEnvVars }}
        {{- include "common.tplvalues.render" (dict "value" .Values.zot.extraEnvVars "context" $) | nindent 8 }}
        {{- end }}
      envFrom:
        {{- if .Values.zot.extraEnvVarsCM }}
        - configMapRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zot.extraEnvVarsCM "context" $) }}
        {{- end }}
        {{- if .Values.zot.secret.envVars }}
        - secretRef:
            name: {{ template "common.names.fullname" . }}-sec-envVars
        {{- end }}
        {{- if .Values.zot.extraEnvVarsSecret }}
        - secretRef:
            name: {{ include "common.tplvalues.render" (dict "value" .Values.zot.extraEnvVarsSecret "context" $) }}
        {{- end }}
      {{- if .Values.zot.resources }}
      resources: {{- toYaml .Values.zot.resources | nindent 8 }}
      {{- else if ne .Values.zot.resourcesPreset "none" }}
      resources: {{- include "common.resources.preset" (dict "type" .Values.zot.resourcesPreset) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.containerPorts }}
      ports: {{- include "common.tplvalues.render" (dict "value" .Values.zot.containerPorts "context" $) | nindent 8 -}}
      {{- end }}
      {{- if not .Values.diagnosticMode.enabled }}
      {{- if .Values.zot.customLivenessProbe }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zot.customLivenessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zot.livenessProbe.enabled }}
      livenessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zot.livenessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.customReadinessProbe }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zot.customReadinessProbe "context" $) | nindent 8 }}
      {{- else if .Values.zot.readinessProbe.enabled }}
      readinessProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zot.readinessProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- if .Values.zot.customStartupProbe }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" .Values.zot.customStartupProbe "context" $) | nindent 8 }}
      {{- else if .Values.zot.startupProbe.enabled }}
      startupProbe: {{- include "common.tplvalues.render" (dict "value" (omit .Values.zot.startupProbe "enabled") "context" $) | nindent 8 }}
      {{- end }}
      {{- end }}
      {{- if .Values.zot.lifecycleHooks }}
      lifecycle: {{- include "common.tplvalues.render" (dict "value" .Values.zot.lifecycleHooks "context" $) | nindent 8 }}
      {{- end }}
      volumeMounts:
        - name: config
          mountPath: /etc/zot/config.json
          subPath: config.json
        {{- /*
        https://stackoverflow.com/questions/59795596/how-to-make-nested-variables-optional-in-helm/68807258#68807258
        */ -}}
        {{- if ((((.Values.zot.config).extensions).search).cve) }}
        - name: tmp
          mountPath: /tmp
        {{- end }}
        {{- if .Values.zot.secret.tls.contents }}
        - name: secret-tls
          mountPath: {{ .Values.zot.secret.tls.mountPath }}
        {{- end }}
        {{- if .Values.zot.secret.others.contents }}
        - name: secret-others
          mountPath: {{ .Values.zot.secret.others.mountPath }}
        {{- end }}
        - name: data
          mountPath: {{ .Values.persistence.mountPath }}
          {{- if .Values.persistence.subPath }}
          subPath: {{ .Values.persistence.subPath }}
          {{- end }}
      {{- if .Values.zot.extraVolumeMounts }}
      {{- include "common.tplvalues.render" (dict "value" .Values.zot.extraVolumeMounts "context" $) | nindent 8 }}
      {{- end }}
    {{- if .Values.zot.sidecars }}
    {{- include "common.tplvalues.render" ( dict "value" .Values.zot.sidecars "context" $) | nindent 4 }}
    {{- end }}
  volumes:
    - name: config
      configMap:
        name: {{ template "common.names.fullname" . }}-cm
    {{- if .Values.zot.secret.tls.contents }}
    - name: secret-tls
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-tls
    {{- end }}
    {{- if .Values.zot.secret.others.contents }}
    - name: secret-others
      secret:
        secretName: {{ template "common.names.fullname" . }}-sec-others
    {{- end }}
    - name: data
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc-data" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- /*
    https://stackoverflow.com/questions/59795596/how-to-make-nested-variables-optional-in-helm/68807258#68807258
    */ -}}
    {{- if ((((.Values.zot.config).extensions).search).cve) }}
    - name: tmp
    {{- if .Values.persistence.enabled }}
      persistentVolumeClaim:
        claimName: {{ default ( print (include "common.names.fullname" .) "-pvc-tmp" ) .Values.persistence.existingClaim }}
    {{- else }}
      emptyDir: {}
    {{- end }}
    {{- end }}
    {{- if .Values.zot.extraVolumes }}
    {{- include "common.tplvalues.render" (dict "value" .Values.zot.extraVolumes "context" $) | nindent 4 }}
    {{- end }}
  {{- if .Values.zot.pod.enabled }}
  restartPolicy: {{ .Values.zot.pod.restartPolicy }}
  {{- else }}
  {{- /* https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#pod-template */}}
  restartPolicy: Always
  {{- end }}
{{- end -}}