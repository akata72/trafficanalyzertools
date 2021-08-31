# Introduction

All tools will take the output from the TrafficAnalyzer as input.

- Invoke-TaNameResolution -InputFile ./BAxxxxx-appname-prod_output.json
- Invoke-TaTcpTest -InputFile ./BAxxxxx-appname-prod_output.json

# Invoke-TaTcpTest

This script will test (tcp) connections to all services defined in the trafficanalyzer results. It should be executed on the machine that has been provided this access or on a machine with an identical tag.

# Invoke-TaNameResolution

This script will try to resolve the names of unknown hosts. Can be executed on any machine with DNS access.
