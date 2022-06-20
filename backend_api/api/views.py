import cv2
from django.core.files.base import ContentFile
import base64
from django.http import HttpResponse
import numpy as np

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.status import HTTP_200_OK, HTTP_500_INTERNAL_SERVER_ERROR

from .estimator import detect_pose, pose_estimation, preprocess_image
from .serializeers import PredictionModelSerializer

from .models import PredictionModel


def home_view(request):
    return HttpResponse("<h1>Farmers' Activity Prediction API</h1>")


@api_view(["POST"])
def upload_image_view(request):
    data = request.data
    image = data["file"]
    name = data["name"]

    try:
        image_data = base64.b64decode(image)
        image_file = ContentFile(image_data, name)

        # convert image_file to numpy array
        img = cv2.imdecode(np.fromstring(image_file.read(), np.uint8), cv2.IMREAD_UNCHANGED)

        estimated_img, desc, pose = predict_pose(img)
        print(pose)

        # convert numpy array to image file
        _, image_file = cv2.imencode(".jpg", estimated_img)

        # prediction = PredictionModel.objects.create(
        #     image=image_file, estimated_image=estimated_img, predicted_pose=pose
        # )
        # serialized_prediction = PredictionModelSerializer(prediction)
        return Response({"desc": desc, "pose": pose}, status=HTTP_200_OK)
    except Exception as e:
        print(e)
        return Response({"error": "Something went wrong"}, status=HTTP_500_INTERNAL_SERVER_ERROR)


def predict_pose(img):
    preprocessed_img = preprocess_image(img)
    estimated_img, body_points = pose_estimation(preprocessed_img)
    desc, pose = detect_pose(body_points)
    return estimated_img, desc, pose
