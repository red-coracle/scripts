#!/usr/bin/env python3
# Hook for letsencrypt.sh to support Cloudflare dns-01 challenges.

import os
import re
import sys
import logging
import requests
import dns.exception
import dns.resolver
from time import sleep

# Setup/configuration
headers = {'X-Auth-Email': 'email@example.com', 'X-Auth-Key': 'replaceme', 'Content-Type': 'application/json'}
endpoint = 'https://api.cloudflare.com/client/v4/zones'

logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler())
logger.setLevel(logging.INFO)

def get_zone(domain):
    tld = re.search('[A-Za-z0-9-]+\.[A-Za-z]+$', domain).group()
    r = requests.get('{0}?name={1}'.format(endpoint, tld), headers=headers)
    r.raise_for_status()
    return r.json()['result'][0]['id']

def get_record(zone, name):
    r = requests.get('{0}/{1}/dns_records?type=TXT&name={2}'.format(endpoint, zone, name), headers=headers)
    r.raise_for_status()
    try:
        return r.json()['result'][0]['id']
    except:
        logger.info(" + Unable to find record.")
        return

def create_record(domain, token):
    zone = get_zone(domain)
    name = '_acme-challenge.{0}'.format(domain)
    payload = {'type': 'TXT', 'name': name, 'content': token, 'ttl': 1}
    r = requests.post("{0}/{1}/dns_records".format(endpoint, zone), headers=headers, json=payload)
    r.raise_for_status()
    record = r.json()['result']['id']
    logger.info(" + Record with id {0} created.".format(record))

    while not check_propogation(name, token):
        logger.info(" + Waiting for record to propogate.")
        sleep(30)

def check_propogation(name, token):
    records = []
    try:
        query = dns.resolver.query(name, 'TXT')
        for result in query:
            for record in result.strings:
                logger.debug("-- Found TXT record: {0}".format(record))
                if record == token:
                    return True
    except:
        pass

def delete_record(domain):
    zone = get_zone(domain)
    name = '_acme-challenge.{0}'.format(domain)
    record = get_record(zone, name)

    r = requests.delete("{0}/{1}/dns_records/{2}".format(endpoint, zone, record), headers=headers)
    r.raise_for_status()
    logger.info(" + Delete record: {0}".format(name))


if __name__ == '__main__':
    if sys.argv[1] == 'deploy_challenge':
        logger.info(' + Creating DNS record.')
        create_record(sys.argv[2], sys.argv[4])
    elif sys.argv[1] == 'clean_challenge':
        logger.info(' + Removing DNS record.')
        delete_record(sys.argv[2])
