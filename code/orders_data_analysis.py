# %%

import kagglehub
import os
import shutil
import pandas as pd
import sqlalchemy as sal
from sqlalchemy import Numeric
# %%

# Baixa o dataset
path = kagglehub.dataset_download("ankitbansal06/retail-orders")

# Caminho da pasta
dest_path = os.path.join(os.getcwd(), "../data")

# Cria pasta se não existir
os.makedirs(dest_path, exist_ok=True)

# Copia os arquivos do cache para a pasta
for filename in os.listdir(path):
    full_file_name = os.path.join(path, filename)
    if os.path.isfile(full_file_name):
        shutil.copy(full_file_name, dest_path)

print(f"Arquivos copiados para: {dest_path}")
# %%

# Carregando dataset
df = pd.read_csv("../data/orders.csv")
df.head()
# %%

# Identificando valores nulos
df["Ship Mode"].unique()
# %%

df.isnull().sum()
# %%

# Tratando valores nulos que estão com outro nome
df = pd.read_csv("../data/orders.csv", na_values=['Not Available', 'unknown'])
df.head()
# %%
df["Ship Mode"].unique()
# %%

df.isnull().sum()
# %%

# Formatando os atributos
df.columns = df.columns.str.lower()
df.columns = df.columns.str.replace(' ', '_')
df.columns
# %%

# Calculando novos atributos relevantes
df['discount_value'] = df['list_price'] * (df['discount_percent'] / 100).round(2)
df['sale_price'] = df['list_price'] - df['discount_value'].round(2)
df['profit'] = (df['sale_price'] - df['cost_price']).round(2)
df.head()
# %%

df.dtypes
# %%

# Convertendo data para datetime
df['order_date'] = pd.to_datetime(df['order_date'], format="%Y-%m-%d")
df.dtypes
# %%

# Criando engine SQL
engine = sal.create_engine("sqlite:///../data/orders.db") 
# %%

# Carregando dados no banco de dados
df.to_sql(
    'df_orders', 
    con=engine, 
    index=False, 
    if_exists='replace',
    dtype={
        'discount_value': Numeric(7, 2),
        'sale_price': Numeric(7, 2),  # Simula DECIMAL(7,2)
        'profit': Numeric(7, 2),
    }
)
# %%
