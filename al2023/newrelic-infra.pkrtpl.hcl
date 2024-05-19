# https://github.com/newrelic/infrastructure-agent/blob/master/assets/examples/infrastructure/newrelic-infra-template.yml.example

license_key: ${license_key}

enable_process_metrics: true

log:
  file: /var/log/newrelic-infra/newrelic-infra.log
  format: json
  level: smart
