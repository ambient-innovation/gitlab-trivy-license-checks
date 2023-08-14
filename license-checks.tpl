{{- /* Template based on https://github.com/codeclimate/platform/blob/master/spec/analyzers/SPEC.md#data-types */ -}}
[
  {{- $t_first := true }}
  {{- range . }}
  {{- $target := .Target }}
    {{- if ne .Target "OS Packages" -}}
      {{- range .Licenses -}}
      {{- if $t_first -}}
        {{- $t_first = false -}}
      {{ else -}}
        ,
      {{- end }}
      {
        "type": "issue",
        "check_name": "container_scanning",
        "categories": [ "Security" ],
        "description": {{ list .Name .PkgName .FilePath .Link | compact | join " - " | printf "%q" }},
        "fingerprint": "{{ list .Name .PkgName .FilePath .Link $target | compact | join "" | sha1sum }}",
        "content": {{ .PkgName | printf "%q" }},
        "severity": {{ if eq .Severity "LOW" -}}
                      "info"
                    {{- else if eq .Severity "MEDIUM" -}}
                      "minor"
                    {{- else if eq .Severity "HIGH" -}}
                      "major"
                    {{- else if eq .Severity "CRITICAL" -}}
                      "critical"
                    {{-  else -}}
                      "info"
                    {{- end }},
        "location": {
          "path": {{ if eq $target "Node.js" -}}
                    "package.json"
                  {{- else if eq $target "Python" -}}
                    "Pipfile"
                  {{- end }},
          "lines": {
            "begin": 0
          }
        }
      }
      {{- end -}}
    {{- end}}
  {{- end }}
]