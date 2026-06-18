import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

load_dotenv()

DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_NAME = os.getenv("POSTGRES_DB")
DB_PORT = os.getenv("POSTGRES_PORT")
DB_HOST = "localhost"  

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

def load_dataset():
    data_dir = "data"
    files = [f for f in os.listdir(data_dir) if f.endswith(('.csv', '.xlsx', '.xls'))]
    
    if not files:
        print("Ошибка: В папочке 'data/' не найдено файлов формата CSV или Excel.")
        return
    
    file_name = files[0]
    file_path = os.path.join(data_dir, file_name)
    print(f"Обнаружен файл: {file_path}. Начинаем чтение...")
    
    if file_name.endswith('.csv'):
        df = pd.read_csv(file_path)
    else:
        df = pd.read_excel(file_path)
        
    print(f"Файл успешно прочитан. Строк: {df.shape[0]}, Столбцов: {df.shape[1]}")
    
    engine = create_engine(DATABASE_URL)
    
    table_name = "user_deposits"
    
    print(f"Загрузка данных в PostgreSQL (схема: raw, таблица: {table_name})...")
    
    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists="replace",
        index=False
    )
    
    print("Данные успешно загружены в базу!")

if __name__ == "__main__":
    load_dataset()