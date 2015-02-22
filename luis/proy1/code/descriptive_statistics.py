import pandas as pd
import matplotlib as mp
import scipy
import os
from igraph import *
os.chdir('/home/lgarcia/LIAC/projects/luis/proy1')
distancias = pd.read_csv('./data/ecobici_distancias.csv')
# Creamos gráfica
g = Graph()

