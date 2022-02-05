
# Importing libraries
import pandas as pd
import numpy as np
from tensorflow import keras
from tensorflow.keras import Sequential, Input
from tensorflow.keras.layers import Dense
from tensorflow.keras.utils import to_categorical
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score

stroke = pd.read_csv('healthcare-dataset-stroke-data.csv')

# One hot encoding
for item in ['gender', 'hypertension', 'heart_disease', 'ever_married', 'work_type', 'Residence_type', 'smoking_status']:
  temp = pd.get_dummies(stroke[item], prefix=item)
  stroke = stroke.drop(item, axis=1)
  stroke = stroke.join(temp)



stroke_features = stroke[stroke.columns.difference(['stroke', 'id'])]
stroke_labels = stroke['stroke']

X_train, X_test, y_train, y_test = train_test_split(stroke_features, stroke_labels, test_size=0.2, shuffle=True)

model = Sequential()
model.add(Input(shape=(23,)))
model.add(Dense(64, activation='relu'))
model.add(Dense(16, activation='relu'))
model.add(Dense(4, activation='relu'))
model.add(Dense(2, activation='softmax'))



model.summary()

model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
model.fit(X_train, pd.get_dummies(y_train, prefix='output'), epochs=100)

predictions = pd.Series(model.predict(X_test).argmax(axis=-1))
print(accuracy_score(y_test, predictions))
