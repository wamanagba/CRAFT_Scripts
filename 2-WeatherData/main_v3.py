# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 16:06:59 2023

@author: win10admin
"""


from datetime import datetime, timedelta,date


from GetNasa import *
from Chirps import *
from MergingNasaChirps import *

from concurrent.futures import ThreadPoolExecutor
import concurrent.futures
#s1 = datetime.now()
import sys
import argparse
from datetime import datetime


import sys
import argparse
from datetime import datetime

def parse_date(date_string):
    try:
        return datetime.strptime(date_string, "%Y%m%d")
    except ValueError as e:
        raise argparse.ArgumentTypeError(f"Not a valid date: '{date_string}'. Error: {e}")


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest='command')
    
    get_correc_nc_parser = subparsers.add_parser('chirps')
    get_correc_nc_parser.add_argument('startDate', type=parse_date, help='Start date with format YYYYMMDD (e.g. 19841224)')
    get_correc_nc_parser.add_argument('endDate', type=parse_date, help='End date with format YYYYMMDD (e.g. 19841231)')
    #get_correc_nc_parser.add_argument('out_dir', type=str, help='Path of output directory for the new netcdf files.')
    
    nasa_parser = subparsers.add_parser('nasaP')
    nasa_parser.add_argument('in_file', type=str, help='Input CSV file for downloading NASA Data files.')
    nasa_parser.add_argument('startDate', type=int, help='Start date with format YYYYMMDD (e.g. 19841224)')
    nasa_parser.add_argument('endDate', type=int, help='End date with format YYYYMMDD (e.g. 19841231)')
    #nasa_parser.add_argument('out_dir', type=str, help='Path of output directory for NASA data files.')
    
    merge_parser = subparsers.add_parser('merging')
    merge_parser.add_argument('in_file', type=str, help='Input CSV file for downloading NASA Data files.')
    #merge_parser.add_argument('startDate', type=int, help='Start date with format YYYYMMDD (e.g. 19841224)')
    #merge_parser.add_argument('endDate', type=int, help='End date with format YYYYMMDD (e.g. 19841231)')
    merge_parser.add_argument('out_dir', type=str, help='Path of output directory for NASA data files.')

    args = parser.parse_args()

    if args.command == 'chirps':
        get_correc_nc(args.startDate, args.endDate)
    elif args.command == 'nasaP':
        nasa(args.in_file, args.startDate, args.endDate)
    elif args.command == 'merging':
        dssat_wth(args.in_file, args.out_dir)


    

if __name__ == "__main__":
    main()

    
#To download the weather data run this in the terminal:
# >python main_v3.py chirps 20000101 20001231
# >python main_v3.py nasaP "C:/CCAFSToolkit/WeatherData/InputFile/Input500.csv" 20000101 20001231
# >python main_v3.py merging "C:/CCAFSToolkit/WeatherData/InputFile/Input500.csv" "C:/CCAFSToolkit/WeatherData/Data/"
