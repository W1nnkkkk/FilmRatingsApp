def translate_key_for_json(word):
    result = 'starring'
    if word == 'Название':
        result = 'name'
    elif word == 'Оригинальное название':
        result = 'originalName'
    elif word == 'Год':
        result = 'year'
    elif word == 'Дата выхода':
        result = 'releaseDate'
    elif word == 'Страна':
        result = 'country'
    elif word == 'Режиссер':
        result = 'director'
    elif word == 'Жанр':
        result = 'genre'
    elif word == 'Время':
        result = 'duration'
    elif word == 'В главных ролях':
        result == 'starring'
    return result