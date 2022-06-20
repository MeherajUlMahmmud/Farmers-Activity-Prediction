import cv2 as cv
import skimage.exposure
import pandas as pd
import numpy as np

dnn_model = "api/pose_dnn.pb"
# read tensorflow model from disk
net = cv.dnn.readNetFromTensorflow(dnn_model)

inWidth = 368
inHeight = 368
thr = 0.2

BODY_PARTS = {
    "Nose": 0,
    "Neck": 1,
    "RShoulder": 2,
    "RElbow": 3,
    "RWrist": 4,
    "LShoulder": 5,
    "LElbow": 6,
    "LWrist": 7,
    "RHip": 8,
    "RKnee": 9,
    "RAnkle": 10,
    "LHip": 11,
    "LKnee": 12,
    "LAnkle": 13,
    "REye": 14,
    "LEye": 15,
    "REar": 16,
    "LEar": 17,
    "Background": 18,
}

POSE_PAIRS = [
    ["Neck", "RShoulder"],
    ["Neck", "LShoulder"],
    ["RShoulder", "RElbow"],
    ["RElbow", "RWrist"],
    ["LShoulder", "LElbow"],
    ["LElbow", "LWrist"],
    ["Neck", "RHip"],
    ["RHip", "RKnee"],
    ["RKnee", "RAnkle"],
    ["Neck", "LHip"],
    ["LHip", "LKnee"],
    ["LKnee", "LAnkle"],
    ["Neck", "Nose"],
    ["Nose", "REye"],
    ["REye", "REar"],
    ["Nose", "LEye"],
    ["LEye", "LEar"],
]


def remove_background(img):
    hsv = cv.cvtColor(img, cv.COLOR_BGR2HSV)  # convert to HSV
    # threshold using inRange
    range1 = (
        20,
        80,
        80,
    )  # lower range of HSV values to filter out the background color (green) from the image (HSV)
    range2 = (
        90,
        255,
        255,
    )  # upper range of HSV values to filter out the background color (green) from the image (HSV)
    mask = cv.inRange(
        hsv, range1, range2
    )  # create a mask of the image with the filtered values in the range (HSV)
    mask = (
        255 - mask
    )  # invert the mask to get the foreground pixels (HSV) and remove the background  pixels (HSV) from the image (HSV)

    # apply morphology opening to mask
    kernel = np.ones(
        (3, 3), np.uint8
    )  # create a kernel of 3x3 pixels to remove noise from the mask
    mask = cv.morphologyEx(
        mask, cv.MORPH_ERODE, kernel
    )  # erode to remove noise and holes in the mask
    mask = cv.morphologyEx(
        mask, cv.MORPH_CLOSE, kernel
    )  # close to fill holes in the mask and remove noise from the mask

    # antialias mask
    mask = cv.GaussianBlur(
        mask, (0, 0), sigmaX=3, sigmaY=3, borderType=cv.BORDER_DEFAULT
    )  # antialias mask using GaussianBlur with sigmaX=3 and sigmaY=3 for 3x3 kernel to remove noise
    mask = skimage.exposure.rescale_intensity(
        mask, in_range=(127.5, 255), out_range=(0, 255)
    )  # rescale mask to 0-255 range to make it easier to work with in OpenCV later on (OpenCV uses 0-255 range for all images)

    result = img.copy()  # copy image to result to draw on it
    result[mask == 0] = (255, 255, 255)  # set all pixels in mask to white

    return result


def resize_image(img):
    # resize image to fit in the network
    img = cv.resize(img, (inWidth, inHeight))  # 368x368
    return img


def preprocess_image(img):
    # img = remove_background(img)
    resized = resize_image(img)
    return resized


def pose_estimation(frame):
    frameWidth = frame.shape[1]  # frame width
    frameHeight = frame.shape[0]  # frame height

    net.setInput(
        cv.dnn.blobFromImage(
            frame,
            1.0,
            (inWidth, inHeight),
            (127.5, 127.5, 127.5),
            swapRB=True,
            crop=False,
        )
    )  # set input blob for the network (image)

    out = net.forward()  # forward pass of the network (get the output)
    out = out[
        :, :19, :, :
    ]  # choose the first 19 elements of the output (19 body parts + background)

    assert (
        len(BODY_PARTS) == out.shape[1]
    )  # check if the number of body parts detected is the same as the number of body parts that the model predicts
    points = []  # array of points

    for i in range(len(BODY_PARTS)):  # for each body part
        # Slice heatmap of corresponding body's part.
        heatMap = out[0, i, :, :]

        # Originally, we try to find all the local maximums. To simplify a sample
        # we just find a global one. However only a single pose at the same time
        # could be detected this way.
        _, conf, _, point = cv.minMaxLoc(
            heatMap
        )  # Find global maxima of the heatmap to draw a point
        x = (frameWidth * point[0]) / out.shape[
            3
        ]  # Scale coordinates to size of original image
        y = (frameHeight * point[1]) / out.shape[
            2
        ]  # Scale coordinates to size of original image

        # Add a point if it's confidence is higher than threshold.
        points.append(
            (int(x), int(y)) if conf > thr else None
        )  # Add a point if it's confidence is higher than threshold.

    for pair in POSE_PAIRS:
        partFrom = pair[0]  # Part to check.
        partTo = pair[1]  # Part to check.
        assert partFrom in BODY_PARTS  # Check if it exists.
        assert partTo in BODY_PARTS  # Check if it exists.

        idFrom = BODY_PARTS[partFrom]  # Get the ID of one part.
        idTo = BODY_PARTS[partTo]  # Get the ID of the other part.

        if points[idFrom] and points[idTo]:  # If both parts are found
            cv.line(frame, points[idFrom], points[idTo], (0, 255, 0), 5)  # Draw a line!
            cv.ellipse(
                frame, points[idFrom], (3, 3), 0, 0, 360, (0, 0, 255), cv.FILLED
            )  # Draw a circle!
            cv.ellipse(
                frame, points[idTo], (3, 3), 0, 0, 360, (0, 0, 255), cv.FILLED
            )  # Draw a circle!

    t, _ = net.getPerfProfile()  # Get the time it took to perform the inference.
    freq = cv.getTickFrequency() / 1000  # Get the frequency of the CPU.
    cv.putText(
        frame, "%.2fms" % (t / freq), (10, 20), cv.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 0)
    )  # Print the time it took to perform the inference.

    return frame, points


def detect_pose(body_points):
    parts = [i for i in BODY_PARTS.keys()]
    # print(parts)

    points = {}
    for i in range(len(body_points)):
        points[parts[i]] = body_points[i]

    if (
        points["Neck"]
        and (points["RHip"] or points["LHip"])
        and (points["RKnee"] or points["LKnee"])
    ):
        point1 = points["Neck"]
        point2 = points["RHip"] if points["RHip"] else points["LHip"]
        point3 = points["RKnee"] if points["RKnee"] else points["LKnee"]

        if (
            point3[1] < point2[1]
        ):  # if y coordinate of any knee is less than y coordinate of any hip
            point3 = point2  # then use the hip as the knee

        # find the angle between two straight lines
        angle = np.arctan2(point2[1] - point1[1], point2[0] - point1[0]) - np.arctan2(
            point3[1] - point2[1], point3[0] - point2[0]
        )
        angle = 180 - abs(angle * 180 / np.pi)

        if angle < 150 and angle > 60:
            if points["LAnkle"] or points["RAnkle"]:
                return (
                    "Farmer is engaged in a task, which is generally carried out while in a BENT position.",
                    "Bending",
                )

            else:
                return (
                    "Farmer is engaged in a task, which is generally carried out while in a SEATED position.",
                    "Sitting",
                )
        elif angle > 150 and angle < 200:
            return (
                "Farmer is engaged in a task, which is generally carried out while in a STANDING position.",
                "Standing",
            )
        else:
            return "Sorry, Unable to identify the pose", "Unknown"

    if not (points["LKnee"] or points["RKnee"]):
        return (
            "Farmer is engaged in a task, which is generally carried out while in a SEATED position.",
            "Sitting",
        )
