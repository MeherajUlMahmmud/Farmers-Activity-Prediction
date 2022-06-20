from django.db import models


class PredictionModel(models.Model):
    image = models.ImageField()
    estimated_image = models.ImageField()
    predicted_pose = models.CharField(max_length=200)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
