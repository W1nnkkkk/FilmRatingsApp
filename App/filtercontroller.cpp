#include "filtercontroller.h"

FilterController::FilterController(QObject *parent)
    : QObject{parent}
{}

void FilterController::insert(QString key, QVariant data)
{
    filter.insert(key, data);
}

void FilterController::insert(QString key, QString data)
{
    filter.insert(key, QVariant(data));
}

void FilterController::clear()
{
    filter.clear();
}

QHash<QString, QVariant> FilterController::getFilter() const
{
    return filter;
}
