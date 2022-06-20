from rest_framework import serializers
from .models import *


class PredictionModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = PredictionModel
        fields = ('image', 'estimated_image', 'actual_pose', 'predicted_pose', 'created_at', 'updated_at')
