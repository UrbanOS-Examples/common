"""
Tests for the external data provider that gets the first available cidr block to peer with an alm vpc.

Gaps:
- Not easy to test failure cases with moto and mockito + boto3 is a mocking nightmare
- Moto is not perfect when it comes to implementation, so things like filtering out peers that don't belong to the alm are not possible

"""
import boto3
import ipaddress
import pytest
from moto import mock_ec2, mock_sts
from functools import partial

import env.first_available_cidr_block as under_test


@mock_ec2
@mock_sts
def test_get_used_networks_combines_vpc_and_peers():
    region = 'us-east-2'

    under_test.set_default_region(region)

    cidr_blocks = [
        '10.0.0.0/16',   # first record is alm
        '10.100.0.0/16',
        '10.101.0.0/16',
        '10.102.0.0/16',
    ]

    alm_vpc_id = _setup_vpc_peering(region, cidr_blocks)

    assert sorted(under_test.get_used_networks(alm_vpc_id)) == \
        sorted([
            ipaddress.IPv4Network('10.0.0.0/16'),
            ipaddress.IPv4Network('10.102.0.0/16'),
            ipaddress.IPv4Network('10.101.0.0/16'),
            ipaddress.IPv4Network('10.100.0.0/16'),
        ])


@mock_ec2
@mock_sts
def test_get_used_networks_returns_vpc_cidr_block_if_no_peering():
    region = 'us-east-2'

    under_test.set_default_region(region)

    cidr_blocks = [
        '10.0.0.0/16',   # first record is alm
    ]

    alm_vpc_id = _setup_vpc_peering(region, cidr_blocks)

    assert sorted(under_test.get_used_networks(alm_vpc_id)) == \
        [
           ipaddress.IPv4Network('10.0.0.0/16'),
        ]

@mock_ec2
@mock_sts
def test_get_used_networks_returns_empty_if_vpc_not_there():
    region = 'us-east-2'

    under_test.set_default_region(region)

    assert sorted(under_test.get_used_networks('no-vpc-found')) == []


def test_find_first_available_network_with_same_size_subnet():
    minimum_host_bits = '16'
    parent_network = ipaddress.IPv4Network('10.0.0.0/8')
    used_network_list = [
        ipaddress.IPv4Network('10.3.0.0/16'),
        ipaddress.IPv4Network('10.2.0.0/16'),
        ipaddress.IPv4Network('10.1.0.0/16'),
        ipaddress.IPv4Network('10.0.0.0/16'),
    ]

    assert under_test.find_first_available_network(parent_network, used_network_list, minimum_host_bits) == \
        ipaddress.IPv4Network('10.4.0.0/16')


def test_find_first_available_network_with_larger_subnet():
    minimum_host_bits = '16'
    parent_network = ipaddress.IPv4Network('10.0.0.0/8')
    used_network_list = [
        ipaddress.IPv4Network('10.102.0.0/16'),
        ipaddress.IPv4Network('10.101.0.0/16'),
        ipaddress.IPv4Network('10.100.0.0/16'),
        ipaddress.IPv4Network('10.0.0.0/15'),
    ]

    assert under_test.find_first_available_network(parent_network, used_network_list, minimum_host_bits) == \
        ipaddress.IPv4Network('10.2.0.0/16')


def test_find_first_available_network_with_smaller_subnet():
    minimum_host_bits = '16'
    parent_network = ipaddress.IPv4Network('10.0.0.0/8')
    used_network_list = [
        ipaddress.IPv4Network('10.102.0.0/16'),
        ipaddress.IPv4Network('10.2.0.0/16'),
        ipaddress.IPv4Network('10.1.0.0/16'),
        ipaddress.IPv4Network('10.0.0.0/17'),
    ]

    assert under_test.find_first_available_network(parent_network, used_network_list, minimum_host_bits) == \
        ipaddress.IPv4Network('10.3.0.0/16')


def test_find_first_available_network_with_no_subnets():
    minimum_host_bits = '16'
    parent_network = ipaddress.IPv4Network('10.0.0.0/8')
    used_network_list = []

    assert under_test.find_first_available_network(parent_network, used_network_list, minimum_host_bits) == \
        ipaddress.IPv4Network('10.0.0.0/16')


def test_find_first_available_network_with_no_matching_subnets():
    minimum_host_bits = '16'
    parent_network = ipaddress.IPv4Network('10.0.0.0/8')
    used_network_list = [
        ipaddress.IPv4Network('192.168.1.0/24'),
        ipaddress.IPv4Network('192.168.2.0/24'),
    ]

    assert under_test.find_first_available_network(parent_network, used_network_list, minimum_host_bits) == \
        ipaddress.IPv4Network('10.0.0.0/16')


def test_find_first_available_network_throws_if_exhausted():
    minimum_host_bits = '16'
    parent_network = ipaddress.IPv4Network('10.0.0.0/8')
    used_network_list = [
        ipaddress.IPv4Network('10.0.0.0/8'),
    ]

    with pytest.raises(Exception):
        under_test.find_first_available_network(parent_network, used_network_list, minimum_host_bits)


@pytest.mark.integration("run with `pytest -v -m integration` if desired")
def test_find_network():
    assert under_test.find_network(
        'vpc-06d96f4ab8606fa67',
        'us-east-2',
        'arn:aws:iam::068920858268:role/admin_role',
        ipaddress.IPv4Network('10.0.0.0/8'),
        '16'
    ) == ipaddress.IPv4Network('10.1.0.0/16')


@pytest.mark.integration("run with `pytest -v -m integration` if desired")
def test_assume_role():
    under_test.set_default_region('us-west-2')

    assert 'arn:aws:sts::068920858268:assumed-role/admin_role/' in under_test.assume_role('arn:aws:iam::068920858268:role/admin_role')


def _setup_vpc_peering(region, cidr_blocks):
    client = boto3.client('ec2', region)
    account_number = boto3.client('sts').get_caller_identity()['Account']

    def _create_vpc(cidr_block):
        return client.create_vpc(
            CidrBlock=cidr_block
        ).get('Vpc', {}).get('VpcId')

    def _peer_vpc(accepter_vpc, requester_vpc):
        return client.create_vpc_peering_connection(
            PeerOwnerId=account_number,
            VpcId=requester_vpc,
            PeerVpcId=accepter_vpc,
            PeerRegion=region
        ).get('VpcPeeringConnection', {}).get('VpcPeeringConnectionId')

    vpc_ids = list(map(_create_vpc, cidr_blocks))
    list(map(partial(_peer_vpc, vpc_ids[0]), vpc_ids[1:]))

    return vpc_ids[0]
