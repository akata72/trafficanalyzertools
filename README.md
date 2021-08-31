# Introduction

All tools will take the output from the TrafficAnalyzer as input.

- Invoke-TaNameResolution -InputFile ./BAxxxxx-appname-prod_output.json
- Invoke-TaTcpTest -InputFile ./BAxxxxx-appname-prod_output.json

# Invoke-TaTcpTest

This script will test (tcp) connections to all services defined in the trafficanalyzer results. It should be executed on the machine that has been provided this access or on a machine with an identical tag.

# Invoke-TaNameResolution

This script will try to resolve the names of unknown hosts. Can be executed on any machine with DNS access.

# Invoke-TaDCtest

This script can be executed as is without any parameters. It will assume that DNS servers are also domain controllers and test connectivity to these.

# Ping a subnet?

- 1..20 | ForEach-Object { "192.168.1.$($_): $(Test-Connection -Count 1 -comp 192.168.1.$($_) -Quiet)" }
