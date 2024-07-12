#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include "requester.h"
#include "filtercontroller.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,

        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
    Qt::QueuedConnection);

    app.setWindowIcon(QIcon("qrc:/icons/mainIcon.jpg"));

    BaseModel *model = new BaseModel;
    ReviewModel *reviewModel = new ReviewModel;
    Requester req(model, reviewModel);
    FilterController filter;

    engine.addImportPath("qrc:/");

    engine.rootContext()->setContextProperty("requester", &req);
    engine.rootContext()->setContextProperty("filmModel", req.getMovieDataAsListModel());
    engine.rootContext()->setContextProperty("reviewModel", req.getReviewDataAsListModel());
    engine.rootContext()->setContextProperty("filter", &filter);

    engine.load(url);

    return app.exec();
}
