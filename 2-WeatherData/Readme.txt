
CHIRPS Data Download Script(Chirps.py): Automate the downloading of CHIRPS climatic data for a given period.
  -      Prerequisites: Python 3.x, Libraries: requests, pandas, numpy, concurrent.futures, datetime.
  -      Inputs: Start (dt_s) and end (dt_e) dates in YYYY-MM-DD format.
  -      Outputs: CHIRPS data files downloaded in "C:/CCAFSToolkit/WeatherData/", subdirectory "in_nc_cor".

  -      How It Works: - It creates HTTP sessions to manage download requests with reconnection attempts in the event of failure.
              - It divides the specified period between dt_s and dt_e into parts to facilitate parallel downloading of CHIRPS data.
              - It checks whether the data files for each month requested already exist locally, to avoid unnecessary downloads.
              - It downloads the CHIRPS data and saves them in the specified folder, creating the necessary folders if they don't exist.
 -       How to run it: open the anaconda terminal and Run it. Example: python main_v3.py chirps 20000101 20001231


Téléchargement des Données NASA (GetNasa.py) : This script automatically downloads climate data from NASAPOWER for a given period.
   - Inputs: Start date (startDate) and end date (endDate) in YYYY-MM-DD format and a csv file containing the geographical coordinates 
             and CELLID of each point to be downloaded.
   - Outputs: NASAPOWER data files downloaded to C:/CCAFSToolkit/WeatherData/nasap/.Each file is named by identifier (CELLID) and contains weather variables, 
	      longitude and latitude.
   - How It Works: The download function downloads daily climate data from the NASA POWER API for specific points, using latitude, longitude, 
		   and a period between startDate and endDate.
		   Split and parallel processing: For large data sets, the script divides the input file into smaller parts and processes them in parallel.
		   After downloading, a check ensures that all the necessary files have been correctly downloaded, otherwise any missing files are re-downloaded.
  - How to run it: exple: python main_v3.py nasaP "C:/CCAFSToolkit/WeatherData/InputFile/Input500.csv" 20000101 20001231

Weather Data Fusion Script()
	- CHIRPS Data Processing: Processes CHIRPS precipitation data, ensuring it is ready for fusion with NASA POWER data.
	- Data Fusion: Merges the processed NASA POWER and CHIRPS data into a single dataset.
	- DSSAT-Compatible Output: Outputs the merged dataset in a format compatible with the DSSAT/CRAFT crop modeling software.
	- Prerequisites: Python 3.x, Libraries: osgeo, gdal, numpy, pandas, datetime, joblib, requests, dateutil, argparse, shutil, concurrent.futures, queue, threading, time, logging
	- Configuration Options:
		- user_input: Path to the input CSV file containing location data for which weather data is required.
		- out_dir: Output directory where the merged weather data file will be saved.

	- - Run the Script: Execute the script from your command line. Example: python main_v3.py merging "C:/CCAFSToolkit/WeatherData/InputFile/Input500.csv" "C:/CCAFSToolkit/WeatherData/Data/"