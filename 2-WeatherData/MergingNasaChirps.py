# -*- coding: utf-8 -*-
"""
Created on Wed Feb  7 12:52:59 2024

@author: youedraogo
"""


#from ChirpsPrepocessing import *
import concurrent.futures
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

# Intended for long time series but few points (<10000)
def chirps1(in_file, in_nc_dir, outprec_file):
    nc_lst = os.listdir(in_nc_dir)  # Retrieve the list of all .sol files in the input folder.
    nc_lst.sort()  # Sort the files in chronological order.
    df_chirps = pd.DataFrame()  # Create an empty DataFrame to store precipitation data.

    with open(in_file, "r") as f1:
        
        in_pt = [line for line in f1.readlines() if line.strip()]  # Read lines from the input file, excluding empty lines.

        for row in in_pt[1:]:
            id = int(row.split(',')[0])  # Get the ID from the first column.
            lat = float(row.split(',')[1])  # Get the latitude from the second column.
            lon = float(row.split(',')[2])  # Get the longitude from the third column.
            time_lst = []  # List to store time values.
            precval = []  # List to store precipitation values.

            for nc_file in nc_lst:
                if nc_file.endswith(".nc"):  # Check if the file is in NetCDF format.
                    dsi = gdal.Open(in_nc_dir + "/" + nc_file, GA_ReadOnly)  # Open the NetCDF file in read-only mode.
                    if dsi is None:
                        print('Could not open NetCDF file')
                        sys.exit(1)  # Print an error message and exit if the file cannot be opened.
                    meta_nc = dsi.GetMetadata()  # Get the metadata of the NetCDF file.
                    date_start = meta_nc['time#units'][-14:]  # Get the start date from the metadata.
                    datetime_st = datetime.strptime(date_start, '%Y-%m-%d %H:%M:%S')  # Convert the start date to a datetime object.
                    bands_time = meta_nc['NETCDF_DIM_time_VALUES'][1:-1].split(',')  # Get the time dimension values.
                    bands_time = list(map(int, bands_time))  # Convert the values to integers.

                    gt = dsi.GetGeoTransform()  # Get the geotransformation of the NetCDF file.
                    px = int((lon - gt[0]) / gt[1])  # Calculate the X coordinate of the pixel corresponding to the longitude.
                    py = int((lat - gt[3]) / gt[5])  # Calculate the Y coordinate of the pixel corresponding to the latitude.
                    bands = dsi.RasterCount  # Get the number of bands in the NetCDF file.

                    for i in range(1, bands + 1):
                        d = dsi.GetRasterBand(i).ReadAsArray(px, py, 1, 1)  # Read the precipitation value for the given pixel.
                        dt_st = datetime_st + timedelta(days=bands_time[i - 1])  # Calculate the date corresponding to the band.
                        band_t = dt_st.strftime('%Y%j')  # Convert the date to YJJJ format (year and day of the year).
                        time_lst.append(band_t)  # Add the time value to the list.
                        if d is None:
                            d = numpy.float32([[-9999.0]])  # Replace missing values with a specific code.
                        precval.append(d[0][0])  # Add the precipitation value to the list.

            df_chirps[id] = precval  # Associate the list of precipitation values with the ID in the DataFrame.

    df_chirps = df_chirps.T  # Transpose the DataFrame to have dates as columns.
    df_chirps.index.name = 'ID'  # Assign a name to the DataFrame's index.
    df_chirps.columns = time_lst  # Associate the time values with column names.

    if not os.path.exists(os.path.dirname(outprec_file)):
        os.mkdir(os.path.dirname(outprec_file))  # Create the destination directory of the output file if it doesn't exist.
    joblib.dump(df_chirps, outprec_file)  # Save the DataFrame to a file in pickle format.

#in_nc_dir = "F:/Data20/"
#in_file =outprec_file= "F:/nnn/Input500.csv"
#chirps1(in_file, in_nc_dir, outprec_file)


def precpkl(outdir_prec):
    # Load the "prec_corr.pkl" file into a dataframe df1
    df1 = joblib.load(outdir_prec + '/prec_corr.pkl')
    
    # Load the "prec_prelim.pkl" file into a dataframe df2
    df2 = joblib.load(outdir_prec + '/prec_prelim.pkl')
    
    # Extract the last date from the df1 dataframe (last column)
    last_dt_corr = df1.columns[-1]
    
    # Calculate the next date based on the last corrected date
    dt_s_pre = datetime.strptime(last_dt_corr, '%Y%j') + timedelta(days=1)
    
    # Convert the next date to a string format
    dt_st_p = dt_s_pre.strftime('%Y%j')
    
    # Select the columns from the df2 dataframe starting from the next date
    df3 = df2.loc[:, dt_st_p:]
    
    # Concatenate df1 and df3 dataframes along the column axis
    result = pd.concat([df1, df3], axis=1)
    
    # Save the result dataframe to a "prec.pkl" pkl file
    joblib.dump(result, outdir_prec + '/prec.pkl')




#Function to merge NASAPOWER and CHIRPS data, including the quality control for SRAD.
def nasachirps(user_input,nasa_outdir, chirps_input, out_dir):
    # I've also added startDate and endDate as input to allow the NASA function 
    # to work.
    #nasa(user_input, startDate, endDate, nasa_outdir)
    nasa_outdir = "C:/CCAFSToolkit/WeatherData/nasap/"

    df_prec = joblib.load(chirps_input)
    df_prec = df_prec.sort_index(axis=1)
    d = df_prec.columns.values.tolist()  # All dates available in CHIRPS
    ids_ch = df_prec.index.values.tolist()  # All IDs available in CHIRPS

    s1 = '{:>6} {:>9} {:>9} {:>7} {:>5} {:>5} {:>5} {:>5}'
    hdr1 = s1.format("@ INSI", "LAT", "LONG", "ELEV", "TAV", "AMP", "REFHT", "WNDHT" + "\n")
    s2 = '{:>7} {:>5} {:>5} {:>6} {:>6}'
    #hdr3 = s2.format("DATE", "TMIN","TMAX", "SRAD", "RAIN")
    hdr3 = "DATE\tTMIN\tTMAX\tSRAD\tRAIN"

    try:
        pt = pd.read_csv(user_input)
        if out_dir is None:
            out_dir = os.path.dirname(user_input) + "/DSSAT"

        # Create target Directory if doesn't exist
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        else:
            print("Directory ", out_dir, " already exists. Data will be overwritten")

        if nasa_outdir is None:
            nasa_outdir = os.path.dirname(user_input) + "/NASAP"

        for index, row in pt.iterrows():

            id = int(row['ID'])
            lat = round(row['Latitude'], 5)
            lon = round(row['Longitude'], 5)
            nasa_id = str(int(row['ID']))

            with open(nasa_outdir + "/" + nasa_id + ".WTH", "r") as f1:  # Reading nasap files
                data = [line for line in f1.readlines() if line.strip()]
                hdr2 = data[11].split()
                solar = [sr.split()[8] for sr in data[13:]]  # To get solar radiation values
                i_srad = [i for i, e in enumerate(solar) if
                          e == 'nan' or e == '-99' or e == '-99.0' or e == '-3596.4']  # To find missing srad values

                with open(out_dir + "/" + str(id) + ".WTH", "w") as f2:  # Writing requested files
                    f2.write(hdr3 + '\n')  # Writing the header

                    for index2, row in enumerate(data[13:]):
                        c = 0  # Controls when to cutoff the end of weather file. c=1 means, the script stops writing rows.
                        r = row.split()  # row of values one line at a time

                        # SRAD quality control
                        if index2 in i_srad:
                            if ((index2 + 1 in i_srad) and (
                                    index2 + 2 in i_srad) and index2 == 0):  # Three first consecutive records have srad missing values
                                break
                            if ((
                                    index2 + 1 in i_srad) and index2 == 0):  # Two first consecutive records have srad missing values
                                break
                            if (len(data[
                                    13:]) == 1):  # The first record has srad missing value and there is no more data
                                break
                            if ((index2 + 1 in i_srad) and (index2 + 2 in i_srad)):
                                SRAD2 = solar[index2 - 1]  # Three consecutive records have srad missing values
                                c = 1
                            elif ((index2 + 1) in i_srad and (index2 + 2) == len(data[13:])):
                                SRAD2 = solar[index2 - 1]  # Two last records have srad missing values
                                c = 1
                            elif (index2 + 1) in i_srad:  # Two consecutive missing values. First value
                                SRAD2 = round(float(solar[index2 - 1]) + (
                                        float(solar[index2 + 2]) - float(solar[index2 - 1])) / 3, 1)
                            elif (index2 - 1) in i_srad:  # Two consecutive missing values. Second value
                                SRAD2 = round(float(solar[index2 - 2]) + 2 * (
                                        float(solar[index2 + 1]) - float(solar[index2 - 2])) / 3, 1)
                            elif (index2 + 1) == len(data[13:]):  # The last record has a srad missing value
                                SRAD2 = solar[index2 - 1]
                            elif (index2 == 0):  # The first record has a srad missing value but the next has valid data
                                SRAD2 = solar[index2 + 1]
                            else:
                                SRAD2 = round((float(solar[index2 - 1]) + float(solar[index2 + 1])) / 2,
                                              1)  # One consecutive missing value
                        else:
                            SRAD2 = r[8]  # To keep the original (no missing) value

                        if (r[0] in d) and (
                                id in ids_ch):  # Evaluates if date from NASA file (r[0]) is in list of dates available in dates of chirps (d) and if the ID is in the CHIRPS
                            #                            start4 = datetime.now()

                            RAIN_CHIRPS = df_prec.loc[id, r[0]]

                            if RAIN_CHIRPS == -9999.0:
                                RAIN = r[6]
                            else:
                                RAIN = round(float(RAIN_CHIRPS), 1)
                        else:
                            RAIN = r[6]

                        #f2.write(s2.format(r[0], r[2], r[3], SRAD2, RAIN) + '\n')
                        f2.write(f"{r[0]}\t{r[2]}\t{r[3]}\t{SRAD2}\t{RAIN}\n")  # Use '\t' as the separator
                        if c == 1:
                            break

    except KeyboardInterrupt:
        sys.exit(1)
        
        
def dssat_wth(in_file, out_dir):
    s1 = datetime.now()

    print('Getting NASA POWER data and corrected data...')
    
    nasa_outdir = "C:/CCAFSToolkit/WeatherData/nasap/"
    out_cor_nc = "C:/CCAFSToolkit/WeatherData/in_nc_cor/"

    #Run chirps for corrected data
    
    outdir_prec= "C:/CCAFSToolkit/WeatherData/prec_pkl/"
    print('Processing CHIRPS data...')
    chirps1(in_file, out_cor_nc, outdir_prec + '/prec.pkl')

    #Fusing NASA POWER and CHIRPS with QC on SRAD.
    print('Fusing NASA POWER and CHIRPS...')
    
    nasachirps(in_file, nasa_outdir, outdir_prec + '/prec.pkl', out_dir)
    e1 = datetime.now()
    print("Time for execution is: ", str(e1-s1))
    
    
    
#in_file  = "C:/CCAFSToolkit/Data/Input500.csv"
#startDate = 19910101
#endDate = 19911231
#out_dir = "C:/CCAFSToolkit/WeatherData/Data/"

