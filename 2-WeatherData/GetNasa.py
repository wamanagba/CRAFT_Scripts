# -*- coding: utf-8 -*-
"""
Created on Wed Feb  7 09:57:00 2024

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

# Function to write the NASA data to a file
def write_nasawth(data, outdir, id):
    filename = f"{outdir}/{id}.WTH"
    with open(filename, 'w') as file:
        file.write(data)



def get_data(user_input, startDate, endDate):
    
    nasa_outdir = "C:/CCAFSToolkit/WeatherData/nasap/"
    
    
    # Function to download the data from the NASAPOWER API
    # We've made some important changes to the download function. 
      # This function now takes the start and end date as parameters
      # and also the q parameter, which represents the queue. 
      
      # In addition, we've modified the function to use Cellgrids as identifier, 
      # replacing Nasapid.
    def download(startDate,endDate,q):
        delay=0.2
        s = requests.Session()
        s.mount("https://power.larc.nasa.gov", requests.adapters.HTTPAdapter(max_retries=30))
        while True:
            pt = q.get()
            id = pt[0]
            lat = pt[1]
            lon = pt[2]
            #logging.info("Requesting data for ID: %s ", id)

            try:
                response = s.get('https://power.larc.nasa.gov/api/temporal/daily/point', params={
                    'parameters': 'T2M',
                    'community': 'AG',
                    'longitude': lon,
                    'latitude': lat,
                    'start': startDate,
                    'end': endDate,
                    'format': 'ICASA'
                }, timeout=80)
                response.raise_for_status()

            except:
                logging.info("Error for ID: %s, with code %s", id , response.status_code)
                if response.status_code == 429:
                    time.sleep(120)
            else:
                write_nasawth(response.text, nasa_outdir, id)
                logging.info("Data obtained for ID: %s ", id)

            q.task_done()
            time.sleep(delay)

    # Create target Directory if it doesn't exist
    if not os.path.exists(nasa_outdir):
        os.mkdir(nasa_outdir)
    else:
        print("Directory ", nasa_outdir, " already exists. Data will be added/overwritten")

    format = "%(asctime)s: %(message)s"
    logging.basicConfig(format=format, level=logging.INFO, datefmt="%H:%M:%S")
    NUM_THREADS = 5
    #delay = 0  # seconds
    q = queue.Queue()

    for i in range(NUM_THREADS):
        t = threading.Thread(target=download, args=(startDate,endDate,q,))
        t.daemon = True
        t.start()

    pt = pd.read_csv(user_input)
    pt = pt.sort_values(by="ID")


    try:
        for index, row in pt.iterrows():
            id = str(int(row['ID']))
            lat = round(row['Latitude'], 4)
            lon = round(row['Longitude'], 4)
            url = [id, lat, lon]
            q.put(url)
        q.join()

    except KeyboardInterrupt:
        sys.exit(1)
        

#Function to check the NASAP files requested are downloaded in disk.
def check_files(user_input):
    nasa_outdir = "C:/CCAFSToolkit/WeatherData/nasap/"
    # Getting the number of NASAP files requested.
    pt = pd.read_csv(user_input).drop_duplicates(subset=["ID"])
    pts_req = pt['ID'].to_list()
    n_pt = len(pts_req)
    print("Number of points requested:", n_pt)

    # List of files downloaded.
    wth_files = [int(x[:-4]) for x in os.listdir(nasa_outdir) if x.endswith(".WTH")]
    n_wth = len(wth_files)
    print("Number of points downloaded:", n_wth)

    m_pts = list(set(pts_req) - set(wth_files))
    if m_pts:
        return [m_pts, n_pt, n_wth, pt]
    else:
        print("All requested data were downloaded successfully.")
        return False
    
    
#Function to check that all NASAPOWER files requested are downloaded.
def get_data2(user_input,startDate, endDate, cf): 
    # I'm adding 'nasa_outdir', startDate and endDate as input for this function,
    #because the get_data function takes nasa_outdir, startDate and endDate as
    #parameters. because This was blocking code execution 
    nasa_outdir = "C:/CCAFSToolkit/WeatherData/nasap/"
    if cf[2] < cf[1]:
        print(cf[1] - cf[2], "missing file(s):", cf[0])
        pt_m = cf[3].loc[cf[3]['ID'].isin(cf[0])]
        missing_pt = os.path.dirname(user_input) + "/missing_pt.csv"
        pt_m.to_csv(missing_pt, index=False)
        get_data(missing_pt, startDate, endDate)

    elif cf[2] > cf[1]:
        print("Something is wrong with the input file index.")
        sys.exit(1)
    else:
        print("All requested files were downloaded successfully.")
        
        
        
        
        
def divide_csv(input_file, num_parts):
    # Charger le fichier CSV dans un DataFrame
    df = pd.read_csv(input_file)

    # Calculer le nombre total de lignes
    total_rows = len(df)

    # Calculer le nombre de lignes par partie (arrondi vers le haut)
    rows_per_part = -(-total_rows // num_parts)

    # Diviser le DataFrame en parties
    parts = [df.iloc[i*rows_per_part:min((i+1)*rows_per_part, total_rows)] for i in range(num_parts)]

    # Créer le préfixe du fichier de sortie dans le répertoire du fichier d'entrée
    input_directory = os.path.dirname(input_file)
    output_prefix = input_directory + "/output_files/"
    if not os.path.exists(output_prefix):
        os.mkdir(output_prefix)

    # Enregistrer chaque partie dans un fichier CSV séparé
    for i, part_df in enumerate(parts, start=1):
        output_file = f"{output_prefix}part{i}.csv"
        part_df.to_csv(output_file, index=False)
        print(f"Partie {i} enregistrée dans {output_file}")
    user_inputs = [output_prefix+'part1.csv', output_prefix+'part2.csv', output_prefix+'part3.csv', output_prefix+'part4.csv']#,output_prefix+'part5.csv', output_prefix+'part6.csv', output_prefix+'part7.csv', output_prefix+'part8.csv', output_prefix+'part9.csv', output_prefix+'part10.csv']
    return(user_inputs)


def download_nasa_data(user_input, start_date, end_date):
    print(f"Downloading NASA data for {user_input}...")
    get_data(user_input, start_date, end_date)


def nasa(input_file, start_date, end_date):
    nasa_outdir = "C:/CCAFSToolkit/WeatherData/nasap/"
    s1 = datetime.now()
    user_inputs= divide_csv(input_file, 4)
    # Download NASA data in parallel
    with concurrent.futures.ThreadPoolExecutor(max_workers=len(user_inputs)) as executor:
        executor.map(lambda user_input: download_nasa_data(user_input, start_date, end_date), user_inputs)
    cf = check_files(input_file) #To check that all files requested were downloaded.
    if cf:
        get_data2(input_file, start_date, end_date, cf) # Change for this input
        if check_files(input_file):
            print('Program terminated. Please check manually NASAPOWER server response.')
            sys.exit(1)

    e1 = datetime.now()
    print("Execution time getting NASAPOWER data: ", str(e1 - s1))
    
#in_file  = "C:/CCAFSToolkit/Data/Input500.csv"
#startDate = 19910101
#endDate = 19911231
#out_dir = "C:/CCAFSToolkit/Data/"
#nasa(in_file, startDate, endDate, out_dir)
