#!/usr/bin/env python3

import sys
import os
import csv
import argparse

import frontmatter as fm

import ndlpy.talk as nt

since_year = 2016

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("listtype",
                        type=str,
                        choices=['talks', 'grants', 'extalks', 'teaching', 'students', 'exstudents', 'pdras', 'expdras'],
                        help="The type of output markdown list")

    parser.add_argument("-o", "--output", type=str,
                        help="Output filename")

    parser.add_argument('file', type=argparse.FileType('r'), nargs='+',
                        help="The file names to read in")
    
    args = parser.parse_args()


    entries = []
    for file in args.file:
        name, ext = os.path.splitext(file.name)
        ext = ext[1:]
        if ext == 'yaml' or ext == 'md' or ext == 'markdown' or ext == 'html':
            metadata, _ = fm.parse(file.read())
            file.close()
            entries.append(metadata)
        elif ext == 'csv':
            csv_entries = csv.DictReader(file)
            file.close()
            entries += csv_entries

    text = ''
    if args.listtype=="talks":
        for entry in entries:
            year = int(entry['date'].strftime('%Y'))
            if year>=since_year:
                text +=  "* *{venue}*, {month}, {year}\n".format(venue=entry['venue'], month=entry['date'].strftime('%B'), year=year)


    with open(args.output, 'w', encoding='utf-8') as f:
        f.write(text)

if __name__ == "__main__":
    sys.exit(main())
