"""
External data provider for terraform. When given a set of parameters (in stringified json), it will:
- find the first available cidr block that is not used by peers or the alm itself

Example call:
echo '{"alm_vpc_id":"vpc-06d96f4ab8606fa67", "alm_region":"us-east-2","alm_role_arn":"arn:aws:iam::068920858268:role/admin_role", "parent_network":"10.0.0.0/8", "minimum_host_bits":"16"}' | python3 first_available_cidr_block.py

Example response:
{"cidr_block":"10.1.0.0/16"}

"""
import botocore.session
import ipaddress
import sys
import json
from uuid import uuid4

session = botocore.session.get_session()


def main():
    """
    Ye olde main function

    Converts to and from strings to domain objects
    """
    parameters = json.load(
        sys.stdin
    )

    found_network = find_network(
        parameters.get('alm_vpc_id'),
        parameters.get('alm_region'),
        parameters.get('alm_role_arn'),
        ipaddress.IPv4Network(parameters.get('parent_network')),
        parameters.get('minimum_host_bits')
    )

    sys.stdout.write(
        json.dumps(
            {
                "cidr_block": str(found_network)
            }
        )
    )


def find_network(alm_vpc_id, alm_region, alm_role_arn, parent_network, minimum_host_bits):
    """
    The actual main function of the module that ties everything together
    """
    set_default_region(alm_region)
    assume_role(alm_role_arn)

    return find_first_available_network(
        parent_network,
        get_used_networks(alm_vpc_id),
        minimum_host_bits
    )


def get_used_networks(alm_vpc_id):
    """
    Combines the VPC CIDR block with and its peer CIDR blocks to form a list of reserved networks
    """
    def _extract_requester_cidr_blocks(peering_connection):
        return _extract_cidr_block(
            peering_connection.get('RequesterVpcInfo', {})
        )

    def _extract_cidr_block(vpc):
        return vpc.get('CidrBlock')

    def _is_a_valid_value(cidr_block):
        return cidr_block is not None

    peer_connections = _get_peer_connections(alm_vpc_id)
    alm_vpcs = _get_matching_alm_vpcs(alm_vpc_id)

    requester_cidr_blocks = list(map(_extract_requester_cidr_blocks, peer_connections))
    alm_cidr_blocks = list(map(_extract_cidr_block, alm_vpcs))
    filtered_cidr_blocks = list(filter(_is_a_valid_value, requester_cidr_blocks + alm_cidr_blocks))

    return list(map(ipaddress.IPv4Network, filtered_cidr_blocks))


def find_first_available_network(parent_network, used_network_list, minimum_host_bits):
    """
    Given a list of already used networks, this will find the first one of a certain size within a supernet
    """
    def _is_not_already_used(network):
        return not any(network.overlaps(x) for x in used_network_list)

    all_subnets = parent_network.subnets(new_prefix=int(minimum_host_bits))
    return next(filter(_is_not_already_used, all_subnets))


def set_default_region(region):
    """
    Sets the region for the entire session so we don't have to set it every time we create a client
    """
    session.set_default_client_config(
        botocore.config.Config(region_name=region)
    )


def assume_role(role_arn):
    """
    Assumes a role for the entire session so we don't have to set it every time we create a client
    """
    sts_client = session.create_client('sts')
    credentials = sts_client.assume_role(
        RoleArn=role_arn,
        RoleSessionName=str(uuid4())
    ).get('Credentials')

    session.set_credentials(
        credentials.get('AccessKeyId'),
        credentials.get('SecretAccessKey'),
        credentials.get('SessionToken')
    )

    return session.create_client('sts').get_caller_identity().get('Arn')


def _get_peer_connections(alm_vpc_id):
    return session.create_client('ec2').describe_vpc_peering_connections(
        Filters=[
            {
                'Name': 'status-code',
                'Values': ['active']
            },
            {
                'Name': 'accepter-vpc-info.vpc-id',
                'Values': [alm_vpc_id]
            }
        ]
    ).get('VpcPeeringConnections', [])


def _get_matching_alm_vpcs(alm_vpc_id):
    return session.create_client('ec2').describe_vpcs(
        Filters=[
            {
                "Name": "vpc-id",
                "Values": [
                    alm_vpc_id
                ]
            }
        ]
    ).get('Vpcs', [])


if __name__ == "__main__":
    main()