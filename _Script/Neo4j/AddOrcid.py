import random, string
import pandas as pd
import os
from numpy import NaN

def orcid(row):
    if row is not NaN:
        return row
    return''.join(random.choice(string.digits) for _ in range(4))+"-"+''.join(random.choice(string.digits) for _ in range(4))+"-"+''.join(random.choice(string.digits) for _ in range(4))+"-"+''.join(random.choice(string.digits) for _ in range(4))

df = pd.read_csv(os.getcwd()+"/Datasets/authors.csv",delimiter="|")
df["orcid"] = df["orcid"].apply(lambda x: orcid(x))
df.to_csv("Datasets/authors_Orcid.csv")