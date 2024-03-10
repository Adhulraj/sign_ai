
import cv2
import numpy as np
import mediapipe as mp
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
import websockets
import asyncio
import base64
import os
import subprocess
import signal

mp_holistic = mp.solutions.holistic  # Holistic model
mp_drawing = mp.solutions.drawing_utils  # Drawing utilities
port = 5001

# Actions that we try to detect
actions = np.load('signs.npy')

model = Sequential()
model.add(LSTM(64, return_sequences=True,
          activation='relu', input_shape=(15, 1662)))
model.add(LSTM(128, return_sequences=True, activation='relu'))
model.add(LSTM(64, return_sequences=False, activation='relu'))
model.add(Dense(64, activation='relu'))
model.add(Dense(32, activation='relu'))
model.add(Dense(actions.shape[0], activation='softmax'))

model.load_weights('sign_model.h5')

def mediapipe_detection(image, model):
    # COLOR CONVERSION BGR 2 RGB
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    image.flags.writeable = False                  # Image is no longer writeable
    results = model.process(image)                 # Make prediction
    image.flags.writeable = True                   # Image is now writeable
    image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)  # COLOR COVERSION RGB 2 BGR
    return image, results


def draw_styled_landmarks(image, results):
    # Draw face connections
    mp_drawing.draw_landmarks(image, results.face_landmarks, mp_holistic.FACEMESH_TESSELATION,
                              mp_drawing.DrawingSpec(
                                  color=(80, 110, 10), thickness=1, circle_radius=1),
                              mp_drawing.DrawingSpec(
                                  color=(80, 256, 121), thickness=1, circle_radius=1)
                              )
    # Draw pose connections
    mp_drawing.draw_landmarks(image, results.pose_landmarks, mp_holistic.POSE_CONNECTIONS,
                              mp_drawing.DrawingSpec(
                                  color=(80, 22, 10), thickness=2, circle_radius=4),
                              mp_drawing.DrawingSpec(
                                  color=(80, 44, 121), thickness=2, circle_radius=2)
                              )
    # Draw left hand connections
    mp_drawing.draw_landmarks(image, results.left_hand_landmarks, mp_holistic.HAND_CONNECTIONS,
                              mp_drawing.DrawingSpec(
                                  color=(121, 22, 76), thickness=2, circle_radius=4),
                              mp_drawing.DrawingSpec(
                                  color=(121, 44, 250), thickness=2, circle_radius=2)
                              )
    # Draw right hand connections
    mp_drawing.draw_landmarks(image, results.right_hand_landmarks, mp_holistic.HAND_CONNECTIONS,
                              mp_drawing.DrawingSpec(
                                  color=(245, 117, 66), thickness=2, circle_radius=4),
                              mp_drawing.DrawingSpec(
                                  color=(245, 66, 230), thickness=2, circle_radius=2)
                              )


def extract_keypoints(results):
    pose = np.array([[res.x, res.y, res.z, res.visibility] for res in results.pose_landmarks.landmark]).flatten() if results.pose_landmarks else np.zeros(33*4)
    face = np.array([[res.x, res.y, res.z] for res in results.face_landmarks.landmark]).flatten(
    ) if results.face_landmarks else np.zeros(468*3)
    lh = np.array([[res.x, res.y, res.z] for res in results.left_hand_landmarks.landmark]).flatten(
    ) if results.left_hand_landmarks else np.zeros(21*3)
    rh = np.array([[res.x, res.y, res.z] for res in results.right_hand_landmarks.landmark]).flatten(
    ) if results.right_hand_landmarks else np.zeros(21*3)

    all_non_zero = np.count_nonzero(pose) != 0 and np.count_nonzero(face) != 0 and np.count_nonzero(rh) != 0

    # all_non_zero = np.count_nonzero(face) != 0 

    return np.concatenate([pose, face, lh, rh]), all_non_zero

async def check_process(process):
    while True:
        if process.poll() is not None:
            print("UI is terminated. Exiting server.")
            asyncio.get_event_loop().stop()
            break
        await asyncio.sleep(1)


async def server(websocket, path):
    print("Client Connected !")
    try:
        sequence = []
        sentence = []
        predictions = []
        threshold = 0.7
        cap = cv2.VideoCapture(0)
        data_len = 0

        

        with mp_holistic.Holistic(min_detection_confidence=0.5, min_tracking_confidence=0.5) as holistic:
            while cap.isOpened():

                # Read feed
                ret, frame = cap.read()

                # Make detections
                image, results = mediapipe_detection(frame, holistic)

                # Draw landmarks
                draw_styled_landmarks(image, results)

                # 2. Prediction logic
                keypoints, all_non_zero = extract_keypoints(results)

                if all_non_zero:
                    sequence.append(keypoints)
                    sequence = sequence[-15:]

                    if len(sequence) == 15:
                        res = model.predict(np.expand_dims(sequence, axis=0))[0]
                        predictions.append(np.argmax(res))

                        if np.unique(predictions[-10:])[0] == np.argmax(res):
                            if res[np.argmax(res)] > threshold:
                                if len(sentence) > 0:
                                    if actions[np.argmax(res)] != sentence[-1]:
                                        sentence.append(actions[np.argmax(res)])
                                else:
                                    sentence.append(actions[np.argmax(res)])

                        if len(sentence) > 20:
                            sentence = sentence[-20:]

                encoded = cv2.imencode('.jpg', image)[1]
                data = str(base64.b64encode(encoded)) # encode the image
                text = ' '.join(sentence)
                data = f"{data[2:len(data)-1]}|{text}" # data to send
                data_len+=1
                print(f"\rData sent {data_len}",end='')
                await websocket.send(data)
            cap.release()
    except websockets.ConnectionClosed:
        print("\nClient Disconnected !")
        cap.release()

    finally:
        if process.poll() is not None:
            print("Exiting Server")
            try:
                os.kill(os.getpid(), signal.SIGTERM)
            except Exception as e:
                print("Error in auto exiting the server")

process = subprocess.Popen(['SignBridge.exe'])
start_server = websockets.serve(server, port=port)
print("Started server on port : ", port)

event_loop = asyncio.get_event_loop()
event_loop.run_until_complete(start_server)
event_loop.create_task(check_process(process))  # start the check_process task
event_loop.run_forever()


if __name__ == '__main__':
    main()
