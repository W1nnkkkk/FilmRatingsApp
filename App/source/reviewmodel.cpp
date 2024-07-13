#include "reviewmodel.h"
#include <QJsonObject>
#include <QJsonValue>
#include <QDebug>

ReviewModel::ReviewModel(QObject *parent)
    : QAbstractListModel{parent}
{}

int ReviewModel::rowCount(const QModelIndex &parent) const
{
    return m_data.size();
}

QHash<int, QByteArray> ReviewModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[ReviewRole] = "comment";
    return roles;
}

QVariant ReviewModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        const QHash<QString, QString> &hash = m_data.at(index.row());

        switch (role) {
        case NameRole:
            return hash.value("Name");
        case ReviewRole:
            return hash.value("Comment");
        default:
            return QVariant();
        }
    }
    return QVariant();
}

void ReviewModel::append(const QJsonArray &newData)
{
    beginResetModel();
    for (const QJsonValue &value : newData) {
        if (value.isObject()) {
            QHash<QString, QString> hash;
            QJsonObject jsonObject = value.toObject();
            for (auto it = jsonObject.begin(); it != jsonObject.end(); ++it) {
                hash.insert(it.key(), it.value().toString());
            }
            m_data.append(hash);
        }
    }
    endResetModel();
}

void ReviewModel::clear()
{
    beginResetModel();
    m_data.clear();
    endResetModel();
}
