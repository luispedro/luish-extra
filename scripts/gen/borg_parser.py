"""borg's parser, for argparse_dump.py: `python argparse_dump.py --tree borg_parser.py parser`."""


def parser():
    from borg.archiver import Archiver
    return Archiver().build_parser()
