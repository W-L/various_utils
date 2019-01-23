import numpy as np
import cv2

cap = cv2.VideoCapture(1)


# Define the codec and create VideoWriter object
fourcc = cv2.VideoWriter_fourcc(*'XVID')
out = cv2.VideoWriter('testopencv.avi',fourcc, 30.0, (1280,1024))

'''
print("----------initial--------")
print(cap.get(3))
print(cap.get(4))
print(cap.get(5))
print(cap.get(8))
print(cap.get(10))
print(cap.get(11))
print(cap.get(12))
print(cap.get(13))
print(cap.get(14))
print(cap.get(15))
print("----------initial--------")
'''

while(True):
    # Capture frame-by-frame
    ret, frame = cap.read()

    #save video-stream
    #out.write(frame)

    # Display the resulting frame
    cv2.imshow('frame',frame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        cv2.imwrite('/home/lukas/snap.tiff',frame)
        break

# When everything is done release the capture
cap.release()
out.release()
cv2.destroyAllWindows()