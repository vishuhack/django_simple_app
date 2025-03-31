from django.urls import path
from app.views import home  # Use the correct app name


urlpatterns = [
    path('', home, name='home'),
]
