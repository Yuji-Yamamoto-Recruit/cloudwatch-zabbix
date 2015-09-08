# cloudwatch-zabbix

## how to use

```sh
bundle exec ruby cloud_watch.rb  --region [REGION] --service [SERVICE_NAME] --metric [METRIC_NAME] --dimension_name [DIMENSION_NAME] --dimension_value [DB_INSTANCE_NAME] --statistics [STATISTCS]
```

### example
```sh
bundle exec ruby cloud_watch.rb  --region ap-northeast-1 --service RDS --metric CPUUtilization --dimension_name DBInstanceIdentifier --dimension_value my-db01 --statistics Average
```
