import pkgconf
import sys
from collections import defaultdict
from pprint import pprint

cli = pkgconf.Client()
queue = cli.queue()

depth = 0

if len(sys.argv) < 2:
    print('usage: collect_fragments <package> [package]')
    exit()

[queue.push(i) for i in sys.argv[1:]]
fl = list(queue.cflags(True))
fl += list(queue.libs(True))

frags_by_kind = defaultdict(list)
[frags_by_kind[k].append(v) for k, v in fl]

pprint(frags_by_kind)
