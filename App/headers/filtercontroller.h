#ifndef FILTERCONTROLLER_H
#define FILTERCONTROLLER_H

#include <QObject>
#include <QVariant>

class FilterController : public QObject
{
    Q_OBJECT
public:
    explicit FilterController(QObject *parent = nullptr);
    Q_INVOKABLE void insert(QString key, QVariant data);
    Q_INVOKABLE void insert(QString key, QString data);
    Q_INVOKABLE void clear();
    Q_INVOKABLE QHash<QString, QVariant> getFilter() const;

private:
    QHash<QString, QVariant> filter;
};

#endif // FILTERCONTROLLER_H
