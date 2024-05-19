# https://github.com/newrelic/infrastructure-agent/blob/master/assets/examples/infrastructure/newrelic-infra-template.yml.example

license_key: ${license_key}

enable_process_metrics: true

log:
  file: ${nria_log_file}
  format: json
  level: smart
