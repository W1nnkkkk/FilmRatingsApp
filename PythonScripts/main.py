# -- coding: utf-8 --

import requests
import json
from bs4 import BeautifulSoup
import pandas as pd
from translate import translate_key_for_json
from concurrent.futures import ThreadPoolExecutor
import os

def merge_json_files(directory, output_filename):
  data = []
  for filename in os.listdir(directory):
    if filename.endswith(".json"):
      filepath = os.path.join(directory, filename)
      with open(filepath, 'r', encoding='utf-8') as f:
        try:
          json_data = json.load(f)
          data.append(json_data)
        except json.JSONDecodeError:
          print(f"Ошибка декодирования JSON: {filename}")

  with open(output_filename, 'w', encoding='utf-8') as outfile:
    json.dump(data, outfile, indent=4, ensure_ascii=False)

def main():

    merge_json_files('data', 'movie.json')

    # df = pd.read_excel('urls.xlsx')
    # links = df['Url'].tolist()
    # with ThreadPoolExecutor() as executor:
    #     results = executor.map(parse_exel_data, links)
    #     for result in results:
    #         print(result)
    # dFrame = pd.DataFrame(movies)
    # dFrame.to_csv('movies.csv', index=False)


def parse_kinopoisk(url):
    response = requests.get(url)
    response.raise_for_status()  # Проверка на ошибки запроса

    soup = BeautifulSoup(response.content, 'html.parser')
    global movies

    for film in soup.find_all('div', class_='shortpost'):
        movie = {}
        url = film.find('div', class_='postcover')
        movie['Url'] = url.a['href']
        
        movies.append(movie)

def create_excel(movies):
    """Создает Excel-таблицу с информацией о фильмах."""
    df = pd.DataFrame(movies)
    df.to_excel('urls.xlsx', index=False)

def parse_exel_data(url):
    response = requests.get(url)
    response.raise_for_status() 

    global movies
    movies.clear()

    soup = BeautifulSoup(response.content, 'html.parser')
    for film_data in soup.find_all('div', class_='postdata clearfix'):
        movie = {}
        image = film_data.find('div', class_='mobile_cover').img['data-src']
        movie['image'] = 'https://nu.baksino.website' + image
        
        description = film_data.find('div', class_='info')
        
        table = description.find("table")
        for row in table.find_all("tr"):
            cells = row.find_all("td")
            if len(cells) == 2:
                key = cells[0].text.strip()
                value = cells[1].text.strip()
                if key == "Год":
                    value = value.split("/")[0].strip()
                elif '/' in value:
                    value = list(map(str.strip, value.split('/')))
                elif ', ' in value:
                    value = list(map(str.strip, value.split(', ')))
                elif key in ["Качество:", "Слоган:"]:
                    continue
                movie[translate_key_for_json(key[:len(key) - 1])] = value
        
        print(movie)
        print('\n')
        name_file = ""
        if (type(movie['name']) == list):
            name_file = movie['name'][0][:255]
        else:
            name_file = movie['name'][:255]
        with open(('data/' + name_file + '.json'), "w") as f:
            json.dump(movie, f, ensure_ascii=False, indent=4)
        movies.append(movie)
     
if __name__ == "__main__":
    main()

    