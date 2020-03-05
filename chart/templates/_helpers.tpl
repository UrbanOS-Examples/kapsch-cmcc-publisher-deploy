{{/* vim: set filetype=mustache: */}}
{{/*
Common labels
*/}}
{{- define "kapsch-cmcc-publisher.labels" -}}
app.kubernetes.io/name: kapsch-cmcc-publisher
helm.sh/chart: kapsch-cmcc-publisher
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
