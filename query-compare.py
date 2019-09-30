#!/usr/bin/env python3
#
# Copyright (C) 2019 Dmitry Marakasov <amdmi3@amdmi3.ru>
#
# This file is part of repology
#
# repology is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# repology is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with repology.  If not, see <http://www.gnu.org/licenses/>.

import argparse
import sys
from urllib.parse import urlencode

import requests


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('-a', '--instance-a', default='https://repology.org', help='instance A for comparison')
    parser.add_argument('-b', '--instance-b', default='http://127.0.0.1:5000', help='instance B for comparison')
    parser.add_argument('--search', type=str, help='search condition')
    parser.add_argument('--maintainer', type=str, help='maintainer condition')
    parser.add_argument('--category', type=str, help='category condition')
    parser.add_argument('--inrepo', type=str, help='inrepo condition')
    parser.add_argument('--notinrepo', type=str, help='notinrepo condition')
    parser.add_argument('--repos', type=int, help='repos condition')
    parser.add_argument('--families', type=int, help='families condition')
    parser.add_argument('--repos-newest', type=int, help='repos newest condition')
    parser.add_argument('--families-newest', type=int, help='families newest condition')
    parser.add_argument('--newest', action='store_true', help='newest condition')
    parser.add_argument('--outdated', action='store_true', help='outdated condition')
    parser.add_argument('--problematic', action='store_true', help='problematic condition')
    parser.add_argument('--has-related', action='store_true', help='has_related condition')

    return parser.parse_args()


def repology_fetch_all(instance, query):
    merged = {}

    pivot = None

    while True:
        if pivot is None:
            url = '{}/api/v1/projects/?{}'.format(instance, urlencode(query))
        else:
            url = '{}/api/v1/projects/{}/?{}'.format(instance, pivot, urlencode(query))

        res = requests.get(url).json()

        merged.update(res)

        pivot = max(res.keys())

        if len(res) == 1:
            return merged


def main() -> int:
    options = parse_arguments()

    query = {}

    for arg, value in options.__dict__.items():
        if arg in ['instance_a', 'instance_b']:
            continue

        if value is True:
            query[arg] = 1
        elif value is False or value is None:
            pass
        else:
            query[arg] = value

    projs_a = set(repology_fetch_all(options.instance_a, query).keys())
    projs_b = set(repology_fetch_all(options.instance_b, query).keys())

    for project in sorted(projs_a - projs_b):
        print('-' + project)
    for project in sorted(projs_b - projs_a):
        print('+' + project)

    return 0


if __name__ == '__main__':
    sys.exit(main())
