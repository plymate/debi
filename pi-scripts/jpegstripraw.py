#!/usr/bin/env python3

import argparse
from PIL import Image

def strip_raw(infile, outfile):
    im = Image.open(infile)
    im.save(outfile, exif=im.getexif())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Copies infile to outfile stripping raw data.')
    parser.add_argument('infile', type=argparse.FileType('rb'),
        help='input file')
    parser.add_argument('outfile', type=argparse.FileType('wb'),
        help='output file')
    args = parser.parse_args()
    strip_raw(args.infile, args.outfile)


