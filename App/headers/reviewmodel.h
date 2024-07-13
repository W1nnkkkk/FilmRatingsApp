#ifndef REVIEWMODEL_H
#define REVIEWMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <QJsonArray>

class ReviewModel : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ReviewModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    void append(const QJsonArray &newData);
    void clear();

    enum MovieRoles {
        NameRole = Qt::UserRole + 1,
        ReviewRole
    };

private:
    QVector<QHash<QString, QString>> m_data;
};

#endif // REVIEWMODEL_H
