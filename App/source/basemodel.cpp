#include "basemodel.h"
#include <QJsonObject>

BaseModel::BaseModel(QObject *parent) :
    QAbstractListModel(parent)
{}

void BaseModel::append(const QJsonArray &newData) {
    beginResetModel();
    for (const QJsonValue &value : newData) {
        if (value.isObject()) {
            QHash<QString, QString> hash;
            QJsonObject jsonObject = value.toObject();
            for (auto it = jsonObject.begin(); it != jsonObject.end(); ++it) {
                if (it.value().isArray()) {
                    QString val;
                    for (int i = 0; i < it.value().toArray().size() ; i++) {
                        if (i + 1 == it.value().toArray().size()) {
                            val += it.value().toArray()[i].toString();
                        }
                        else {
                            val += it.value().toArray()[i].toString() + ", ";
                        }
                    }
                    hash.insert(it.key(), val);
                }
                else {
                    hash.insert(it.key(), it.value().toString());
                }
            }
            m_data.append(hash);
        }
    }
    endResetModel();
}

void BaseModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
}

QVariant BaseModel::data(const QModelIndex &index, int role) const {
    if (index.isValid()) {
        const QHash<QString, QString> &hash = m_data.at(index.row());

        switch (role) {
        case IdRole:
            return hash.value("Id");
        case ImageRole:
            return hash.value("Image");
        case NameRole:
            return hash.value("Name");
        case OriginalNameRole:
            return hash.value("OriginalName");
        case YearRole:
            return hash.value("Year");
        case ReleaseDateRole:
            return hash.value("ReleaseDate");
        case CountryRole:
            return hash.value("Country");
        case DirectorRole:
            return hash.value("Director");
        case GenreRole:
            return hash.value("Genre");
        case DurationRole:
            return hash.value("Duration");
        case StarringRole:
            return hash.value("Starring");
        case ReviewRole:
            return hash.value("Review");
        default:
            return QVariant();
        }
    }
    return QVariant();
}

int BaseModel::rowCount(const QModelIndex &parent) const {
    return m_data.size();
}

QHash<int, QByteArray> BaseModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[ImageRole] = "image";
    roles[NameRole] = "name";
    roles[OriginalNameRole] = "originalName";
    roles[YearRole] = "year";
    roles[ReleaseDateRole] = "releaseDate";
    roles[CountryRole] = "country";
    roles[DirectorRole] = "director";
    roles[GenreRole] = "genre";
    roles[DurationRole] = "duration";
    roles[StarringRole] = "starring";
    roles[ReviewRole] = "review";
    return roles;
}
