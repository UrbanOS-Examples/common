{{/* vim: set filetype=mustache: */}}
{{/*
Create a common label block
*/}}
{{- define "bootstrap.labels" -}}
environment: {{ .Values.global.environment }}
chart: {{ .Chart.Name }}-{{ .Chart.Version }}
release: {{ .Release.Name }}
source: helm
{{- end -}}