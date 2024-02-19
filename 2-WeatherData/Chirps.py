# -*- coding: utf-8 -*-
"""
Created on Wed Feb  7 09:30:38 2024

@author: youedraogo
"""
import os, sys
from osgeo import ogr, gdal
from osgeo.gdalconst import *
import numpy
import pandas as pd
from datetime import datetime, timedelta,date
import joblib
import requests
from dateutil.relativedelta import relativedelta
import argparse
import shutil
import concurrent.futures
import queue
import threading
import time
import logging
# register all of the GDAL drivers
gdal.AllRegister()


def get_correc(dt_s, dt_e, out_cor_nc):
    # Create a session for HTTP requests with custom parameters
    s = requests.Session()
    s.mount("https://data.chc.ucsb.edu", requests.adapters.HTTPAdapter(max_retries=10))

    # Calculate the difference in months between the start date and end date
    diff_month = (dt_e.year - dt_s.year) * 12 + (dt_e.month - dt_s.month)

    # Iterate over each month between the start date and end date, inclusive
    for n in range(diff_month + 1):
        # Calculate the current month by adding n months to the start date
        yymm = dt_s + relativedelta(months=+n)
        yy = yymm.strftime("%Y")  # Extract the year in "YYYY" format
        mm = yymm.strftime("%m")  # Extract the month in "MM" format

        file_name = 'corr_chirps_' + yy + mm + '.nc'  # File name to download
        file_path = os.path.join(out_cor_nc, file_name)  # Full file path

        # Check if the file already exists
        if os.path.exists(file_path):
            print(file_name + ' already exists. Skipping download.')
            continue

        try:
            # Download the file from the specified URL
            response = s.get(f'https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/netcdf/p05/by_month/chirps-v2.0.{yy}.{mm}.days_p05.nc', timeout=80)
            response.raise_for_status()  # Check if the request was successful (HTTP status code 200)

            # Create the destination folder if it doesn't already exist
            if not os.path.exists(out_cor_nc):
                os.makedirs(out_cor_nc)

            # Save the downloaded file to the destination folder
            with open(file_path, 'wb') as file:
                file.write(response.content)
            print(file_name + ' downloaded successfully.')

        except requests.exceptions.HTTPError as err:
            print(f"Failed to download {file_name}: {err}")

        finally:
            response.close()  # Close the connection with the server




def divide_period_into_parts(dt_s, dt_e, num_parts):
    total_days = (dt_e - dt_s).days
    days_per_part = total_days // num_parts

    parts = []
    current_date = dt_s.replace(day=1)  # Assurez-vous que part_start est le premier jour du mois

    for i in range(num_parts):
        part_start = current_date
        if i < num_parts - 1:
            current_date = (part_start + timedelta(days=days_per_part)).replace(day=1)
            part_end = (current_date - timedelta(days=1)).replace(day=1)
        else:
            part_end = dt_e.replace(day=1)

        parts.append((part_start, part_end))

    return parts

def get_correc_nc(dt_s, dt_e):
    
    #os.chdir(os.path.dirname(in_file))
    os.makedirs('C:/CCAFSToolkit/WeatherData/', exist_ok=True)
    tempdir = os.path.dirname('C:/CCAFSToolkit/WeatherData/temp')
    nasa_outdir= tempdir+ '/nasap'
    out_cor_nc= tempdir+ '/in_nc_cor'
    chirpsF_outdir= tempdir+ '/prec_pkl'
    os.makedirs(nasa_outdir, exist_ok=True)
    os.makedirs(out_cor_nc,exist_ok=True)
    os.makedirs(chirpsF_outdir,exist_ok=True)
    
    s11 = datetime.now()
    # Utilisez la fonction divide_period_into_parts pour obtenir les sous-périodes
    parts = divide_period_into_parts(dt_s, dt_e, 4)

    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        # Schedule the execution of get_correc_nc function for each part in parallel
        futures = [executor.submit(get_correc, part_start, part_end, out_cor_nc) for part_start, part_end in parts]

        # Wait for all futures to complete
        concurrent.futures.wait(futures)
    e11 = datetime.now()
    print("Execution time getting Chirps data: ", str(e11 - s11))



#out_dir =  "C:/CCAFSToolkit/Data/"

#get_correc_nc(startDate, endDate, out_dir)
