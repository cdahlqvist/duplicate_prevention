#!/bin/bash
logstash_path='./bin/logstash'

# Index 5.0M logs at a time up to 200M for each of threee configurations
iterations=40
log_count=5000000
workers=8

for (( i=0; i < $iterations; i++ ))
do
    start_time=`date +%s`
    ./cat_logs logs $log_count | $logstash_path -w $workers -f ./autoid.conf
    end_time=`date +%s`
    duration=`expr $end_time - $start_time`
    echo `date` " => $log_count records processed with autogenerated ID in $duration seconds."  >> ./log_autoid.log

    sleep 5
    curl -XGET "http://$host:9200/_cat/indices" | grep auto >> ./log_autoid.log

    start_time=`date +%s`
    ./cat_logs logs $log_count | $logstash_path -w $workers -f ./uuid.conf
    end_time=`date +%s`
    duration=`expr $end_time - $start_time`
    echo `date` " => $log_count records processed with UUID based ID in $duration seconds." >> ./log_uuid.log

    sleep 5
    curl -XGET "http://$host:9200/_cat/indices" | grep hash1 >> ./log_uuid.log

    start_time=`date +%s`
    ./cat_logs logs $log_count | $logstash_path -w $workers -f ./hashid.conf
    end_time=`date +%s`
    duration=`expr $end_time - $start_time`
    echo `date` " => $log_count records processed with time and 96-bit MD5 hash based ID in $duration seconds." >> ./log_hashid.log

    sleep 5
    curl -XGET "http://$host:9200/_cat/indices" | grep hash2 >> ./log_hashid.log
done
