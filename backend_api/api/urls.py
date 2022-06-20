from django.urls import path
from .views import *

urlpatterns = [
    path('', home_view),
    path(upload_imag'e/', upload_image_view),
]
