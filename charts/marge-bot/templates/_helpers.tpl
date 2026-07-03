{{/*
Expand the name of the chart.
*/}}
{{- define "marge-bot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "marge-bot.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "marge-bot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "marge-bot.labels" -}}
helm.sh/chart: {{ include "marge-bot.chart" . }}
app.kubernetes.io/name: {{ include "marge-bot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
k8s-app: {{ include "marge-bot.name" . }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "marge-bot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "marge-bot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
k8s-app: {{ include "marge-bot.name" . }}
{{- end -}}

{{/*
Secret name.
*/}}
{{- define "marge-bot.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- printf "%s-secrets" (include "marge-bot.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
