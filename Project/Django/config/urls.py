from django.contrib import admin
from django.db import connection
from django.http import HttpResponse
from django.urls import path


def index(request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT current_database(), version();")
        db_name, version = cursor.fetchone()
    return HttpResponse(
        "<h1>Django + PostgreSQL + Nginx</h1>"
        f"<p>База даних: {db_name}</p>"
        f"<p>{version}</p>"
    )


urlpatterns = [
    path("", index, name="index"),
    path("admin/", admin.site.urls),
]
