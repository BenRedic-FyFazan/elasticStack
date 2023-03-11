#!/bin/bash -x
$scripts/integrations/integration_base.sh
$scripts/integrations/integration_apache.sh
$scripts/integrations/integration_cockroachDB.sh
$scripts/integrations/integration_memcached.sh
$scripts/integrations/integration_haproxy.sh
