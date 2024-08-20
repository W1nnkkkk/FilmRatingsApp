# -- coding: utf-8 --
import base64
import time
from concurrent.futures import ThreadPoolExecutor
import requests
from bs4 import BeautifulSoup
import pandas as pd
from fake_useragent import UserAgent
from MongoConnClass import MongoEntity


main_url = "https://kino.mail.ru"
extra_url = "/cinema/online"
main_url_next_page = "?page="
uri = []
mongo_descriptor = MongoEntity()
server = "http://127.0.0.1:7979"


def main():

    # parse_site_to_films_uri(main_url + extra_url)
    # for i in range(2, 119):
    #     parse_site_to_films_uri(main_url + extra_url + main_url_next_page + str(i))
    #
    # create_exel_file('URL', uri)

    df = pd.read_excel('urls.xlsx')

    links = df['URL'].tolist()

    for link in links:
        parse_table_data_and_insert_into_mongo(link)


def parse_table_data_and_insert_into_mongo(url):
    response = requests.get(url)
    response.raise_for_status()

    print(url)

    soup = BeautifulSoup(response.content, 'html.parser')
    film_data = soup.find('div', class_='p-movie-info')
    image = (soup.find("img", class_="picture__image picture__image_cover")["src"])
    name = soup.find("h1", class_="text text_bold_giant color_white").text
    upload_image(requests.get(image).content, server, name)

    try:
        year = film_data.find('div', class_="margin_bottom_20").find('a').text
    except Exception as err:
        print(err)
    duration = ""
    try:
        if film_data.find('span', class_="margin_left_40 nowrap").a:
            duration = "Пока нет"
        else:
            if film_data.find('span', class_="margin_left_40 nowrap").text:
                duration = film_data.find('span', class_="margin_left_40 nowrap").text
    except Exception as err:
        print(err)

    genres = []
    for genre in film_data.find_all('span', class_="badge__text"):
        genres.append(genre.text)

    country = ""
    directors = []
    starrings = []

    try:
        directors_a = (film_data.find('span', class_="p-truncate__inner js-toggle__truncate-inner")
                       .find_all('a'))
        for director in directors_a:
            directors.append(director.text)

        starring_a = (film_data.find('span', class_="p-truncate__inner js-toggle__truncate-inner")
                      .findNext('span', class_="p-truncate__inner js-toggle__truncate-inner")
                      .find_all('a'))
        for starring in starring_a:
            starrings.append(starring.text)

        country_a = (film_data.find('span', class_="p-truncate__inner js-toggle__truncate-inner")
                        .findNext('span', class_="p-truncate__inner js-toggle__truncate-inner")
                        .findNext('span', class_="p-truncate__inner js-toggle__truncate-inner")
                        .find_all('a'))

        for countries in country_a:
            country += countries.text + " "
    except Exception as err:
        print(err)

    document = {
        "image": server + "/image/" + name + ".jpg",
        "name": name,
        "originalName": "",
        "year": year,
        "country": country,
        "director": directors,
        "genre": genres,
        "duration": duration,
        "starring": starrings
    }

    print(document)
    # mongo_descriptor.add_to_collection(document=document)


def upload_image(image_data, server_url, filename):
    files = {
        "image": base64.b64encode(image_data).decode("utf-8"),
        "filename": filename
    }

    upload_response = requests.post(f"{server_url}/upload", json=files)

    if upload_response.status_code == 200:
      print(f"Картинка '{filename}' успешно загружена.")
    else:
      print(f"Ошибка загрузки: {upload_response.text}")


def parse_site_to_films_uri(url):
    response = requests.get(url)
    response.raise_for_status()

    global uri

    soup = BeautifulSoup(response.content, 'html.parser')
    for film_data in soup.find_all('a',
        class_="link link_inline link-holder link-holder_itemevent link-holder_itemevent_small"):
        uri.append(main_url + film_data['href'])


def create_exel_file(key, list_values):
    df = pd.DataFrame(list_values, columns=[key])
    df.to_excel('urls.xlsx', index=False)


if __name__ == "__main__":
    main()

    