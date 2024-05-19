{
  "agent": {
    "metrics_collection_interval": 10,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "/aws/ec2/{instance_id}/cloud-init",
            "log_stream_name": "cloud-init",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z",
            "timezone": "Local",
            "retention_in_days": 7
          },
          {
            "file_path": "${nria_log_file}",
            "log_group_name": "/aws/ec2/{instance_id}/newrelic-infra-agent",
            "log_stream_name": "newrelic-infra-agent",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z",
            "timezone": "Local",
            "retention_in_days": 7,
            "log_group_class": "INFREQUENT_ACCESS"
          }
        ]
      }
    }
  }
}