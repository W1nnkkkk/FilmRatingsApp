#ifndef BASEMODEL_H
#define BASEMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QJsonArray>

class BaseModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit BaseModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    void append(const QJsonArray &newData);
    void clear();

    enum MovieRoles {
        IdRole = Qt::UserRole + 1,
        ImageRole,
        NameRole,
        OriginalNameRole,
        YearRole,
        ReleaseDateRole,
        CountryRole,
        DirectorRole,
        GenreRole,
        DurationRole,
        StarringRole,
        ReviewRole
    };
private:
    QVector<QHash<QString, QString>> m_data;
};

#endif // BASEMODEL_H
