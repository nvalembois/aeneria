{{- define "app.env" }}
- name: DATABASE_URL
{{- if eq .Values.db.type "cnpg" }}
  valueFrom:
    secretKeyRef:
      key: uri
      name: "{{ include "app.fullname" . }}-db-app"
{{- end }}
- name: APP_SECRET
  valueFrom:
    secretKeyRef:
      key: APP_SECRET
      name: {{ include "app.fullname" . | quote }}
{{- if not (hasKey .Values.app.env "AENERIA_PROXY_URL") }}
- name: AENERIA_PROXY_URL
{{- if .Values.ingress.enabled }}
  value: https://{{ .Values.ingress.host }}
{{ else }}
  value: http://{{ include "app.fullname" . }}
{{- end }}
{{- end }}
{{- range $name, $value := .Values.app.env }}
- name: {{ $name | quote }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}
