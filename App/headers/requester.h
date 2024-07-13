#ifndef REQUESTER_H
#define REQUESTER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>
#include "basemodel.h"
#include  "reviewmodel.h"

class Requester : public QObject
{
    Q_OBJECT

public:
    Requester(QObject* parent = nullptr);
    Requester(BaseModel* model, ReviewModel *reviewModel, QObject* parent = nullptr);
    Q_INVOKABLE QJsonArray getJsonData() const { return this->data; }
    void setJsonData(QJsonArray arr) { this->data = arr; emit dataChanged();}
    Q_INVOKABLE void findFilms(QHash<QString, QVariant> params);
    Q_INVOKABLE void findReview(QString id);
    Q_INVOKABLE void createReview(QString name, QString comment, QString id);
    BaseModel *getMovieDataAsListModel();
    ReviewModel *getReviewDataAsListModel();
    Q_INVOKABLE void updateMovieModel();
    Q_INVOKABLE void updateReviewModel();

private slots:
    void replyFinifshed();

signals:
    void dataChanged();
    void modelChanged();

private:
    QNetworkAccessManager* manager;
    QString url;
    QJsonArray data;
    BaseModel* model;
    ReviewModel* reviewModel;
};

#endif // REQUESTER_H
