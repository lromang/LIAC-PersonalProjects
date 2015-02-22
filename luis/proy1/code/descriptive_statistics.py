import pandas as pd
import matplotlib.pyplot as plt
import scipy
import os
from igraph import *
import networkx as nx
os.chdir('/home/lgarcia/LIAC/projects/luis/proy1')
distancias = pd.read_csv('./data/ecobici_distancias.csv')
estaciones = pd.read_csv('./data/ecobici_estaciones.csv')
# Creamos gráfica
g =nx.Graph()

for i  in range(estaciones.shape[0]):
    g.add_node("i")

for i in range(distancias.shape[0]):
    g.add_edge( distancias.iloc[i][0],
                        distancias.iloc[i][1])

plt.figure(figsize=(8,8))
# with nodes colored by degree sized by population
node_color=[float(g.degree(v)) for v in g]
nx.draw(g,
     edge_size =[ for v in H],,
     node_color=node_color,
     with_labels=False)

# scale the axes equally
plt.xlim(-5000,500)
plt.ylim(-2000,3500)
plt.savefig("knuth_miles.png")



