#include "requester.h"
#include <QStringList>
#include <QDebug>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>

Requester::Requester(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    url = "http://31.128.41.7:7979/movie/";
    this->model = new BaseModel;
    this->reviewModel = new ReviewModel;
}

Requester::Requester(BaseModel *model, ReviewModel *reviewModel, QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);
    url = "http://31.128.41.7:7979/movie/";
    this->model = model;
    this->reviewModel = reviewModel;
}

BaseModel *Requester::getMovieDataAsListModel()
{
    return model;
}

ReviewModel *Requester::getReviewDataAsListModel()
{
    return reviewModel;
}

void Requester::updateMovieModel()
{
    model->clear();
    model->append(this->data);
    emit modelChanged();
}

void Requester::updateReviewModel()
{
    reviewModel->clear();
    qDebug() << this->data;
    reviewModel->append(this->data);
    emit modelChanged();
}

void Requester::findFilms(QHash<QString, QVariant> params)
{
    QString newUrl;

    QHash<QString, QVariant>::const_iterator iterator = params.constBegin();
    while (iterator != params.constEnd()) {
        if (iterator.value().toString().split(", ").size() > 1) {
            for (auto &el : iterator.value().toString().split(", ")) {
                newUrl += "filter[" + iterator.key() + "]=";
                newUrl += el + "&";
            }
        }
        else {
            newUrl += iterator.key() + "=" + iterator.value().toString();
        }
        newUrl += "&";
        ++iterator;
    }

    qDebug() << newUrl;

    data = QJsonArray();
    QUrl getUrl(url + "find");
    getUrl.setQuery(newUrl);
    QNetworkRequest request(getUrl);
    QNetworkReply *reply = manager->get(request);
    reply->setProperty("requestType", "findFilms");
    connect(reply, &QNetworkReply::finished,
            this, &Requester::replyFinifshed);
}

void Requester::findReview(QString id)
{
    data = QJsonArray();
    QUrl getUrl(url + "review/find");
    getUrl.setQuery("_id=" + id);
    QNetworkRequest request(getUrl);
    QNetworkReply *reply = manager->get(request);
    reply->setProperty("requestType", "findReview");
    connect(reply, &QNetworkReply::finished,
            this, &Requester::replyFinifshed);
}

void Requester::createReview(QString name, QString comment, QString id)
{
    QNetworkRequest request(url + "review/create");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Content-Type", "application/json");

    QJsonObject jsonObject;
    QJsonObject update;
    QJsonObject review;
    review["name"] = name;
    review["comment"] = comment;
    update["review"] = review;
    jsonObject["update"] = update;
    QJsonObject filter;
    filter["_id"] = id;
    jsonObject["filter"] = filter;

    QJsonDocument jsonDoc(jsonObject);
    QByteArray jsonData = jsonDoc.toJson();

    QNetworkReply *reply = manager->post(request, jsonData);
    connect(reply, &QNetworkReply::finished, this,
            &Requester::replyFinifshed);
}

void Requester::replyFinifshed()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());

    if (reply->error() == QNetworkReply::NoError) {
        QByteArray resp = reply->readAll();
        QJsonDocument jsonDocument = QJsonDocument::fromJson(resp);
        QString requestType = reply->property("requestType").toString();
        setJsonData(jsonDocument.array());
        if (requestType == "findFilms") {
            model->append(jsonDocument.array());
        } else if (requestType == "findReview") {
            reviewModel->append(jsonDocument.array());
        }
    }
    reply->deleteLater();
}

